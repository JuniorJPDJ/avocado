import 'dart:typed_data';

import 'FreestyleLibre.dart';
import 'GlucoseData.dart';
import 'utils.dart';

/*
    Most of this code is based on xDrip+ code
*/

const FREESTYLELIBRE_SN_LOOKUP = [
  "0",
  "1",
  "2",
  "3",
  "4",
  "5",
  "6",
  "7",
  "8",
  "9",
  "A",
  "C",
  "D",
  "E",
  "F",
  "G",
  "H",
  "J",
  "K",
  "L",
  "M",
  "N",
  "P",
  "Q",
  "R",
  "T",
  "U",
  "V",
  "W",
  "X",
  "Y",
  "Z"
];

const TOMATO_HEADER_LENGTH = 18;
const TOMATO_PATCH_SUFFIX_LENGTH = 6;
const TOMATO_MIN_PACKET_LENGTH =
    TOMATO_HEADER_LENGTH + FREESTYLELIBRE_PACKET_LENGTH + 1;

class TomatoBridgePacket {
  Uint8List _data;
  FreestyleLibrePacket packet;

  // TOMATO_HEADER + FREESTYLELIBRE_PACKET + 1B SUFFIX (wtf?) + optional TOMATO_PATCH_SUFFIX

  TomatoBridgePacket(this._data, num _calibrationFactor,
      {DateTime readDate, GlucoseDataSource source}) {
    packet = FreestyleLibrePacket(
        _data.sublist(TOMATO_HEADER_LENGTH,
            TOMATO_HEADER_LENGTH + FREESTYLELIBRE_PACKET_LENGTH),
        _calibrationFactor,
        serialNumber: this.freestyleLibreSerialNumber,
        readDate: readDate,
        source: source);
  }

  int get batteryLevel => _data[13];

  DateTime get readDate => packet.readDate;

  GlucoseDataSource get source => packet.source;

  // useless?
  Uint8List get patchUid => _data.sublist(5, 13);

  // useless?
  Uint8List get patchInfo =>
      _data.length >= TOMATO_MIN_PACKET_LENGTH + TOMATO_PATCH_SUFFIX_LENGTH
          ? _data.sublist(TOMATO_MIN_PACKET_LENGTH,
              TOMATO_MIN_PACKET_LENGTH + TOMATO_PATCH_SUFFIX_LENGTH)
          : null;

  String get freestyleLibreSerialNumber {
    var snData =
        Uint8List.fromList(_data.sublist(5, 11).reversed.toList() + [0, 0]);
    String sn = '0';

    for (var i = 0; i < 10; ++i) {
      sn += FREESTYLELIBRE_SN_LOOKUP[getBit(snData, i * 5) << 4 |
          getBit(snData, i * 5 + 1) << 3 |
          getBit(snData, i * 5 + 2) << 2 |
          getBit(snData, i * 5 + 3) << 1 |
          getBit(snData, i * 5 + 4)];
    }

    return sn;
  }
}
