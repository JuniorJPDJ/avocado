import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import 'Alarm.dart';
import 'AvocadoState.dart';
import 'GlucoseData.dart';

class AlarmView extends StatefulWidget {
  final AvocadoState state;
  final Alarm alarm;
  final GlucoseData data;

  AlarmView(this.state, AlarmTrigger trigger)
      : alarm = trigger.alarm,
        data = trigger.data;

  AlarmViewState createState() => AlarmViewState(state, alarm, data);
}

class AlarmViewState extends State<AlarmView> {
  AvocadoState state;
  Alarm alarm;
  GlucoseData data;

  AlarmViewState(this.state, this.alarm, this.data);

  @override
  Widget build(BuildContext context) {
    FlutterRingtonePlayer.playAlarm();

    return Scaffold(
        backgroundColor: Colors.white,
        //white bc the whole app is white for now, ok?
        body: Center(
            child: Column(children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 250.0),
            child: Icon(Icons.alarm_on, size: 100),
          ),
          Container(
            margin: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () => state.alarmAppears.add(null),
              child: new Text('Snooze the alarm'),
            ),
          ),
        ])));
  }

  @override
  void dispose() {
    FlutterRingtonePlayer.stop();

    super.dispose();
  }
}
