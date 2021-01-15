import 'dart:typed_data';

import 'TomatoBridgePacket.dart';
import "FreestyleLibre.dart";

String toHex(Uint8List data) => data.map((i) => i.toRadixString(16).padLeft(2, '0')).join();

// little endian bit order, big endian byte order, assumes everything fits in data
// 0x01, 0x80, 0x01 -> 0000_0001_1000_0000_0000_0001
int getBit(Uint8List data, int bitNum) => ((data[bitNum ~/ 8] & (1 << (7 - bitNum % 8))) == 0) ? 0 : 1;

int reverseBits(int input, [int bitLength = 8]) {
  int output = 0;
  for (int i = 0; i < bitLength; ++i) {
    output = (output << 1) | (input & 1);
    input >>= 1;
  }
  return output;
}

Stream<String> accumulateStream(Stream<String> stream) async* {
  String buf;
  await for(String val in stream){
    if(buf == null) buf = val;
    else buf = buf + val;

    yield buf;
  }
}


String parseReading(FreestyleLibreGlucoseData reading) =>
    "Reading ${reading.index}: raw value: ${reading.glucoseReading}, time: ${reading.time} (${reading.sensorTime})\n";


String parsePacket(FreestyleLibrePacket packet){
  var out = StringBuffer();

  out.write("Packet checksum valid: ${packet.areChecksumsCorrect()}\n");
  out.write("Sensor status: ${packet.status}\n");
  out.write("Sensor age: ${packet.sensorAge} min, first use: ${packet.sensorFirstUse}, read time: ${packet.readDate}\n");

  out.write("\nTrend readings:\n");
  for(FreestyleLibreGlucoseData reading in packet.iterTrend())
    out.write(parseReading(reading));

  /*
  out.write("\nHistory readings:\n");
  for(FreestyleLibreGlucoseData reading in packet.iterHistory())
    out.write(parseReading(reading, calibrationMultipiler));
  */

  out.write("\n");
  return out.toString();
}

String parseBTPacket(TomatoBridgePacket packet){
  var out = StringBuffer();

  out.write("Tomato battery level: ${packet.batteryLevel}\n");
  out.write("Sensor patch: uid=${toHex(packet.patchUid)}, info=${toHex(packet.patchInfo)}\n");
  out.write("Sensor serial number: ${packet.freestyleLibreSerialNumber}\n");
  out.write(parsePacket(packet.packet));

  return out.toString();
}