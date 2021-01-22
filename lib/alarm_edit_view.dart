import 'package:flutter/material.dart';

class AlarmEditView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Edit Alert"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            tooltip: 'Cancel changes',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: <Widget>[
            Switch(
              value: true,
              activeColor: Colors.white,
              inactiveTrackColor: Colors.white24,
              activeTrackColor: Colors.white60,
              inactiveThumbColor: Colors.blue[300],
              onChanged: (v){},
            ),
            IconButton(
              icon: const Icon(Icons.check),
            tooltip: 'Save changes',
              onPressed: () {
              },
            )
          ],
        ),
        body: Column(children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 15),
            child: TextField(
              decoration: InputDecoration(hintText: 'Alarm Name'),
            ),
          ),
          Container(
            child: TextField(
              decoration: InputDecoration(hintText: 'Sugar Value'),
                keyboardType: TextInputType.number,
            ),
          ),
          Container(
            child: Text('Snoozed for: '),
          ),
          Container(
            child: Center(
             child: ButtonBar(
                 children: <Widget>[
                   ElevatedButton(onPressed: null, child: new Text('15 min')),
                   ElevatedButton(onPressed: null, child: new Text('30 min')),
                   ElevatedButton(onPressed: null, child: new Text('45 min')),
                   ElevatedButton(onPressed: null, child: new Text('off'))
                 ]
             )
            )
          ),
        ]));
  }
}
