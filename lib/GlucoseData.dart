abstract class GlucoseData {
  double get value;
  DateTime get time;
  GlucoseDataSource get source;
  void calibrate(num factor);
}

abstract class GlucoseDataSource {
  String get id;
  Stream<GlucoseData> get dataStream;
  void calibrate(num factor);
  Future<void> query();
}
