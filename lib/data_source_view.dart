import 'dart:developer';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

import 'AvocadoState.dart';
import 'GlucoseData.dart';
import 'alarm_list_view.dart';
import 'main_drawer.dart';
import 'qr_share_view.dart';

// TODO: delete source

class DataSourceView extends StatelessWidget {
  final GlucoseDataSource dataSource;
  final AvocadoState state;

  DataSourceView(this.state, this.dataSource);

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

  Widget _buildPopupDialogDelete(BuildContext context) {
    return new AlertDialog(
      title: const Text('Are you sure you want to delete this view?'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
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
          title: Text('${dataSource.sourceId}: Overview'),
          actions: <Widget>[
            PopupMenuButton(
              onSelected: (v) => v(),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          _buildPopupDialog(context),
                    );
                  },
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.auto_fix_high, color: Colors.blue),
                      Text('  Calibration'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              AlarmListView(state, dataSource)),
                    );
                  },
                  child: Row(
                        children: <Widget>[
                          Icon(Icons.alarm, color: Colors.blue),
                          Text('  Alarm'),
                        ],
                      ),
                ),
                PopupMenuItem(
                  value: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          _buildPopupDialogDelete(context),
                    );
                  },
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.delete_outline, color: Colors.blue),
                      Text('  Delete View'),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
        body: ListView(children: <Widget>[
          Container(
            margin: const EdgeInsets.all(10.0),
            color: Colors.blueAccent[600],
            width: 48.0,
            height: 48.0,
            child: StreamBuilder<GlucoseData>(
              stream: state.glucoseData[dataSource].updatesStream
                  .map((buf) => buf.last),
              builder: (context, snapshot) => Center(
                child: Text(
                  "${snapshot.data?.value ?? "N/A"}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
          ),
          Container(
            child: AspectRatio(
                aspectRatio: 3 / 2,
                // child: GlucoseDataChart.fromBuffer(state.glucoseData[dataSource])
                child: StreamBuilder<GlucoseDataBuffer>(
                  stream: state.glucoseData[dataSource].updatesStream,
                  initialData: state.glucoseData[dataSource],
                  builder: (context, snapshot) =>
                      GlucoseDataChart.fromBuffer(snapshot.data),
                )),
          ),
          Container(
              margin: const EdgeInsets.only(top: 20.0, left: 20),
              child: Row(
                children: <Widget>[
                  if (dataSource is BatteryPowered) ...[
                    Icon(Icons.battery_std, color: Colors.blue),
                    Text(
                        'Battery: ${(dataSource as BatteryPowered).batteryLevel}')
                  ],
                ],
              )),
          Container(
              margin: const EdgeInsets.only(top: 20.0, left: 20),
              child: Row(children: <Widget>[
                if (dataSource is Lifetimable) ...[
                  Icon(Icons.calendar_today, color: Colors.blue),
                  Text(
                      'Sensor remaining lifetime: ${(dataSource as Lifetimable).remainingLifeTime}')
                ]
              ])),
          Container(
              margin: const EdgeInsets.only(right: 100, left: 100, top: 50),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QRShareView()),
                  );
                },
                child: Text(
                  'Share your data',
                ),
              ))
        ]),
        drawer: MainDrawer(state));
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
              endLabel: '140', color: charts.MaterialPalette.gray.shade300),
        ]),
      ],
      defaultRenderer: new charts.LineRendererConfig(includePoints: true),
      domainAxis: new charts.DateTimeAxisSpec(
        viewport: new charts.DateTimeExtents(
            // TODO: odpowiedni zakres?
            start: DateTime.now().subtract(Duration(minutes: 5)),
            end: DateTime.now().add(Duration(minutes: 1))),
      ),
      primaryMeasureAxis: new charts.NumericAxisSpec(
        tickProviderSpec: new charts.StaticNumericTickProviderSpec(
          <charts.TickSpec<num>>[
            charts.TickSpec<num>(0),
            charts.TickSpec<num>(300),
          ],
        ),
      ),
    );
  }
}
