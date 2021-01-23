import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'Alarm.dart';
import 'AvocadoState.dart';
import 'GlucoseData.dart';
import 'alarm_edit_view.dart';

class AlarmListView extends StatelessWidget {
  final AvocadoState state;
  final GlucoseDataSource dataSource;

  AlarmListView(this.state, this.dataSource);

  Widget _buildDeleteDialog(BuildContext context, Alarm alarm) {
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
        body: StreamBuilder<void>(
            stream: Stream.periodic(Duration(milliseconds: 200)),
            builder: (_, __) => ListView(
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
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        _buildDeleteDialog(context, alarm),
                                  );
                                },
                              ),
                            ],
                          ))
                      .toList(),
                )));
  }
}
