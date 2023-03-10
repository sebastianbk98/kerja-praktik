import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:rue_app/controllers/attendance_controller.dart';
import 'package:rue_app/screens/home_screen.dart';
import 'package:rue_app/widget.dart';

class QrScanner extends StatelessWidget {
  const QrScanner({
    Key? key,
    required this.uid,
    required this.fullName,
    required this.id,
  }) : super(key: key);
  final String uid;
  final String fullName;
  final String id;
  @override
  Widget build(BuildContext context) {
    return Title(
      color: Colors.blue,
      title: "Scan QR Code",
      child: Scaffold(
        appBar: AppBar(title: const Text('Check In')),
        body: MobileScanner(
          allowDuplicates: false,
          onDetect: (barcode, args) {
            final String? code = barcode.rawValue;
            String url = id.isEmpty
                ? "Rianinda Utama Ekspress //Check In"
                : "Rianinda Utama Ekspress //Check Out";
            if (code != url) {
              showAlertDialog(context, "Error", "Wrong QR Code");
            } else if (id.isEmpty) {
              checkInAttendance(uid, fullName).then((String value) {
                if (value == "success") {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                      (route) => false);
                } else {
                  showAlertDialog(context, "Error", value);
                }
              });
            } else {
              checkOutAttendance(id).then((String value) {
                if (value == "success") {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                      (route) => false);
                } else {
                  showAlertDialog(context, "Error", value);
                }
              });
            }
          },
        ),
      ),
    );
  }
}
