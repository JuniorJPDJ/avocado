// Copyright 2017, Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'TomatoBridge.dart';
import 'utils.dart';

const SCAN_DURATION = 15;

class BluetoothMainView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BluetoothState>(
      stream: FlutterBlue.instance.state,
      initialData: BluetoothState.unknown,
      builder: (c, snapshot) {
        final state = snapshot.data;
        if (state == BluetoothState.on) {
          return FindDevicesView();
        }
        return BluetoothOffView(state: state);
      },
    );
  }
}

class BluetoothOffView extends StatelessWidget {
  const BluetoothOffView({Key key, this.state}) : super(key: key);

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bluetooth is off"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
              style: Theme.of(context)
                  .primaryTextTheme
                  .subtitle1
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class ScanResultTile extends StatelessWidget {
  const ScanResultTile({Key key, this.result, this.onTap}) : super(key: key);

  final ScanResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: (result.device.name.length > 0)
            ? Text(
                result.device.name,
                overflow: TextOverflow.ellipsis,
              )
            : Text(result.device.id.toString()),
        trailing: RaisedButton(
          child: Text('CONNECT'),
          color: Colors.blue,
          textColor: Colors.white,
          onPressed: (result.advertisementData.connectable) ? onTap : null,
        ));
  }
}

class FindDevicesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Devices'),
      ),
      body: RefreshIndicator(
        onRefresh: () => FlutterBlue.instance
            .startScan(timeout: Duration(seconds: SCAN_DURATION)),
        child: SingleChildScrollView(
          child: StreamBuilder<List<ScanResult>>(
            stream: FlutterBlue.instance.scanResults,
            initialData: [],
            builder: (c, snapshot) {
              return Column(
                // TODO: filter devices to only Tomato
                children: snapshot
                    .data /*.where((r) => TomatoBridge.isTomato(r.device))*/
                    .map(
                      (r) => ScanResultTile(
                        result: r,
                        onTap: () => Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return DeviceScreen(device: r.device);
                        })),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => FlutterBlue.instance.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () => FlutterBlue.instance
                    .startScan(timeout: Duration(seconds: SCAN_DURATION)));
          }
        },
      ),
    );
  }
}

class DeviceScreen extends StatelessWidget {
  DeviceScreen({Key key, this.device}) : super(key: key);

  final BluetoothDevice device;
  TomatoBridge bridge;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(device.name),
          actions: <Widget>[
            StreamBuilder<BluetoothDeviceState>(
              stream: device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) {
                VoidCallback onPressed;
                String text;
                switch (snapshot.data) {
                  case BluetoothDeviceState.connected:
                    onPressed = () => device.disconnect();
                    text = 'DISCONNECT';
                    break;
                  case BluetoothDeviceState.disconnected:
                    onPressed = () => device.connect();
                    text = 'CONNECT';
                    break;
                  default:
                    onPressed = null;
                    text = snapshot.data.toString().substring(21).toUpperCase();
                    break;
                }
                return FlatButton(
                    onPressed: onPressed,
                    child: Text(
                      text,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .button
                          .copyWith(color: Colors.white),
                    ));
              },
            )
          ],
        ),
        body: Center(
            child: SingleChildScrollView(
                child: StreamBuilder<String>(
                    stream: (() async* {
                      try {
                        var data = StringBuffer();
                        log("initing stream!", name: "DeviceScreen");

                        bridge ??= await TomatoBridge.create(device);
                        bridge.rxPacketStream.listen((packet) {
                          data.write(parseBTPacket(packet));
                        });
                        await bridge.initSensor();

                        for (int i = 0;; ++i) {
                          await Future<void>.delayed(
                              Duration(milliseconds: 100));
                          yield "Connected ${i / 10}s ago\n${data.toString()}";
                        }
                      } on Exception catch (e) {
                        yield "Error while connecting: $e";
                      }
                    })(),
                    initialData: "Connecting",
                    builder: (context, snapshot) => Text(snapshot.data)))));
  }
}
