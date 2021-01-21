import 'package:flutter/material.dart';

class EditAlarm extends StatelessWidget {
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Edit Alert"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(children: <Widget>[
          Container(
            child: TextField(
              decoration: InputDecoration(hintText: 'Alarm Name'),
            ),
          ),
          Container(
            child: TextField(
              decoration: InputDecoration(hintText: 'Sugar Value'),
            ),
          ),
          Container(
              //TODO: sth with snoozing the button;
              ),
        ]));
  }
}
