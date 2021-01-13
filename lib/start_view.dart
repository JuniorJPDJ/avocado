import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'ble_views.dart';
import 'about_route_file.dart';
import 'alarm_route_view.dart';
import 'device_route_view.dart';


class FirstRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('First Route'),
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
                  child: Text('glucoseLevel')),
            ],
          ),
        ),

        /*child: ElevatedButton(
          child: Text('Open route'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SecondRoute()),
            );
          },
        ),*/
        Container(
          child: AspectRatio(
            aspectRatio: 3 / 2,
            child: SlidingViewportOnSelection.withSampleData(),
          ),
        ),
      ]),
      drawer: Drawer(
        //child: GestureDetector(
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
                  MaterialPageRoute(builder: (context) => FlutterBlueRoute()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.alarm_sharp),
              title: Text('Alarms'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AlarmRoute()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('About'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutRoute()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.bar_chart),
              title: Text('About'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SlidingViewportOnSelection.withSampleData()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

//// bar chart actions

class SlidingViewportOnSelection extends StatelessWidget {
  final List<charts.Series> seriesList;

  final bool animate;

  SlidingViewportOnSelection(this.seriesList, {this.animate});

  /// Creates a [BarChart] with sample data and no transition.
  factory SlidingViewportOnSelection.withSampleData() {
    return new SlidingViewportOnSelection(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(children: <Widget>[
          Container(
              child: AspectRatio(
                  aspectRatio: 3 / 2,
                  child:
                  charts.LineChart(seriesList, animate: animate, behaviors: [
                    // Add the sliding viewport behavior to have the viewport center on the
                    // domain that is currently selected.
                    new charts.SlidingViewport(),
                    new charts.PanBehavior(),
                    new charts.RangeAnnotation([
                      new charts.LineAnnotationSegment(
                          20, charts.RangeAnnotationAxisType.measure,
                          startLabel: '40', color: charts.MaterialPalette.gray.shade300),
                      new charts.LineAnnotationSegment(
                          65, charts.RangeAnnotationAxisType.measure,
                          endLabel: '170', color: charts.MaterialPalette.gray.shade400),
                    ]),

                  ],
                    defaultRenderer: new charts.LineRendererConfig(includePoints: true),
                    domainAxis: new charts.NumericAxisSpec(
                      viewport: new charts.NumericExtents(2018, 2022),
                    ),
                    primaryMeasureAxis: new charts.NumericAxisSpec(
                      tickProviderSpec: new charts.StaticNumericTickProviderSpec(
                        <charts.TickSpec<num>>[
                          charts.TickSpec<num>(0),
                          charts.TickSpec<num>(100),
                        ],
                      ),
                    ),


                  )
                // Set an initial viewport to demonstrate the sliding viewport behavior on
                // initial chart load.
              ))
        ]));
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<OrdinalSales, int>> _createSampleData() {
    final data = [
      new OrdinalSales(2014, 5),
      new OrdinalSales(2015, 25),
      new OrdinalSales(2016, 100),
      new OrdinalSales(2017, 75),
      new OrdinalSales(2018, 33),
      new OrdinalSales(2019, 80),
      new OrdinalSales(2020, 21),
      new OrdinalSales(2021, 77),
      new OrdinalSales(2022, 8),
      new OrdinalSales(2023, 12),
      new OrdinalSales(2024, 42),
      new OrdinalSales(2025, 70),
      new OrdinalSales(2026, 77),
      new OrdinalSales(2027, 55),
      new OrdinalSales(2028, 19),
      new OrdinalSales(2029, 66),
      new OrdinalSales(2030, 27),
    ];

    return [
      new charts.Series<OrdinalSales, int>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: data,
      )
    ];
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final int year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}