import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rue_app/models/attendance_model.dart';

var db = FirebaseFirestore.instance;

Future<String> checkInAttendance(String uid, String fullName) async {
  try {
    List<String> now = DateTime.now().toString().split(" ");
    String date = now[0];
    String time = now[1];
    AttendanceModel checkIn = AttendanceModel(
        uid: uid,
        fullName: fullName,
        date: date,
        checkInTime: time,
        checkOutTime: "");
    await db.collection("attendances").add(checkIn.toFirestore());
    return "success";
  } on Exception catch (e) {
    return e.toString();
  }
}

Future<String> checkOutAttendance(String id) async {
  try {
    String now = DateTime.now().toString().split(" ")[1];
    await db
        .collection("attendances")
        .doc(id)
        .update({"checkOutTime": now.toString()});
    return "success";
  } on Exception catch (e) {
    return e.toString();
  }
}

Future<Map<String, dynamic>> checkTodayAttendanceByUid(String uid) async {
  String now = DateTime.now().toString().split(" ")[0];
  try {
    var ref = await db
        .collection("attendances")
        .where("uid", isEqualTo: uid)
        .where('date', isEqualTo: now)
        .where("checkOutTime", isEqualTo: "")
        .withConverter(
          fromFirestore: AttendanceModel.fromFirestore,
          toFirestore: (AttendanceModel attendanceModel, _) =>
              attendanceModel.toFirestore(),
        )
        .get();
    if (ref.docs.isEmpty) {
      return {
        "message": "success",
        "object": "",
      };
    } else {
      return {
        "message": "success",
        "object": ref.docs.first.id,
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
    List<AttendanceModel> temp = map[DateTime.parse(data.date)] ?? [];
    temp.add(data);
    map[DateTime.parse(data.date)] = temp;
  }

  return map;
}

Future<List<AttendanceModel>> getAttendanceRecordsWithDate(
    String firstDate, String lastDate) async {
  final ref = await db
      .collection("attendances")
      .where("date",
          isGreaterThanOrEqualTo: firstDate, isLessThanOrEqualTo: lastDate)
      .withConverter(
        fromFirestore: AttendanceModel.fromFirestore,
        toFirestore: (AttendanceModel attendanceModel, _) =>
            attendanceModel.toFirestore(),
      )
      .get();

  List<AttendanceModel> list = [];
  for (var element in ref.docs) {
    var data = element.data();
    list.add(data);
  }

  return list;
}
