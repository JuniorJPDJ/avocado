import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'AvocadoState.dart';
import 'package:pretty_things/alarm_view.dart';
import 'GlucoseData.dart';
import 'start_view.dart';


// <TEST DATA>
class TmpDataSource extends GlucoseDataSource {
  static int tmpId = 0;

  int _id;
  num calibrationFactor;
  BehaviorSubject<TmpGlucoseData> dataStream;

  TmpDataSource(){
    _id = tmpId++;
    dataStream = BehaviorSubject();
    calibrationFactor = 10;

    dataStream.addStream(
        Stream.periodic(Duration(seconds: 5), (int i) =>
            TmpGlucoseData((i + 5) % 20, this, DateTime.now(), calibrationFactor)
        )
    );
  }

  @override
  void calibrate(num factor) {
    calibrationFactor = factor;
    dataStream.value.calibrate(factor);
  }

  @override
  String get id => "TMP_DATA_SRC_$_id";

  @override
  Future<void> query() async {

  }
}

class TmpGlucoseData extends GlucoseData {
  TmpDataSource source;
  DateTime time;
  int rawValue;
  num _calibrationFactor;

  TmpGlucoseData(this.rawValue, this.source, this.time, this._calibrationFactor);

  num get value => rawValue * _calibrationFactor;

  @override
  void calibrate(num factor) {
    _calibrationFactor = factor;
  }
}
// </TEST DATA>

AvocadoState state;

void main() {
  state = AvocadoState();

  var source = TmpDataSource();
  state.addDataSource(source);

  runApp(MaterialApp(
    title: 'Navigation Basics',
    //home: AlarmView(),
    home: FirstRoute(state, source),
  ));
}
