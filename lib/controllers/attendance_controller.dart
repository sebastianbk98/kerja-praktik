import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rue_app/models/attendance_model.dart';

var db = FirebaseFirestore.instance;

Future<String> checkInAttendance(String uid, String fullName) async {
  try {
    DateTime now = DateTime.now();
    AttendanceModel checkIn = AttendanceModel(
      uid: uid,
      fullName: fullName,
      checkIn: now,
    );
    await db.collection("attendances").add(checkIn.toFirestore());
    return "success";
  } on Exception catch (e) {
    return e.toString();
  }
}

Future<Map<String, dynamic>> checkTodayAttendanceByUid(String uid) async {
  DateTime now = DateTime.now();
  DateTime start = DateTime(now.year, now.month, now.day, 0, 0);
  DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59);
  try {
    var ref = await db
        .collection("attendances")
        .where("uid", isEqualTo: uid)
        .where('checkIn',
            isGreaterThanOrEqualTo: start.toString(),
            isLessThanOrEqualTo: end.toString())
        .withConverter(
          fromFirestore: AttendanceModel.fromFirestore,
          toFirestore: (AttendanceModel attendanceModel, _) =>
              attendanceModel.toFirestore(),
        )
        .get();
    if (ref.docs.isEmpty) {
      return {
        "message": "success",
        "object": false,
      };
    } else {
      return {
        "message": "success",
        "object": true,
      };
    }
  } on Exception catch (e) {
    return {"message": e.toString()};
  }
}

Future<Map<DateTime, List<AttendanceModel>>> getAttendanceRecordByUid(
    String uid) async {
  final ref = await db
      .collection("attendances")
      .where("uid", isEqualTo: uid)
      .withConverter(
        fromFirestore: AttendanceModel.fromFirestore,
        toFirestore: (AttendanceModel attendanceModel, _) =>
            attendanceModel.toFirestore(),
      )
      .get();
  Map<DateTime, List<AttendanceModel>> map = {};
  for (var element in ref.docs) {
    var data = element.data();
    map[data.checkIn] = [data];
  }

  return map;
}
