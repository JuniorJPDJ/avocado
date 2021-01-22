import 'package:flutter/material.dart';

import 'connect_source_view.dart';
import 'about_view.dart';
import 'alarm_list_view.dart';
import 'device_route_view.dart';

class MainDrawer extends StatelessWidget {

  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Drawer Header',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle_sharp),
            title: const Text('Your Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DeviceRoute()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.connect_without_contact),
            title: Text('Connect new data source'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ConnectSourceView()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.alarm_sharp),
            title: Text('Alarms'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AlarmListView()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('About'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutView()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.bar_chart),
            title: Text('About'),
          ),
        ],
      ),
    );
  }
}