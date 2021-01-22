import 'package:flutter/material.dart';
import 'qr_view.dart';
import 'bt_views.dart';

class ConnectSourceView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Data source"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: ListView(children: <Widget>[
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
                      MaterialPageRoute(builder: (context) => QRView()),
                    );
                  },
                ),
              ],
          ),
    );
  }
}
