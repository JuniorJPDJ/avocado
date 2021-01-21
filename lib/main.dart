import 'package:flutter/material.dart';
import 'AvocadoState.dart';
import 'package:pretty_things/alarm_view.dart';
import 'GlucoseTest.dart';
import 'start_view.dart';


AvocadoState state;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  state = AvocadoState('avocado.sqlite');

  var source = TmpDataSource();
  await state.addDataSource(source);

  runApp(MaterialApp(
    title: 'Navigation Basics',
    home: FirstRoute(state, source),
    //home: AlarmView(),
  ));
}
