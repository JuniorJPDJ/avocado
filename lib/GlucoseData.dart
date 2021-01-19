import 'dart:async';

import 'package:circular_buffer/circular_buffer.dart';
import 'package:rxdart/rxdart.dart';

abstract class GlucoseData {
  num get value;
  DateTime get time;
  GlucoseDataSource get source;
  void calibrate(num factor);
}

abstract class GlucoseDataSource {
  String get id;
  BehaviorSubject<GlucoseData> get dataStream;
  void calibrate(num factor);
  Future<void> query();
}

class GlucoseDataBuffer extends CircularBuffer<GlucoseData>{
  BehaviorSubject<GlucoseDataBuffer> updatesStream;

  GlucoseDataBuffer([length = 24*60]) : super(length) {
    // one measurement per minute, 24h
    updatesStream = BehaviorSubject.seeded(this);
  }

  @override
  void add(GlucoseData el) {
    super.add(el);
    updatesStream.add(this);
  }
}