import 'dart:typed_data';

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