import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

import 'AvocadoState.dart';
import 'GlucoseData.dart';
import 'alarm_list_view.dart';
import 'connect_source_view.dart';
import 'main_drawer.dart';
import 'qr_share_view.dart';
import 'utils.dart';

class DataSourceView extends StatelessWidget {
  final GlucoseDataSource dataSource;
  final AvocadoState state;

  DataSourceView(this.state, this.dataSource, {Key key}) : super(key: key);

  Widget _buildCalibrationDialog(BuildContext context) {
    var cont = TextEditingController();

    return new AlertDialog(
      title: const Text('Enter current glucose level for calibration'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Blood sugar level"),
          TextField(
            controller: cont,
            decoration: InputDecoration(hintText: 'mg/dL'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            (dataSource as CalibrableGlucoseDataSource)
                .calibrateByLast(num.parse(cont.text));
            state.glucoseData[dataSource].updatesStream.add(null);
            Navigator.of(context).pop();
          },
          textColor: Theme.of(context).primaryColor,
          child: const Text('Save'),
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

  Widget _buildDeleteDialog(BuildContext context) {
    return new AlertDialog(
      title: const Text(
          'Are you sure you want to remove this data source?\nAll related data will be deleted!'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await state.removeDataSource(dataSource);
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => ConnectSourceView(state)));
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
                if (dataSource is CalibrableGlucoseDataSource)
                  PopupMenuItem(
                    value: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            _buildCalibrationDialog(context),
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
                          _buildDeleteDialog(context),
                    );
                  },
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.delete_outline, color: Colors.blue),
                      // I cried. XDDDDD
                      Text('  Delete source'),
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
            child: StreamBuilder<void>(
              stream: state.glucoseData[dataSource].updatesStream,
              builder: (context, snapshot) => Center(
                child: Text(
                  "${nullOnException(() => state.glucoseData[dataSource].last)?.value?.toInt() ?? "N/A"}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
          ),
          Container(
            child: AspectRatio(
                aspectRatio: 3 / 2,
                // child: GlucoseDataChart.fromBuffer(state.glucoseData[dataSource])
                child: StreamBuilder<void>(
                  stream: state.glucoseData[dataSource].updatesStream,
                  builder: (context, snapshot) => GlucoseDataChart.fromBuffer(
                      state.glucoseData[dataSource]),
                )),
          ),
          if (dataSource is BatteryPowered)
            Container(
                margin: const EdgeInsets.only(top: 20.0, left: 20),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.battery_std, color: Colors.blue),
                    Text(
                        'Battery: ${(dataSource as BatteryPowered).batteryLevel}')
                  ],
                )),
          if (dataSource is Lifetimable)
            Container(
                margin: const EdgeInsets.only(top: 20.0, left: 20),
                child: Row(children: <Widget>[
                  Icon(Icons.calendar_today, color: Colors.blue),
                  Text(
                      'Sensor remaining lifetime: ${(dataSource as Lifetimable).remainingLifeTime.inDays} days')
                ])),
          if (dataSource is Sharable)
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
  // TODO: change this chart lib
  final List<charts.Series<GlucoseData, DateTime>> seriesList;

  final bool animate;

  GlucoseDataChart(this.seriesList, {this.animate = false, Key key})
      : super(key: key);

  factory GlucoseDataChart.fromBuffer(GlucoseDataBuffer buff, {Key key}) {
    return new GlucoseDataChart([
      new charts.Series<GlucoseData, DateTime>(
        id: 'Glucose',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (GlucoseData d, _) => d.time,
        measureFn: (GlucoseData d, _) => d.value,
        data: buff,
      )
    ], key: key);
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
