import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

import 'AvocadoState.dart';
import 'connect_source_view.dart';
import 'data_source_view.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AvocadoState state = AvocadoState('avocado.sqlite');

  await state.loadSourcesFromDb();

  if(state.glucoseData.length > 0)
    state.glucoseDataSources.first.dataStream.listen((value) {FlutterAppBadger.updateBadgeCount(value.value.toInt());});


  runApp(MaterialApp(
    title: 'Navigation Basics',
    //home: DataSourceView(state, source),
    home: state.glucoseData.length > 0
        ? DataSourceView(state, state.glucoseDataSources.first)
        : ConnectSourceView(state),
  ));
}
