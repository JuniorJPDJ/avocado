import 'package:flutter/material.dart';

import 'AvocadoState.dart';
import 'GlucoseTest.dart';
import 'bt_views.dart';
import 'main_drawer.dart';
import 'qr_reader_view.dart';

class ConnectSourceView extends StatelessWidget {
  final AvocadoState state;

  ConnectSourceView(this.state);

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
                MaterialPageRoute(builder: (context) => BluetoothMainView()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.cloud_download_outlined),
            title: Text('Connect to the cloud'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QRReaderView()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.sensor_door),
            title: Text('Add debug data source'),
            onTap: () async {
              state.addDataSource(TmpDataSource());
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
