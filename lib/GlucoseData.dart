import 'dart:async';

import 'package:circular_buffer/circular_buffer.dart';
import 'package:rxdart/rxdart.dart';

import 'utils.dart';


abstract class GlucoseData implements StringSerializable {
  num get value;
  DateTime get time;
  GlucoseDataSource get source;
}

abstract class CalibrableGlucoseData implements GlucoseData {
  num get rawValue;
  void calibrate(num factor);
}

abstract class CalibrableGlucoseDataMixin implements CalibrableGlucoseData {
  num calibrationFactor;
  num get rawValue;

  num get value => rawValue * calibrationFactor;
  
  void calibrate(num factor) {
    calibrationFactor = factor;
  }
}

class GenericCalibrableGlucoseData with CalibrableGlucoseDataMixin {
  num rawValue;
  CalibrableGlucoseDataSource source;
  DateTime time;
  num calibrationFactor;

  GenericCalibrableGlucoseData(this.rawValue, this.calibrationFactor, this.time, this.source);

  @override
  String get instanceData => "$rawValue|$calibrationFactor|${time.toString()}|${source.sourceId}";

  @override
  factory GenericCalibrableGlucoseData.deserialize(CalibrableGlucoseDataSource src, String instanceData){
    var data = instanceData.split("|");
    return GenericCalibrableGlucoseData(num.parse(data[0]), num.parse(data[1]), DateTime.parse(data[2]), src);
  }

  @override
  final String typeName = "GenericCalibrableGlucoseData";
}


abstract class GlucoseDataSource implements StringSerializable {
  BehaviorSubject<GlucoseData> get dataStream;
  String get sourceId;
}

abstract class QuerableGlucoseDataSource implements GlucoseDataSource {
  Future<void> query();
}

abstract class CalibrableGlucoseDataSource implements GlucoseDataSource {
  BehaviorSubject<CalibrableGlucoseData> get dataStream;

  void calibrate(num factor);
}

abstract class CalibrableGlucoseDataSourceMixin implements CalibrableGlucoseDataSource {
  num calibrationFactor;

  void calibrate(num factor) {
    dataStream.value.calibrate(factor);
    calibrationFactor = factor;
  }
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



abstract class BatteryPowered {
  num get batteryLevel;
}

abstract class Lifetimable {
  Duration get remainingLifeTime;
}