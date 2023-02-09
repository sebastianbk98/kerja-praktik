import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:rue_app/controllers/attendance_controller.dart';
import 'package:rue_app/screens/home_screen.dart';

class QrScanner extends StatelessWidget {
  const QrScanner({
    Key? key,
    required this.uid,
    required this.fullName,
  }) : super(key: key);
  final String uid;
  final String fullName;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check In')),
      body: MobileScanner(
        allowDuplicates: false,
        onDetect: (barcode, args) {
          final String? code = barcode.rawValue;
          if (code == "Rianinda Utama Ekspress //Check In") {
            // String result =
            checkInAttendance(uid, fullName).then((String value) {
              if (value == "success") {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Check In success"),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(value),
                  ),
                );
              }
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false);
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Wrong QR Code"),
              ),
            );
          }
        },
      ),
    );
  }
}
