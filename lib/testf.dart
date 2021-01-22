import 'dart:convert';

import "FreestyleLibre.dart";
import 'TomatoBridgePacket.dart';
import 'utils.dart';

main() {
  num calibrationFactor = 13;

  var libreDumps = [
    // xDrip logs
    [
      DateTime(2020, 12, 3, 18, 50, 14),
      "UnnQFgMAAAAAAAAAAAAAAAAAAAAAAAAA74sKEpMDyAxZAJUDyChZAJwDyABZAKQDyAhZALkDyDRZAMgDyDxZAOMDyARZAO0DyPhYAOcDyPRYAOgDyKhYAGsDyIRYAHYDyLRYAH4DyMhYAH4DyLBYAIADyKRYAI0DyMhYAMcHyCiYAKsHyARYACwHyBCYAIUGyHBYABQFyDRYAEYEyFhXAMQDyByXAF8DiNJXAAMDyCCXAH0DyLRXAOQDyPSXADcEyAiYAA4EyFhYAJIDyESYAHkDyDSYAHQDyHBYACgDyKRYAH8DyLBYAA0GyCBZAPEFyJBYAOwFyIRYAOcFyOhYAP4FyAhZAHMGyJxZAL0GyFxZACEHyHhZAIYHyPRYAEAIyKhYAIIIyJBYAIgIyGyYAFUIyGhYACoIyBxYAJsXAABgWgABYAozURQHloBaAO2mGnMayATseWQ="
    ],
    [
      DateTime(2020, 12, 3, 18, 51, 16),
      "UnnQFgMAAAAAAAAAAAAAAAAAAAAAAAAAcjMMEpMDyAxZAJUDyChZAJwDyABZAKQDyAhZALkDyDRZAMgDyDxZAOMDyARZAO0DyPhYAOcDyPRYAOgDyKhYAN4DyGSYAOMDyERYAH4DyMhYAH4DyLBYAIADyKRYAI0DyMhYAMcHyCiYAKsHyARYACwHyBCYAIUGyHBYABQFyDRYAEYEyFhXAMQDyByXAF8DiNJXAAMDyCCXAH0DyLRXAOQDyPSXADcEyAiYAA4EyFhYAJIDyESYAHkDyDSYAHQDyHBYACgDyKRYAH8DyLBYAA0GyCBZAPEFyJBYAOwFyIRYAOcFyOhYAP4FyAhZAHMGyJxZAL0GyFxZACEHyHhZAIYHyPRYAEAIyKhYAIIIyJBYAIgIyGyYAFUIyGhYACoIyBxYAJwXAABgWgABYAozURQHloBaAO2mGnMayATseWQ="
    ],
  ];

  for (var i in libreDumps) {
    var packet = FreestyleLibrePacket(base64Decode(i[1]), calibrationFactor,
        readDate: i[0]);
    print(parsePacket(packet));
  }

  var miaoDumps = [
    // Android logs
    // invalid crc
    [
      DateTime(2021, 01, 11, 01, 24),
      "KAFrS4YJWXAGAKAH4DgABxABUnnQFgMAAAAAAAAAAAAAAAAAAAAAAAAAGoYFCA8FyBTZAP8EyCjZAO8EyDTZAOEEyDzZANwEyETZAP8EyNzXAPMEyNDXAMgEyMzXAL4EyNDXAKsEyBjYALcEyFjYAM8EyIzYAOUEyLjYAOQEyNjYAOcEyPDYAAMFyAjZAM4HyPjZAPIFyISbAC8FyKybAAQFyMybABUFyBzaAFAFyCjZACUFyDjYANMEyMzXAOIJyOjZAGMJyMTZAFIHyLzZAGAGyOTYAB0GyODYAFoFyGjYAFsFyIDYACAFyLzYAC4FyGTZADgGyNjZAJMHyKzZADAIyLCaABgIyBicABIIyGScACEIyJAcAXUIyFQcAZsIyKgcATcJyJjbACwJyODbAPsIyMTbAPEIyFybAFYJyNSZAHMJyATZAIMJyETZAIZLAABVWgABYAoPURQHloBaAO2mEp4ayAThOWYpoggAAW06"
    ],
    // valid logs
    [
      DateTime(2021, 01, 15, 19, 37),
      "KAFrFSEmznEGAKAH4DQABxABoHoQGwMAAAAAAAAAAAAAAAAAAAAAAAAAa6EACAkIyHhWAAEIyISWAPUHyKCWAAEIyJxWAAkIyKiWAAQIyMCWAP0HyOTWAAIIyARXAQAIyAxXAQMIyAQXAfEHyPzWAOsHyPBWAeUHyMCWAMwHyMTWANsHyOTWAOMHyNTWAGUKyBDXAKQJyPzWAE8JyAzXACgJyFBWABEJyKRWAKUIyGCWADUIyLCWAAEIyARXAfcFyJRZACwGyGgYAcgGyBzXAKwHyFSWALwIyCCWAOMJyMCVACULyOSUAJwLyFyVALsLyLSVAPELyFyVAN8LyNyUAEgLyFSVAPYKyCSVAMQKyGSVAJgKyHCVAJgKyGSVALMKyGCVALgKyFiVAIcKyACWAI4KyGiWAI4KyHyWAMYKyKBWAO4KyOzWANsKyLSWACEVAABo7gABggpgURQHloBaAO2mEpAayAQbeV0poggAAacS"
    ],
    [
      DateTime(2021, 01, 15, 20, 07),
      "KAFrFT8mznEGAKAH4DQABxABoHoQGwMAAAAAAAAAAAAAAAAAAAAAAAAAut4OCoMHyBhWAIEHyAxWAIUHyPSVAIsHyNRVAIEHyMSVAHcHyLSVAG8HyKRVAHIHyKCVAHMHyKCVAGkHyJiVAGAHyJSVAF0HyJCVAFkHyIyVAF4HyJCVAIEHyCyWAHcHyCSWAGUKyBDXAKQJyPzWAE8JyAzXACgJyFBWABEJyKRWAKUIyGCWADUIyLCWAAEIyARXAbMHyCyWAHoHyLSVAMgGyBzXAKwHyFSWALwIyCCWAOMJyMCVACULyOSUAJwLyFyVALsLyLSVAPELyFyVAN8LyNyUAEgLyFSVAPYKyCSVAMQKyGSVAJgKyHCVAJgKyGSVALMKyGCVALgKyFiVAIcKyACWAI4KyGiWAI4KyHyWAMYKyKBWAO4KyOzWANsKyLSWAD8VAABo7gABggpgURQHloBaAO2mEpAayAQbeV0poggAAaod"
    ],
    [
      DateTime(2021, 01, 15, 20, 16),
      "KAFrFUgmznEGAKAH4DQABxABoHoQGwMAAAAAAAAAAAAAAAAAAAAAAAAAKHcHCzcHyOCVACsHyCBWABUHyCCWAAEHyESWAPoGyHCWAOwGyJyWAOAGyMCWAHIHyKCVAHMHyKCVAGkHyJiVAGAHyJSVAF0HyJCVAFkHyIyVAF4HyJCVAFUHyJiVAEMHyMyVAGUKyBDXAKQJyPzWAE8JyAzXACgJyFBWABEJyKRWAKUIyGCWADUIyLCWAAEIyARXAbMHyCyWAHoHyLSVAPgGyHCWAKwHyFSWALwIyCCWAOMJyMCVACULyOSUAJwLyFyVALsLyLSVAPELyFyVAN8LyNyUAEgLyFSVAPYKyCSVAMQKyGSVAJgKyHCVAJgKyGSVALMKyGCVALgKyFiVAIcKyACWAI4KyGiWAI4KyHyWAMYKyKBWAO4KyOzWANsKyLSWAEgVAABo7gABggpgURQHloBaAO2mEpAayAQbeV0poggAAaIP"
    ],
    [
      DateTime(2021, 01, 15, 20, 21),
      "KAFrFU0mznEGAKAH4DQABxABoHoQGwMAAAAAAAAAAAAAAAAAAAAAAAAAG5AMCzcHyOCVACsHyCBWABUHyCCWAAEHyESWAPoGyHCWAOwGyJyWAOAGyMCWAMUGyLzWALYGyJTWAKYGyGyWAJkGyJCWAJ4GyLiWAFkHyIyVAF4HyJCVAFUHyJiVAEMHyMyVAGUKyBDXAKQJyPzWAE8JyAzXACgJyFBWABEJyKRWAKUIyGCWADUIyLCWAAEIyARXAbMHyCyWAHoHyLSVAPgGyHCWAKwHyFSWALwIyCCWAOMJyMCVACULyOSUAJwLyFyVALsLyLSVAPELyFyVAN8LyNyUAEgLyFSVAPYKyCSVAMQKyGSVAJgKyHCVAJgKyGSVALMKyGCVALgKyFiVAIcKyACWAI4KyGiWAI4KyHyWAMYKyKBWAO4KyOzWANsKyLSWAE0VAABo7gABggpgURQHloBaAO2mEpAayAQbeV0poggAAbQF"
    ],
    [
      DateTime(2021, 01, 15, 20, 24),
      "KAFrFVAmznEGAKAH4DQABxABoHoQGwMAAAAAAAAAAAAAAAAAAAAAAAAA1UUPCzcHyOCVACsHyCBWABUHyCCWAAEHyESWAPoGyHCWAOwGyJyWAOAGyMCWAMUGyLzWALYGyJTWAKYGyGyWAJkGyJCWAJ4GyLiWAIwGyKiWAHsGyJCWAHAGyHxWAEMHyMyVAGUKyBDXAKQJyPzWAE8JyAzXACgJyFBWABEJyKRWAKUIyGCWADUIyLCWAAEIyARXAbMHyCyWAHoHyLSVAPgGyHCWAKwHyFSWALwIyCCWAOMJyMCVACULyOSUAJwLyFyVALsLyLSVAPELyFyVAN8LyNyUAEgLyFSVAPYKyCSVAMQKyGSVAJgKyHCVAJgKyGSVALMKyGCVALgKyFiVAIcKyACWAI4KyGiWAI4KyHyWAMYKyKBWAO4KyOzWANsKyLSWAFAVAABo7gABggpgURQHloBaAO2mEpAayAQbeV0poggAARgb"
    ],
    [
      DateTime(2021, 01, 15, 20, 26),
      "KAFrFVImznEGAKAH4DQABxABoHoQGwMAAAAAAAAAAAAAAAAAAAAAAAAAp7ABC1AGyKiWACsHyCBWABUHyCCWAAEHyESWAPoGyHCWAOwGyJyWAOAGyMCWAMUGyLzWALYGyJTWAKYGyGyWAJkGyJCWAJ4GyLiWAIwGyKiWAHsGyJCWAHAGyHxWAGYGyHiWAGUKyBDXAKQJyPzWAE8JyAzXACgJyFBWABEJyKRWAKUIyGCWADUIyLCWAAEIyARXAbMHyCyWAHoHyLSVAPgGyHCWAKwHyFSWALwIyCCWAOMJyMCVACULyOSUAJwLyFyVALsLyLSVAPELyFyVAN8LyNyUAEgLyFSVAPYKyCSVAMQKyGSVAJgKyHCVAJgKyGSVALMKyGCVALgKyFiVAIcKyACWAI4KyGiWAI4KyHyWAMYKyKBWAO4KyOzWANsKyLSWAFIVAABo7gABggpgURQHloBaAO2mEpAayAQbeV0poggAAe4l"
    ],
    // iOS logs
    [
      DateTime(2021, 01, 15, 20, 48),
      "KAFrFWgmznEGAKAH4DQABxABoHoQGwMAAAAAAAAAAAAAAAAAAAAAAAAAkC4HDbsFyCjXAJ4FyDjXAI8FyCDXAIwFyADXAHsFyNyWAFwFyOyWAEoFyASXAPsFyNzWAOkFyLjWAOgFyJiWAOEFyHiWANoFyFyWANgFyESWANcFyHCWANQFyLSWAMsFyOjWAGUKyBDXAKQJyPzWAE8JyAzXACgJyFBWABEJyKRWAKUIyGCWADUIyLCWAAEIyARXAbMHyCyWAHoHyLSVAPgGyHCWACMGyPjWAJYFyCDXAOMJyMCVACULyOSUAJwLyFyVALsLyLSVAPELyFyVAN8LyNyUAEgLyFSVAPYKyCSVAMQKyGSVAJgKyHCVAJgKyGSVALMKyGCVALgKyFiVAIcKyACWAI4KyGiWAI4KyHyWAMYKyKBWAO4KyOzWANsKyLSWAGgVAABo7gABggpgURQHloBaAO2mEpAayAQbeV0poggAAWcl"
    ],
    [
      DateTime(2021, 01, 15, 20, 51),
      "KAFrFWsmznEGAKAH4DQABxABoHoQGwMAAAAAAAAAAAAAAAAAAAAAAAAAVgYKDbsFyCjXAJ4FyDjXAI8FyCDXAIwFyADXAHsFyNyWAFwFyOyWAEoFyASXADUFyCSXACwFyEAXATUFyEQXAeEFyHiWANoFyFyWANgFyESWANcFyHCWANQFyLSWAMsFyOjWAGUKyBDXAKQJyPzWAE8JyAzXACgJyFBWABEJyKRWAKUIyGCWADUIyLCWAAEIyARXAbMHyCyWAHoHyLSVAPgGyHCWACMGyPjWAJYFyCDXAOMJyMCVACULyOSUAJwLyFyVALsLyLSVAPELyFyVAN8LyNyUAEgLyFSVAPYKyCSVAMQKyGSVAJgKyHCVAJgKyGSVALMKyGCVALgKyFiVAIcKyACWAI4KyGiWAI4KyHyWAMYKyKBWAO4KyOzWANsKyLSWAGsVAABo7gABggpgURQHloBaAO2mEpAayAQbeV0poggAAesP"
    ],
  ];

  for (var i in miaoDumps) {
    var btPacket = TomatoBridgePacket(base64Decode(i[1]), calibrationFactor,
        readDate: i[0]);
    print(parseBTPacket(btPacket));
  }
}
