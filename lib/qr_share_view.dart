import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';


class QRShareView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Share your data'),
        ),
      body: Center(
        child:QrImage(
        data: "Michasia for life",
        version: QrVersions.auto,
        size: 300.0,
          errorCorrectionLevel: QrErrorCorrectLevel.H,
      ),
      )
    );
  }
}
