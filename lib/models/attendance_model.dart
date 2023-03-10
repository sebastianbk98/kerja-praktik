import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String uid;
  final String fullName;
  final String date;
  final String checkInTime;
  final String checkOutTime;

  AttendanceModel({
    required this.uid,
    required this.fullName,
    required this.date,
    required this.checkInTime,
    required this.checkOutTime,
  });
  factory AttendanceModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    return AttendanceModel(
      uid: data?["uid"],
      fullName: data?["fullName"],
      date: data?["date"],
      checkInTime: data?["checkInTime"],
      checkOutTime: data?["checkOutTime"],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "uid": uid,
      "fullName": fullName,
      "date": date,
      "checkInTime": checkInTime,
      "checkOutTime": checkOutTime,
    };
  }

  @override
  String toString() {
    return "$fullName\nCheck In at $checkInTime${checkOutTime.isEmpty ? "" : "\nCheck Out at $checkOutTime"}";
  }
}
