import 'package:rxdart/rxdart.dart';

import 'GlucoseData.dart';

class TmpDataSource
    with CalibrableGlucoseDataSourceMixin
    implements
        CalibrableGlucoseDataSource,
        BatteryPowered,
        Lifetimable,
        Sharable {
  static int tmpId = 0;

  int _id;
  int i;
  num calibrationFactor;
  BehaviorSubject<GenericCalibrableGlucoseData> dataStream;

  TmpDataSource([this.i = 5, this.calibrationFactor = 10]) {
    _setup();
  }

  void _setup() {
    _id = tmpId++;
    dataStream = BehaviorSubject();

    dataStream.addStream(Stream.periodic(
        Duration(seconds: 5),
        (_) => GenericCalibrableGlucoseData(
            i++ % 20, calibrationFactor, DateTime.now(), this)));
  }

  @override
  String get sourceId => "TMP_DATA_SRC_$_id";

  @override
  String get instanceData => "$i|$calibrationFactor";

  @override
  final String typeName = "TmpDataSource";

  @override
  TmpDataSource.deserialize(String instanceData) {
    var data = instanceData.split("|");

    i = int.parse(data[0]);
    calibrationFactor = num.parse(data[1]);

    _setup();
  }

  @override
  num get batteryLevel => 69;

  @override
  Duration get remainingLifeTime => Duration(days: 3, hours: 2, minutes: 1);
}
