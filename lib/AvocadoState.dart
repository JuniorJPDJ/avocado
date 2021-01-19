import 'dart:collection';

import 'package:rxdart/rxdart.dart';

import 'GlucoseData.dart';

class AvocadoState {
  BehaviorSubject<Iterable<GlucoseDataSource>> sourcesUpdate;

  LinkedHashMap<GlucoseDataSource, GlucoseDataBuffer> glucoseData;

  AvocadoState() {
    glucoseData = LinkedHashMap();
    sourcesUpdate = BehaviorSubject.seeded(glucoseDataSources);
  }

  void addDataSource(GlucoseDataSource source){
    // TODO: fill from db if data available
    if(glucoseData.containsKey(source)) throw StateError("Data source is already registered");
    source.dataStream.listen((data) => addMeasurement(source, data));
    glucoseData[source] = GlucoseDataBuffer();
    sourcesUpdate.add(glucoseDataSources);
  }

  Iterable<GlucoseDataSource> get glucoseDataSources => glucoseData.keys;

  void addMeasurement(GlucoseDataSource source, GlucoseData data){
    // TODO: save to db if necessary
    glucoseData[source].add(data);
  }
}