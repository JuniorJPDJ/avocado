import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'AvocadoState.dart';
import 'GlucoseData.dart';
import 'bt_views.dart';
import 'about_view.dart';
import 'alarm_list_view.dart';
import 'device_route_view.dart';

class FirstRoute extends StatelessWidget {
  final GlucoseDataSource dataSource;
  final AvocadoState state;

  FirstRoute(this.state, this.dataSource);

  Widget _buildPopupDialog(BuildContext context) {
    return new AlertDialog(
      title: const Text('Please calibrate'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Blood sugar level"),
          TextField(
            decoration: InputDecoration(hintText: 'mg/dL'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          textColor: Theme.of(context).primaryColor,
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Avocado care'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.auto_fix_high),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => _buildPopupDialog(context),
                );
              },
          )
        ],
      ),
      body: ListView(children: <Widget>[
        Container(
          child: Stack(
            children: <Widget>[
              Container(
                  margin: const EdgeInsets.all(10.0),
                  color: Colors.blueAccent[600],
                  width: 48.0,
                  height: 48.0,
                  child: StreamBuilder<GlucoseData>(
                    stream: state.glucoseData[dataSource].updatesStream
                        .map((buf) => buf.last),
                    builder: (context, snapshot) =>
                        Text("${snapshot.data?.value ?? "N/A"}"),
                  )),
            ],
          ),
        ),
        Container(
          child: AspectRatio(
              aspectRatio: 3 / 2,
              // child: GlucoseDataChart.fromBuffer(state.glucoseData[dataSource])
              child: StreamBuilder<GlucoseDataBuffer>(
                stream: state.glucoseData[dataSource].updatesStream,
                initialData: state.glucoseData[dataSource],
                builder: (context, snapshot) => GlucoseDataChart.fromBuffer(snapshot.data),
              )
          ),
        ),
        Container(
          child: Row(
            children: <Widget>[
              Icon(Icons.battery_std),
              Text('Miao battery')
            ],
          )

        ),
      ]),
      drawer: Drawer(
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
              leading: Icon(Icons.bluetooth_connected),
              title: Text('Bluetooth Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BluetoothMainView()),
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
              /*
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SlidingViewportOnSelection.withSampleData()),
                );
              },
             */
            ),
          ],
        ),
      ),
    );
  }
}

class GlucoseDataChart extends StatelessWidget {
  final List<charts.Series<GlucoseData, DateTime>> seriesList;

  final bool animate;

  GlucoseDataChart(this.seriesList, {this.animate = false});

  factory GlucoseDataChart.fromBuffer(GlucoseDataBuffer buff) {
    return new GlucoseDataChart([
      new charts.Series<GlucoseData, DateTime>(
        id: 'Glucose',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (GlucoseData d, _) => d.time,
        measureFn: (GlucoseData d, _) => d.value,
        data: buff,
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      behaviors: [
        // Add the sliding viewport behavior to have the viewport center on the
        // domain that is currently selected.
        new charts.SlidingViewport(),
        new charts.PanBehavior(),
        new charts.RangeAnnotation([
          new charts.LineAnnotationSegment(
              70, charts.RangeAnnotationAxisType.measure,
              startLabel: '70', color: charts.MaterialPalette.gray.shade300),
          new charts.LineAnnotationSegment(
              140, charts.RangeAnnotationAxisType.measure,
              endLabel: '140', color: charts.MaterialPalette.gray.shade400),
        ]),
      ],
      defaultRenderer: new charts.LineRendererConfig(includePoints: true),
      /* domainAxis: new charts.DateTimeAxisSpec(
        viewport: new charts.DateTimeExtents(
          // TODO: odpowiedni zakres?
            start: DateTime(2018), end: DateTime(2022)),
      ), */
      primaryMeasureAxis: new charts.NumericAxisSpec(
        tickProviderSpec: new charts.StaticNumericTickProviderSpec(
          <charts.TickSpec<num>>[
            charts.TickSpec<num>(0),
            charts.TickSpec<num>(100),
          ],
        ),
      ),
    );
  }
}
