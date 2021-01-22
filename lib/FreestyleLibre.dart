import 'dart:typed_data';
import 'dart:math';
import 'package:crclib/catalog.dart';
import 'GlucoseData.dart';
import 'utils.dart';

/*
    Most of this code is based on xDrip+ code
*/

const FREESTYLELIBRE_PACKET_LENGTH = 344;

bool libreCRC(Uint8List data) =>
    Crc16Mcrf4xx().convert(data.sublist(2)) == reverseBits(data[1] << 8 | data[0], 16);

enum FreeStyleLibreSensorStatus {
  unknown,
  notYetStarted,
  starting,
  ready,          // status for 14 days and 12 h of normal operation, libre reader quits after 14 days
  expired,        // status of the following 12 h, sensor delivers last BG reading constantly
  shutdown,       // sensor stops operation after 15d after start
  inFailure,
}

class FreestyleLibreGlucoseData with CalibrableGlucoseDataMixin implements GlucoseData {
  FreestyleLibrePacket packet;
  int index;
  bool historical;
  num calibrationFactor;

  FreestyleLibreGlucoseData(this.packet, this.index, this.calibrationFactor, {this.historical = false});

  int get _i {
    // ring buffer index
    var i = (historical ? packet._indexHistory : packet._indexTrend) - index - 1;
    if (i < 0) i += historical ? 32 : 16;
    return i;
  }

  int get rawValue {
    var offset = historical ? 124 : 28;

    return (packet._data[_i * 6 + offset] | packet._data[_i * 6 + offset + 1] << 8) & 0x1FFF;
  }

  int get sensorTime =>
    max(0, historical ?
      ((packet._sensorAge - 3) ~/ 15 - index) * 15
        :
      packet._sensorAge - index
    );

  DateTime get time => packet.sensorFirstUse.add(Duration(minutes: sensorTime));

  @override
  GlucoseDataSource get source => packet.source;

  @override
  bool operator ==(Object other) =>
      other is FreestyleLibreGlucoseData &&
      other?.packet?.serialNumber == packet?.serialNumber &&
      other?.sensorTime == sensorTime &&
      other?.rawValue == rawValue;

  @override
  int get hashCode => packet?.serialNumber.hashCode ^
      sensorTime.hashCode ^
      rawValue.hashCode;

  // workaround for deserialization to another class
  @override
  final String typeName = "GenericCalibrableGlucoseData";

  @override
  String get instanceData => "$rawValue|$calibrationFactor|${time.toString()}|${source?.sourceId ?? ""}";

  static GenericCalibrableGlucoseData deserialize(CalibrableGlucoseDataSource src, String instanceData){
    return GenericCalibrableGlucoseData.deserialize(src, instanceData);
  }
}

class FreestyleLibrePacket {
  Uint8List _data;
  DateTime readDate;
  GlucoseDataSource source;
  String serialNumber;
  num _calibrationFactor;

  FreestyleLibrePacket(this._data, this._calibrationFactor, {this.serialNumber, DateTime readDate, this.source}){
    readDate ??= DateTime.now();
    this.readDate = DateTime(readDate.year, readDate.month, readDate.day, readDate.hour, readDate.minute);
  }

  FreeStyleLibreSensorStatus get status =>
    _data[4] < FreeStyleLibreSensorStatus.values.length ? FreeStyleLibreSensorStatus.values[_data[4]] : FreeStyleLibreSensorStatus.unknown;

  bool get sensorReady =>
      [FreeStyleLibreSensorStatus.starting, FreeStyleLibreSensorStatus.ready].contains(status);

  int get _indexHistory => _data[27];

  int get _indexTrend => _data[26];

  // in minutes
  int get _sensorAge => _data[317] << 8 | _data[316];

  Duration get sensorAge => Duration(minutes: _sensorAge);

  DateTime get sensorFirstUse => readDate.subtract(sensorAge);

  Duration get remainingSensorLifeTime => Duration(days: 14) - sensorAge;

  Iterable<FreestyleLibreGlucoseData> iterHistory() sync* {
    // loads history values (ring buffer, starting at _indexHistory. byte 124-315)
    // history are readings in 15 minutes interval
    // most recent value corresponds to (sensorAge - 3) % 15 + 3 ago (thanks @dspnikder)
    for(var index = 0; index < 32; index++)
      yield FreestyleLibreGlucoseData(this, index, _calibrationFactor, historical: true);
  }

  Iterable<FreestyleLibreGlucoseData> iterTrend() sync* {
    // loads trend values (ring buffer, starting at _indexTrend. byte 28-123)
    // trend values are readings in 1 minute interval
    // most recent value corresponds to sensorAge timing
    for(var index = 0; index < 16; index++)
      yield FreestyleLibreGlucoseData(this, index, _calibrationFactor);
  }

  // https://github.com/NightscoutFoundation/xDrip/blob/2021.01.13/app/src/main/java/com/eveningoutpost/dexdrip/UtilityModels/LibreUtils.java#L68
  bool areChecksumsCorrect() =>
    libreCRC(_data.sublist(0, 24)) &&
    libreCRC(_data.sublist(24, 320)) &&
    libreCRC(_data.sublist(320, 344));
}
