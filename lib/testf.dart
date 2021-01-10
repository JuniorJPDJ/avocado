import 'dart:convert';
import "FreestyleLibre.dart";

void printReading(FreestyleLibreGlucoseData reading){
  print("Reading ${reading.index}: ${reading.glucoseReading}, time: ${reading.time} (${reading.sensorTime})");
}

void printPacket(FreestyleLibrePacket packet){
  print("Sensor status: ${packet.status}");
  print("Sensor age: ${packet.sensorAge} min, first use: ${packet.sensorFirstUse}, read time: ${packet.readDate}");

  print("\nTrend readings:");
  for(FreestyleLibreGlucoseData reading in packet.iterTrend())
    printReading(reading);

  print("\nHistory readings:");
  for(FreestyleLibreGlucoseData reading in packet.iterHistory())
    printReading(reading);
}

main() {
  var readTime1 = DateTime(2020, 12, 3, 18, 50, 14);
  var dump1 = base64Decode("UnnQFgMAAAAAAAAAAAAAAAAAAAAAAAAA74sKEpMDyAxZAJUDyChZAJwDyABZAKQDyAhZALkDyDRZAMgDyDxZAOMDyARZAO0DyPhYAOcDyPRYAOgDyKhYAGsDyIRYAHYDyLRYAH4DyMhYAH4DyLBYAIADyKRYAI0DyMhYAMcHyCiYAKsHyARYACwHyBCYAIUGyHBYABQFyDRYAEYEyFhXAMQDyByXAF8DiNJXAAMDyCCXAH0DyLRXAOQDyPSXADcEyAiYAA4EyFhYAJIDyESYAHkDyDSYAHQDyHBYACgDyKRYAH8DyLBYAA0GyCBZAPEFyJBYAOwFyIRYAOcFyOhYAP4FyAhZAHMGyJxZAL0GyFxZACEHyHhZAIYHyPRYAEAIyKhYAIIIyJBYAIgIyGyYAFUIyGhYACoIyBxYAJsXAABgWgABYAozURQHloBaAO2mGnMayATseWQ=");

  var readTime2 = DateTime(2020, 12, 3, 18, 51, 16);
  var dump2 = base64Decode("UnnQFgMAAAAAAAAAAAAAAAAAAAAAAAAAcjMMEpMDyAxZAJUDyChZAJwDyABZAKQDyAhZALkDyDRZAMgDyDxZAOMDyARZAO0DyPhYAOcDyPRYAOgDyKhYAN4DyGSYAOMDyERYAH4DyMhYAH4DyLBYAIADyKRYAI0DyMhYAMcHyCiYAKsHyARYACwHyBCYAIUGyHBYABQFyDRYAEYEyFhXAMQDyByXAF8DiNJXAAMDyCCXAH0DyLRXAOQDyPSXADcEyAiYAA4EyFhYAJIDyESYAHkDyDSYAHQDyHBYACgDyKRYAH8DyLBYAA0GyCBZAPEFyJBYAOwFyIRYAOcFyOhYAP4FyAhZAHMGyJxZAL0GyFxZACEHyHhZAIYHyPRYAEAIyKhYAIIIyJBYAIgIyGyYAFUIyGhYACoIyBxYAJwXAABgWgABYAozURQHloBaAO2mGnMayATseWQ=");

  printPacket(FreestyleLibrePacket(dump1, readDate: readTime1));
  print("");
  printPacket(FreestyleLibrePacket(dump2, readDate: readTime2));
}

main2(){
  for(int sensorAge = -3; sensorAge < 6200; ++sensorAge) {
    for(int index = 0; index < 32; ++index) {
      var w_abs = ((sensorAge - 3) ~/ 15).abs() * 15 - index * 15;
      var wo_abs = ((sensorAge - 3) ~/ 15) * 15 - index * 15;
      if(w_abs != wo_abs) {
        print("Age: $sensorAge, index: $index");
        print("ABS: ${w_abs}");
        print("NON-ABS: ${wo_abs}");
      }
    }
  }
}