import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  TextEditingController name;
  TextEditingController surname;
  TextEditingController myPhone;
  TextEditingController mainDoctor;
  TextEditingController mainDoctorNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Avocado safety card"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: ListView(children: <Widget>[
          Container(
            child: null,
          ),
          Container(
            margin: const EdgeInsets.all(10.0),
            child: TextField(
              controller: name,
              decoration: InputDecoration(hintText: 'your name'),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10.0),
            child: TextField(
              controller: surname,
              decoration: InputDecoration(hintText: 'your surname'),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10.0),
            child: TextField(
              controller: myPhone,
              decoration: InputDecoration(hintText: 'phone number'),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10.0),
            child: TextField(
              controller: mainDoctor,
              decoration: InputDecoration(hintText: 'main doctor'),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10.0),
            child: TextField(
              controller: mainDoctorNumber,
              decoration: InputDecoration(hintText: 'main doctor number'),
            ),
          ),
        ]));
  }
}
