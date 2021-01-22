import 'package:rxdart/rxdart.dart';

import 'GlucoseData.dart';
import 'utils.dart';

class Alarm implements StringSerializable {
  GlucoseDataSource source;
  String _name;

  num _value;
  bool _greater;
  DateTime _snoozedTo;

  bool _enabled;

  BehaviorSubject<Alarm> updatesStream;

  Alarm(this.source, this._name, this._value, this._greater,
      [this._enabled = true, this._snoozedTo]) {
    updatesStream = BehaviorSubject.seeded(this);
  }

  String get name => _name;

  set name(String v) {
    _name = v;
    updatesStream.add(this);
  }

  num get value => _value;

  set value(num v) {
    _value = v;
    updatesStream.add(this);
  }

  bool get greater => _greater;

  set greater(bool v) {
    _greater = v;
    updatesStream.add(this);
  }

  void snooze(DateTime to) {
    _snoozedTo = to;
    updatesStream.add(this);
  }

  void unsnooze() {
    _snoozedTo = null;
    updatesStream.add(this);
  }

  DateTime get snoozedTo => _snoozedTo;

  bool get enabled => _enabled;

  set enabled(bool v) {
    _enabled = v;
    updatesStream.add(this);
  }

  String get instanceData =>
      "${source.sourceId}|$name|$value|$greater|$enabled|$snoozedTo";

  final String typeName = "Alarm";

  factory Alarm.deserialize(GlucoseDataSource src, String instanceData) {
    var data = instanceData.split("|");
    return Alarm(src, data[1], num.parse(data[2]), data[3] == "true",
        data[4] == "true", data[5] == "null" ? null : DateTime.parse(data[5]));
  }
}
