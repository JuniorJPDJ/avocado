import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Alarm.dart';
import 'AvocadoState.dart';
import 'GlucoseData.dart';

// TODO: handle back button and ask if really want to cancel edit
// TODO: high/low mode selection
// TODO: save changes

class AlarmEditView extends StatefulWidget {
  final AvocadoState state;
  final Alarm alarm;
  final GlucoseDataSource dataSource;

  AlarmEditView(this.state, this.alarm, [dataSource])
      : this.dataSource = alarm == null ? dataSource : alarm.source {
    if (this.dataSource == null) throw StateError("No datasource specified");
  }

  @override
  AlarmEditViewState createState() =>
      AlarmEditViewState(state, alarm, dataSource);
}

class AlarmEditViewState extends State<AlarmEditView> {
  final AvocadoState state;
  final Alarm alarm;
  final GlucoseDataSource dataSource;

  TextEditingController name;
  TextEditingController value;
  bool greater;
  DateTime snoozedTo;
  bool enabled;

  AlarmEditViewState(this.state, this.alarm, this.dataSource) {
    name = TextEditingController(text: alarm?.name);
    value = TextEditingController(text: alarm?.value?.toString());
    greater = alarm?.greater ?? true;
    snoozedTo = alarm?.snoozedTo;
    enabled = alarm?.enabled ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: alarm == null
              ? Text("${dataSource.sourceId}: Create alarm")
              : Text("Edit alarm ${alarm.name}"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            tooltip: 'Cancel changes',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: <Widget>[
            Switch(
              value: enabled,
              activeColor: Colors.white,
              inactiveTrackColor: Colors.white24,
              activeTrackColor: Colors.white60,
              inactiveThumbColor: Colors.blue[300],
              onChanged: (v) => setState(() => enabled = v),
            ),
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'Save changes',
              onPressed: () {},
            )
          ],
        ),
        body: Column(children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 15),
            child: TextField(
              controller: name,
              decoration: InputDecoration(hintText: 'Alarm name'),
            ),
          ),
          Container(
            child: TextField(
              controller: value,
              decoration:
                  InputDecoration(hintText: 'Sugar value triggering alarm'),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
            ),
          ),
          Container(
            child: StreamBuilder<void>(
              stream: Stream.periodic(Duration(milliseconds: 200)),
              builder: (context, snapshot) => snoozedTo == null ||
                      DateTime.now().isAfter(snoozedTo)
                  ? Text('Not snoozed!')
                  : Text(
                      'Snoozed for: ${snoozedTo.difference(DateTime.now())}'),
            ),
          ),
          Container(
              child: Center(
                  child: ButtonBar(children: <Widget>[
            ElevatedButton(
                onPressed: () => snooze(15),
                child: new Text('snooze for\n15 min')),
            ElevatedButton(
                onPressed: () => snooze(30),
                child: new Text('snooze for\n30 min')),
            ElevatedButton(
                onPressed: () => snooze(45),
                child: new Text('snooze for\n45 min')),
            ElevatedButton(
                onPressed: () => setState(() => snoozedTo = null),
                child: new Text('disable\nsnooze'))
          ]))),
          Container(
              child: ToggleButtons(onPressed: null, children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Higher'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Lower'),
            ),
          ]))
        ]));
  }

  void snooze(int minutes) => setState(
      () => snoozedTo = DateTime.now().add(Duration(minutes: minutes)));
}
