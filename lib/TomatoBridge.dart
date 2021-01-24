import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:rxdart/rxdart.dart';

import 'FreestyleLibre.dart';
import 'GlucoseData.dart';
import 'TomatoBridgePacket.dart';
import 'utils.dart';

enum TOMATO_STATE { REQUEST_DATA_SENT, RECEIVING_DATA }

// https://github.com/NightscoutFoundation/xDrip/blob/2020.12.18/app/src/main/java/com/eveningoutpost/dexdrip/Models/Tomato.java#L237
class TomatoBridge
    with CalibrableGlucoseDataSourceMixin
    implements
        GlucoseDataSource,
        QuerableGlucoseDataSource,
        Lifetimable,
        BatteryPowered {
  // https://infocenter.nordicsemi.com/index.jsp?topic=%2Fcom.nordic.infocenter.sdk5.v15.3.0%2Fble_sdk_app_nus_eval.html
  static const String NRF_SERVICE = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
  static const String NRF_CHR_TX = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E";
  static const String NRF_CHR_RX = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E";

  BluetoothDevice _device;
  BluetoothService _service;
  BluetoothCharacteristic _rx;
  BluetoothCharacteristic _tx;

  Uint8List _rxBuf;

  BehaviorSubject<TomatoBridgePacket> rxPacketStream;
  BehaviorSubject<FreestyleLibreGlucoseData> dataStream;

  num calibrationFactor;
  Duration connTimeout;

  TOMATO_STATE state;

  TomatoBridge._create(BluetoothDevice device, this.connTimeout) {
    _device = device;
    _rxBuf = Uint8List(0);
    rxPacketStream = BehaviorSubject();
    dataStream = BehaviorSubject();

    rxPacketStream.listen(_onPacket);
  }

  void _onRX(List<int> _data) {
    // based on xDrip+ code
    Uint8List data = Uint8List.fromList(_data);
    log("Recieved data: ${toHex(data)}", name: "TomatoBridge");

    if (state == TOMATO_STATE.REQUEST_DATA_SENT) {
      if (data.length == 1 && data[0] == 0x34) {
        log("No sensor found near bridge", name: "TomatoBridge");
        return;
      } else if (data.length == 1 && data[0] == 0x32) {
        // allow sensor confirm (2B), make it send data every 5 minutes (didn't work?) (2B), start reading (1B)
        bridgeRawWrite(Uint8List.fromList([0xD3, 0x01, 0xD1, 0x05, 0xF0]));
        // uh, we can't ensure async write to be sent, but IT SHOULD WORK ANYWAY!
        return;
      } else if (data.length >= TOMATO_HEADER_LENGTH && data[0] == 0x28) {
        var pkgLen = (data[1] << 8) + data[2];
        log("Got initial packet with size: $pkgLen", name: "TomatoBridge");
        // starting accumulating packet data in buffer
        _rxBuf = data;
        // no need to append, this is initial packet
        state = TOMATO_STATE.RECEIVING_DATA;
      } else {
        log("Unknown initial packet from bridge", name: "TomatoBridge");
        return;
      }
    } else if (state == TOMATO_STATE.RECEIVING_DATA) {
      // MOAR DATAAAA!
      _rxBuf = Uint8List.fromList(
          _rxBuf + data); // didn't find better way to concatenate byte arrays
    } else {
      // only option is NULL-STATE - class not initialized
      log("RX on uninitialized bridge", name: "TomatoBridge");
      return;
    }

    _parsePacketsFromBuffer();
  }

  void _parsePacketsFromBuffer() {
    // we anyway need to ask for incoming packets (periodical push doesn't work)
    // and on init we are clearing buffer,
    // so handling more than one package at time is not necessary
    if (_rxBuf.length < TOMATO_MIN_PACKET_LENGTH) {
      return;
    }

    TomatoBridgePacket packet;

    if (_rxBuf.length >= TOMATO_MIN_PACKET_LENGTH + TOMATO_PATCH_SUFFIX_LENGTH)
      packet = TomatoBridgePacket(
          _rxBuf.sublist(
              0, TOMATO_MIN_PACKET_LENGTH + TOMATO_PATCH_SUFFIX_LENGTH),
          calibrationFactor,
          source: this);
    else
      packet = TomatoBridgePacket(
          _rxBuf.sublist(0, TOMATO_MIN_PACKET_LENGTH), calibrationFactor,
          source: this);

    rxPacketStream.add(packet);
  }

  Future<void> _onPacket(TomatoBridgePacket packet) async {
    log(parseBTPacket(packet));

    if (packet.packet.areChecksumsCorrect()) {
      if (calibrationFactor != null) {
        // skip propagation of data if not calibrated
        List<FreestyleLibreGlucoseData> measurements =
            List.from(packet.packet.iterTrend());

        // cut already handled measurements
        int index = measurements.indexOf(dataStream.value);
        if (dataStream.value != null && index > 0)
          measurements = measurements.sublist(0, index);

        // oldest first
        for (FreestyleLibreGlucoseData m in measurements.reversed)
          dataStream.add(m);
      }
    } else {
      await Future.delayed(Duration(seconds: 5));
      initSensor();
    }
  }

  static Future<TomatoBridge> create(BluetoothDevice device,
      {Duration timeout}) async {
    timeout ??= Duration(seconds: 30);

    var self = TomatoBridge._create(device, timeout);

    if (await device.state.first != BluetoothDeviceState.connected)
      await device.connect(timeout: timeout);

    self._service = (await device.discoverServices()).firstWhere(
        (srv) => srv.uuid.toString().toUpperCase() == NRF_SERVICE, orElse: () {
      throw StateError("Not tomato? NRF service not found.");
    });

    self._rx = self._service.characteristics.firstWhere(
        (chr) => chr.uuid.toString().toUpperCase() == NRF_CHR_RX, orElse: () {
      throw StateError("Not tomato? NRF RX characteristic not found");
    });
    self._tx = self._service.characteristics.firstWhere(
        (chr) => chr.uuid.toString().toUpperCase() == NRF_CHR_TX, orElse: () {
      throw StateError("Not tomato? NRF TX characteristic not found");
    });

    await self._rx.setNotifyValue(true);
    self._rx.value.listen(self._onRX);

    return self;
  }

  static bool isTomato(BluetoothDevice device) =>
      device.name.startsWith("miaomiao") || device.name.startsWith("watlaa");

  Future<void> bridgeRawWrite(Uint8List data) async {
    log("Sending data: ${toHex(data)}", name: "TomatoBridge");
    await _tx.write(data);
  }

  Future<void> initSensor() async {
    if (await _device.state.first != BluetoothDeviceState.connected)
      await _device.connect(timeout: connTimeout);
    // Make tomato send data every 5 minutes (0xD1, 0x05), start reading (0xF0)
    // I'VE NO DUCKING IDEA WHAT IT REALLY MEANS AND FOUND NOTHING ABOUT IT, JUST NEED TO PRAY IT WORKS
    await bridgeRawWrite(Uint8List.fromList([0xD1, 0x05, 0xF0]));
    log("Sent init sequence", name: "TomatoBridge");
    state = TOMATO_STATE.REQUEST_DATA_SENT;
  }

  @override
  Future<void> query() async {
    await initSensor();
  }

  @override
  String get instanceData => _device.id.toString();

  @override
  String get sourceId => typeName + instanceData;

  @override
  TomatoBridge.deserialize(String instanceData) {
    // TODO: implement TomatoBridge deserialization
    throw UnimplementedError();
  }

  @override
  final String typeName = "TomatoBridge";

  @override
  num get batteryLevel => rxPacketStream?.value?.batteryLevel;

  @override
  Duration get remainingLifeTime =>
      rxPacketStream?.value?.packet?.remainingSensorLifeTime;

  @override
  CalibrableGlucoseData get lastReading =>
      super.lastReading ??
      FreestyleLibreGlucoseData(
          rxPacketStream?.value?.packet, 0, calibrationFactor);
}
