import 'dart:typed_data';

String toHex(Uint8List data){
  return data.map((i) => i.toRadixString(16).padLeft(2, '0')).join();
}