import 'package:flutter/material.dart';

import 'AvocadoState.dart';
import 'GlucoseTest.dart';
import 'bt_views.dart';
import 'data_source_view.dart';
import 'main_drawer.dart';
import 'qr_reader_view.dart';

class ConnectSourceView extends StatelessWidget {
  final AvocadoState state;

  ConnectSourceView(this.state, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(state),
      appBar: AppBar(
        title: Text("Connect new data source"),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.bluetooth_connected),
            title: Text('Connect your MiaoMiao'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BluetoothMainView(state)),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.cloud_download_outlined),
            title: Text('Connect to the cloud'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QRReaderView(state)),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.sensor_door),
            title: Text('Add test data source'),
            onTap: () async {
              var src = TestDataSource();
              state.addDataSource(src);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DataSourceView(state, src)));
            },
          ),
        ],
      ),
    );
  }
}
