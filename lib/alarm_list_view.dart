import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'Alarm.dart';
import 'AvocadoState.dart';
import 'GlucoseData.dart';
import 'alarm_edit_view.dart';

class AlarmListView extends StatelessWidget {
  final AvocadoState state;
  final GlucoseDataSource dataSource;

  AlarmListView(this.state, this.dataSource) {
    // TODO: <test>
    Alarm alarm = Alarm(dataSource, "TEST 1", 40, false);
    state.addAlarm(alarm);
    // </test>
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("${dataSource.sourceId}: Alarms"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.add_alert),
              tooltip: 'Add alarm',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AlarmEditView(state, null, dataSource)),
                );
              },
            ),
          ],
        ),
        body: ListView(
          children: state.alarms[dataSource]
              .map((Alarm alarm) => Slidable(
                    actionPane: SlidableDrawerActionPane(),
                    actionExtentRatio: 0.25,
                    child: Container(
                      color: Colors.white,
                      child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.indigoAccent,
                            child: Text('${alarm.value}'),
                            foregroundColor: Colors.white,
                          ),
                          title: Text(alarm.name),
                          subtitle: Text('SlidableDrawerDelegate'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      AlarmEditView(state, alarm)),
                            );
                          }),
                    ),
                    secondaryActions: <Widget>[
                      IconSlideAction(
                        caption: 'Edit',
                        color: Colors.black45,
                        icon: Icons.more_horiz,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AlarmEditView(state, alarm)),
                          );
                        },
                      ),
                      IconSlideAction(
                        caption: 'Delete',
                        color: Colors.red,
                        icon: Icons.delete,
                        onTap: () => {
                          // TODO: delete alarm
                        },
                      ),
                    ],
                  ))
              .toList(),
        ));
  }
}
