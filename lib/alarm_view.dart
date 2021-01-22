import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';


class AlarmView extends StatelessWidget {
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
                    onPressed: () {

              },
                  child: new Text('Snooze the alarm'),
                ),
              ),
            ])
        ));
  }
}
