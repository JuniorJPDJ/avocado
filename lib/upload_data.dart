import 'package:avocado/GlucoseData.dart';
import 'package:http/http.dart' as http;

const CLOUD_SERVER_BASE_URL = "https://avocado.juniorjpdj.pl/";

String url(url) => CLOUD_SERVER_BASE_URL + url;

Future<void> upload_data(GlucoseData data, String password) async {
  // TODO: encrypt data with ed25519
  // TODO: hash data with sha256
  // TODO: queue for errored data
  var encryptedData = data.instanceData;
  var sourceKey = "rotfl";

  await http.post(url('add_measurement'), body: {
    'pw': password,
    'ts': '${data.time.millisecondsSinceEpoch ~/ 1000}',
    'data': encryptedData,
    'set': sourceKey
  });
}
