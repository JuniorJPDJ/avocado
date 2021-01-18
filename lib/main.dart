import 'package:flutter/material.dart';
import 'GlucoseData.dart';
import 'start_view.dart';


class AvocadoStore {
  List<GlucoseDataSource> sources;

  AvocadoStore() {
    sources = [];
  }
}

AvocadoStore store;

void main() {
  store = AvocadoStore();
  runApp(MaterialApp(
    title: 'Navigation Basics',
    home: FirstRoute(),
  ));
}
