import 'dart:collection';
import 'dart:developer';

import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart';

import 'Alarm.dart';
import 'GlucoseData.dart';
import 'GlucoseTest.dart';
import 'TomatoBridge.dart';

GlucoseDataSource deserializeGlucoseDataSource(String typeName, String instanceData){
  // Dart, you suck.
  // Yes. I really can't override static/factory/constructor and have to hardcode that.
  switch(typeName){
    case "TmpDataSource":
      return TmpDataSource.deserialize(instanceData);
    case "TomatoBridge":
      return TomatoBridge.deserialize(instanceData);
    default:
      return null;
  }
}

GlucoseData deserializeGlucoseData(GlucoseDataSource src, String typeName, String instanceData){
  switch(typeName){
    case "GenericCalibrableGlucoseData":
      return GenericCalibrableGlucoseData.deserialize(src, instanceData);
    default:
      return null;
  }
}

Alarm deserializeAlarm(GlucoseDataSource src, String typeName, String instanceData){
  switch(typeName){
    case "Alarm":
      return Alarm.deserialize(src, instanceData);
    default:
      return null;
  }
}

class AvocadoState {
  BehaviorSubject<Iterable<GlucoseDataSource>> sourcesUpdate;

  LinkedHashMap<GlucoseDataSource, GlucoseDataBuffer> glucoseData;
  HashMap<String, GlucoseDataSource> sourceIds;

  HashMap<Alarm, int> alarmIds;
  HashMap<GlucoseDataSource, List<Alarm>> alarms;

  String _dbName;
  Database db;

  AvocadoState(this._dbName) {
    glucoseData = LinkedHashMap();
    sourceIds = HashMap();

    alarms = HashMap();
    alarmIds = HashMap();

    sourcesUpdate = BehaviorSubject.seeded(glucoseDataSources);
  }

  Future<void> _openDb() async {
    db ??= await openDatabase(_dbName,
      onCreate: (db, version) async {
        await db.execute('''
            CREATE TABLE glucose_data_source (
              id STRING PRIMARY KEY,
              type_name STRING NOT NULL,
              instance_data STRING NOT NULL
            );
            ''');
        await db.execute('''
            CREATE TABLE glucose_data (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              source_id STRING NOT NULL,
              time INTEGER NOT NULL,
              type_name STRING NOT NULL,
              instance_data STRING NOT NULL,
              FOREIGN KEY (source_id)
              REFERENCES glucose_data_source (id)
                ON UPDATE CASCADE
                ON DELETE CASCADE
            );
            ''');

        await db.execute('''
          CREATE TABLE alarm (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            source_id STRING NOT NULL,
            type_name STRING NOT NULL,
            instance_data STRING NOT NULL,
            FOREIGN KEY (source_id)
            REFERENCES glucose_data_source (id)
              ON UPDATE CASCADE
              ON DELETE CASCADE
          )
        ''');
      },
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      version: 1
    );
  }

  Future<void> loadSourcesFromDb() async {
    await _openDb();
    var resp = await db.query("glucose_data_source",
        columns: ["type_name", "instance_data"],
    );

    for (var row in resp) {
      try {
        var gd = deserializeGlucoseDataSource(
            row['type_name'],
            row['instance_data']
        );
        if (gd != null) {

        }
      } on Exception catch (e) {
        log("error deserializing glucose data source with"
            "type ${row['type_name']} and"
            "instance data ${row['instance_data']}: $e"
        );
      }
    }
  }

  Future<Iterable<GlucoseData>> loadDataFromDb(GlucoseDataSource source) async {
    await _openDb();
    var resp = await db.query("glucose_data",
        columns: ["source_id", "time", "type_name", "instance_data"],
        where: "source_id = ? AND time >= ?",
        whereArgs: [
          source.sourceId,
          DateTime.now().subtract(Duration(hours: 24)).millisecondsSinceEpoch~/1000
        ],
        orderBy: "time"
    );

    return (() sync* {
      for (var row in resp) {
        try {
          var gd = deserializeGlucoseData(
              source,
              row['type_name'],
              row['instance_data']
          );
          if (gd != null) yield gd;
        } on Exception catch (e) {
          log("error deserializing glucose data with"
              "type ${row['type_name']} and"
              "instance data ${row['instance_data']}: $e"
          );
        }
      }
    })();
  }

  Future<Map<Alarm, int>> loadAlarmsFromDb(GlucoseDataSource source) async {
    await _openDb();
    var resp = await db.query("alarm",
        columns: ["id", "source_id", "type_name", "instance_data"],
        where: "source_id = ?",
        whereArgs: [source.sourceId]
    );

    Map<Alarm, int> ret = LinkedHashMap<Alarm, int>();

    for (var row in resp) {
      try {
        var gd = deserializeAlarm(
            source,
            row['type_name'],
            row['instance_data']
        );
        if (gd != null) ret[gd] = row['id'];
      } on Exception catch (e) {
        log("error deserializing alarm with"
            "type ${row['type_name']} and"
            "instance data ${row['instance_data']}: $e"
        );
      }
    }

    return ret;
  }

  Future<void> saveDataToDb(GlucoseData data) async {
    await _openDb();

    var map = {
      "source_id": data.source.sourceId,
      "time": data.time.millisecondsSinceEpoch~/1000,
      "type_name": data.typeName,
      "instance_data": data.instanceData
    };

    log("inserting $map");
    await db.insert("glucose_data", map);
  }

  Future<void> addDataSource(GlucoseDataSource source) async {
    await _openDb();
    if(glucoseData.containsKey(source)) throw StateError("Data source is already registered");

    sourceIds[source.sourceId] = source;
    var buf = glucoseData[source] = GlucoseDataBuffer();

    source.dataStream.listen((data) => addMeasurement(source, data));

    // if null - not inserted, already exists, need to load data
    if(await db.insert('glucose_data_source', {
      'id': source.sourceId,
      'type_name': source.typeName,
      'instance_data': source.instanceData
    }, conflictAlgorithm: ConflictAlgorithm.ignore) == null) {
      buf.addAll(await loadDataFromDb(source));

      Map<Alarm, int> dbAlarms = await loadAlarmsFromDb(source);
      alarms[source] = dbAlarms.keys.toList();
      alarms[source].forEach((alarm) => alarm.updatesStream.listen(_handleAlarmUpdate));
      alarmIds.addAll(dbAlarms);
    }

    sourcesUpdate.add(glucoseDataSources);
  }

  Future<void> addAlarm(Alarm alarm) async {
    await _openDb();

    if(alarmIds.containsKey(alarm)) throw StateError("Alarm is already registered");

    int id = await db.insert('alarm', {
      'source_id': alarm.source.sourceId,
      'type_name': alarm.typeName,
      'instance_data': alarm.instanceData
    });

    alarmIds[alarm] = id;
    alarms[alarm.source].add(alarm);

    alarm.updatesStream.listen(_handleAlarmUpdate);
  }

  void _handleAlarmUpdate(Alarm alarm) async {
    await _openDb();

    await db.update('alarm', {
          'instance_data': alarm.instanceData
        },
        where: "id = ?",
        whereArgs: [alarmIds[alarm]]);
  }

  Iterable<GlucoseDataSource> get glucoseDataSources => glucoseData.keys;

  void addMeasurement(GlucoseDataSource source, GlucoseData data) {
    // TODO: try to run alarm if new enough
    saveDataToDb(data);
    glucoseData[source].add(data);
  }

  // TODO: try to load data sources from DB
}