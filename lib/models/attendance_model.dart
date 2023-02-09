import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AttendanceModel {
  final String uid;
  final String fullName;
  final DateTime checkIn;

  AttendanceModel({
    required this.uid,
    required this.fullName,
    required this.checkIn,
  });
  factory AttendanceModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return AttendanceModel(
      uid: data?["uid"],
      fullName: data?["fullName"],
      checkIn: DateTime.parse(data?["checkIn"]),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "uid": uid,
      "fullName": fullName,
      "checkIn": checkIn.toString(),
    };
  }

  @override
  String toString() {
    return "$fullName at ${DateFormat.Hms().format(checkIn)}";
  }
}
