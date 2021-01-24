import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Alarm.dart';
import 'AvocadoState.dart';
import 'GlucoseData.dart';

// TODO: handle back button and ask if really want to cancel edit

Widget buildDeleteAlarmDialog(
    AvocadoState state, BuildContext context, Alarm alarm) {
  return new AlertDialog(
    title: Text('Are you sure you want to delete alarm "${alarm.name}"?'),
    content: new Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
    ),
    actions: <Widget>[
      new FlatButton(
        onPressed: () {
          Navigator.of(context).pop();
          state.removeAlarm(alarm);
        },
        textColor: Theme.of(context).primaryColor,
        child: const Text('Delete'),
      ),
      new FlatButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        textColor: Theme.of(context).primaryColor,
        child: const Text('Cancel'),
      ),
    ],
  );
}

class AlarmEditView extends StatefulWidget {
  final AvocadoState state;
  final Alarm alarm;
  final GlucoseDataSource dataSource;

  AlarmEditView(this.state, this.alarm, [GlucoseDataSource dataSource])
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
              onPressed: () async {
                if (alarm == null)
                  await state.addAlarm(Alarm(dataSource, name.text,
                      num.parse(value.text), greater, enabled, snoozedTo));
                else
                  alarm.edit(name.text, num.parse(value.text), greater, enabled,
                      snoozedTo);
                Navigator.pop(context);
              },
            )
          ],
        ),
        body: Center(
            child: Column(children: <Widget>[
          Container(
            margin: const EdgeInsets.all(10.0),
            child: TextField(
              controller: name,
              decoration: InputDecoration(hintText: 'Alarm name'),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10.0),
            child: TextField(
              controller: value,
              decoration: InputDecoration(hintText: 'Sugar value'),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10.0),
            child: StreamBuilder<void>(
              stream: Stream.periodic(Duration(milliseconds: 200)),
              builder: (_, __) => snoozedTo == null ||
                      DateTime.now().isAfter(snoozedTo)
                  ? Text('Not snoozed!')
                  : Text(
                      'Snoozed for: ${snoozedTo.difference(DateTime.now())}'),
            ),
          ),
          Container(
              child: Align(
                  alignment: Alignment.topCenter,
                  child: Row(children: [
                    //const Spacer(),
                    ButtonBar(children: <Widget>[
                      ElevatedButton(
                          onPressed: () => _snooze(15),
                          child: new Text('snooze for\n15 min',
                              style: TextStyle(fontSize: 10))),
                      ElevatedButton(
                          onPressed: () => _snooze(30),
                          child: new Text('snooze for\n30 min',
                              style: TextStyle(fontSize: 10))),
                      ElevatedButton(
                          onPressed: () => _snooze(45),
                          child: new Text('snooze for\n45 min',
                              style: TextStyle(fontSize: 10))),
                      ElevatedButton(
                          onPressed: () => setState(() => snoozedTo = null),
                          child: new Text('disable\nsnooze',
                              style: TextStyle(fontSize: 10)))
                    ])
                  ]))),
          Container(
              child: ToggleButtons(
                  onPressed: (i) => setState(() => greater = i == 0),
                  isSelected: greater ? [true, false] : [false, true],
                  children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Higher'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Lower'),
                ),
              ]))
        ])));
  }

  void _snooze(int minutes) => setState(
      () => snoozedTo = DateTime.now().add(Duration(minutes: minutes)));
}
