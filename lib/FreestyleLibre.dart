import 'dart:typed_data';
import 'dart:math';

const FREESTYLELIBRE_PACKET_LENGTH = 344;

// TODO: verify packet CRC
// TODO: validate patch info

enum FreeStyleLibreSensorStatus {
  unknown,
  notYetStarted,
  starting,
  ready,          // status for 14 days and 12 h of normal operation, libre reader quits after 14 days
  expired,        // status of the following 12 h, sensor delivers last BG reading constantly
  shutdown,       // sensor stops operation after 15d after start
  inFailure,
}

class FreestyleLibreGlucoseData {
  FreestyleLibrePacket packet;
  int index;
  bool historical;

  FreestyleLibreGlucoseData(this.packet, this.index, {this.historical = false});

  int get _i {
    // ring buffer index
    var i = (historical ? packet._indexHistory : packet._indexTrend) - index - 1;
    if (i < 0) i += historical ? 32 : 16;
    return i;
  }

  int get glucoseReading {
    var offset = historical ? 124 : 28;

    return (packet._data[_i * 6 + offset] | packet._data[_i * 6 + offset + 1] << 8) & 0x1FFF;
  }

  int get sensorTime =>
    max(0, historical ?
      ((packet.sensorAge - 3) ~/ 15 - index) * 15
        :
      packet.sensorAge - index
    );

  DateTime get time => packet.sensorFirstUse.add(Duration(minutes: sensorTime));
}

class FreestyleLibrePacket {
  Uint8List _data;
  DateTime readDate;

  FreestyleLibrePacket(this._data, {DateTime readDate}){
    readDate ??= DateTime.now();
    this.readDate = DateTime(readDate.year, readDate.month, readDate.day, readDate.hour, readDate.minute);
  }

  FreeStyleLibreSensorStatus get status =>
    _data[4] < FreeStyleLibreSensorStatus.values.length ? FreeStyleLibreSensorStatus.values[_data[4]] : FreeStyleLibreSensorStatus.unknown;

  bool get sensorReady =>
      [FreeStyleLibreSensorStatus.starting, FreeStyleLibreSensorStatus.ready].contains(status);

  int get _indexHistory => _data[27];

  int get _indexTrend => _data[26];

  // in minutes
  int get sensorAge => _data[317] << 8 | _data[316];

  DateTime get sensorFirstUse {
    var d = readDate.subtract(Duration(minutes: sensorAge));
    // d.second = 0;
    // d.millisecond = 0;
    // d.microsecond = 0;
    return d;
  }

  Iterable<FreestyleLibreGlucoseData> iterHistory() sync* {
    // loads history values (ring buffer, starting at _indexHistory. byte 124-315)
    // history are readings in 15 minutes interval
    // most recent value corresponds to (sensorAge - 3) % 15 + 3 ago (thanks @dspnikder)
    for(var index = 0; index < 32; index++)
      yield FreestyleLibreGlucoseData(this, index, historical: true);
  }

  Iterable<FreestyleLibreGlucoseData> iterTrend() sync* {
    // loads trend values (ring buffer, starting at _indexTrend. byte 28-123)
    // trend values are readings in 1 minute interval
    // most recent value corresponds to sensorAge timing
    for(var index = 0; index < 16; index++)
      yield FreestyleLibreGlucoseData(this, index);
  }
}

class FreestyleLibre {
  // NFCInterface _nfcInterface;

  // FreestyleLibre(NFCInterface nfcInterface) {
  //   _nfcInterface = nfcInterface;
  // }
}
