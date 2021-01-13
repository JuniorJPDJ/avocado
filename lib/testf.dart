import 'dart:convert';
import 'dart:typed_data';
import 'package:pretty_things/utils.dart';

import 'TomatoBridgePacket.dart';
import "FreestyleLibre.dart";

void printReading(FreestyleLibreGlucoseData reading, num calibrationMultipiler){
  print("Reading ${reading.index}: ${reading.glucoseReading/calibrationMultipiler} (${reading.glucoseReading}), time: ${reading.time} (${reading.sensorTime})");
}

void printPacket(FreestyleLibrePacket packet, num calibrationMultipiler){
  print("Sensor status: ${packet.status}");
  print("Sensor age: ${packet.sensorAge} min, first use: ${packet.sensorFirstUse}, read time: ${packet.readDate}");

  print("\nTrend readings:");
  for(FreestyleLibreGlucoseData reading in packet.iterTrend())
    printReading(reading, calibrationMultipiler);

  print("\nHistory readings:");
  for(FreestyleLibreGlucoseData reading in packet.iterHistory())
    printReading(reading, calibrationMultipiler);

  print("");
}

void printBTPacket(TomatoBridgePacket packet, num calibrationMultipiler){
  print("Tomato battery level: ${packet.batteryLevel}");
  print("Sensor patch: uid=${toHex(packet.patchUid)}, info=${toHex(packet.patchInfo)}");
  print("Sensor serial number: ${packet.freestyleLibreSerialNumber}");
  printPacket(packet.packet, calibrationMultipiler);
}

main() {
  double cal = 1200/90;
  /*
  var readTime1 = DateTime(2020, 12, 3, 18, 50, 14);
  var dump1 = base64Decode("UnnQFgMAAAAAAAAAAAAAAAAAAAAAAAAA74sKEpMDyAxZAJUDyChZAJwDyABZAKQDyAhZALkDyDRZAMgDyDxZAOMDyARZAO0DyPhYAOcDyPRYAOgDyKhYAGsDyIRYAHYDyLRYAH4DyMhYAH4DyLBYAIADyKRYAI0DyMhYAMcHyCiYAKsHyARYACwHyBCYAIUGyHBYABQFyDRYAEYEyFhXAMQDyByXAF8DiNJXAAMDyCCXAH0DyLRXAOQDyPSXADcEyAiYAA4EyFhYAJIDyESYAHkDyDSYAHQDyHBYACgDyKRYAH8DyLBYAA0GyCBZAPEFyJBYAOwFyIRYAOcFyOhYAP4FyAhZAHMGyJxZAL0GyFxZACEHyHhZAIYHyPRYAEAIyKhYAIIIyJBYAIgIyGyYAFUIyGhYACoIyBxYAJsXAABgWgABYAozURQHloBaAO2mGnMayATseWQ=");
  var packet1 = FreestyleLibrePacket(dump1, readDate: readTime1);
  printPacket(packet1);

  var readTime2 = DateTime(2020, 12, 3, 18, 51, 16);
  var dump2 = base64Decode("UnnQFgMAAAAAAAAAAAAAAAAAAAAAAAAAcjMMEpMDyAxZAJUDyChZAJwDyABZAKQDyAhZALkDyDRZAMgDyDxZAOMDyARZAO0DyPhYAOcDyPRYAOgDyKhYAN4DyGSYAOMDyERYAH4DyMhYAH4DyLBYAIADyKRYAI0DyMhYAMcHyCiYAKsHyARYACwHyBCYAIUGyHBYABQFyDRYAEYEyFhXAMQDyByXAF8DiNJXAAMDyCCXAH0DyLRXAOQDyPSXADcEyAiYAA4EyFhYAJIDyESYAHkDyDSYAHQDyHBYACgDyKRYAH8DyLBYAA0GyCBZAPEFyJBYAOwFyIRYAOcFyOhYAP4FyAhZAHMGyJxZAL0GyFxZACEHyHhZAIYHyPRYAEAIyKhYAIIIyJBYAIgIyGyYAFUIyGhYACoIyBxYAJwXAABgWgABYAozURQHloBaAO2mGnMayATseWQ=");
  var packet2 = FreestyleLibrePacket(dump2, readDate: readTime2);
  printPacket(packet2);
  */
  
  var btReadTime1 = DateTime(2021, 01, 11, 1, 24);
  var btDump1 = base64Decode("KAFrS4YJWXAGAKAH4DgABxABUnnQFgMAAAAAAAAAAAAAAAAAAAAAAAAAGoYFCA8FyBTZAP8EyCjZAO8EyDTZAOEEyDzZANwEyETZAP8EyNzXAPMEyNDXAMgEyMzXAL4EyNDXAKsEyBjYALcEyFjYAM8EyIzYAOUEyLjYAOQEyNjYAOcEyPDYAAMFyAjZAM4HyPjZAPIFyISbAC8FyKybAAQFyMybABUFyBzaAFAFyCjZACUFyDjYANMEyMzXAOIJyOjZAGMJyMTZAFIHyLzZAGAGyOTYAB0GyODYAFoFyGjYAFsFyIDYACAFyLzYAC4FyGTZADgGyNjZAJMHyKzZADAIyLCaABgIyBicABIIyGScACEIyJAcAXUIyFQcAZsIyKgcATcJyJjbACwJyODbAPsIyMTbAPEIyFybAFYJyNSZAHMJyATZAIMJyETZAIZLAABVWgABYAoPURQHloBaAO2mEp4ayAThOWYpoggAAW06");
  var btPacket1 = TomatoBridgePacket(btDump1, readDate: btReadTime1);
  printBTPacket(btPacket1, cal);
}
