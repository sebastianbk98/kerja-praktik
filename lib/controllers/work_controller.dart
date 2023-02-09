import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:rue_app/config/const.dart';
import 'package:rue_app/config/firebase_storage_utils.dart';
import 'package:rue_app/controllers/employee_controller.dart';
import 'package:rue_app/controllers/truck_controller.dart';
import 'package:rue_app/models/work_model.dart';

var db = FirebaseFirestore.instance;

Future<String?> createWork({
  required Work work,
  required Uint8List? file,
}) async {
  try {
    for (String key in work.employees.keys) {
      String result =
          await updateEmployeeStatus(uid: key, status: employeeRequested);
      if (result != "success") return result;
    }
    for (String key in work.trucks.keys) {
      String result = await updateTruckStatus(id: key, status: truckWorking);
      if (result != "success") return result;
    }
    var temp = await db.collection("works").add({});
    work.id = temp.id;
    String fileReference = "${temp.id}/${work.documentReference}";
    var upload = {};
    if (file != null) {
      upload = await StorageServices()
          .uploadFile(fileReference, file, "application/pdf");
    }

    if (upload["message"] != "success") {
      return upload["message"];
    } else {
      work.documentReference = upload["object"];
      await temp.set(work.toFirestore());

      return "success";
    }
  } on Exception catch (e) {
    return e.toString();
  }
}

Future<String?> editWork({required Work work}) async {
  try {
    await db.collection("works").doc(work.id).set(work.toFirestore());
    return "success";
  } on Exception catch (e) {
    return e.toString();
  }
}

Future<Map<String, dynamic>> getWorkByID({required String id}) async {
  try {
    final ref = await db
        .collection("works")
        .doc(id)
        .withConverter(
          fromFirestore: Work.fromFirestore,
          toFirestore: (Work work, _) => work.toFirestore(),
        )
        .get();
    return {"message": "success", "object": ref.data()};
  } on Exception catch (e) {
    return {"message": e.toString()};
  }
}

Future<Map<String, dynamic>> getAllOngoingWorks() async {
  try {
    List<Work> list = [];
    final ref = await db
        .collection("works")
        .where("status", whereIn: [
          workRequestEmployee,
          workInProgress,
          workDoneConfirmation,
        ])
        .withConverter(
          fromFirestore: Work.fromFirestore,
          toFirestore: (Work work, _) => work.toFirestore(),
        )
        .get();
    for (var element in ref.docs) {
      list.add(element.data());
    }
    return {"message": "success", "object": list};
  } on Exception catch (e) {
    return {"message": e.toString()};
  }
}

Future<Map<String, dynamic>> getAllWorksHistory() async {
  try {
    List<Work> list = [];
    final ref = await db
        .collection("works")
        .where("status", whereNotIn: [
          workRequestEmployee,
          workInProgress,
          workDoneConfirmation,
        ])
        .withConverter(
          fromFirestore: Work.fromFirestore,
          toFirestore: (Work work, _) => work.toFirestore(),
        )
        .get();
    for (var element in ref.docs) {
      list.add(element.data());
    }
    return {"message": "success", "object": list};
  } on Exception catch (e) {
    return {"message": e.toString()};
  }
}

Future<String> updateDriverStatus(
    {required String id, required String uid, required String status}) async {
  try {
    var result = await getWorkByID(id: id);
    if (result["message"] != "success") {
      return result["message"];
    }
    Work work = result["object"];
    work.employees[uid][1] = status;
    if (status == "ACCEPTED") {
      bool ready = true;
      String employeeUpdate =
          await updateEmployeeStatus(uid: uid, status: employeeWorking);
      if (employeeUpdate != "success") return employeeUpdate;
      for (List<dynamic> employee in work.employees.values) {
        if (employee[1] != "ACCEPTED") {
          ready = false;
          break;
        }
      }
      if (ready) work.status = workInProgress;
    } else {
      String employeesUpdate = await updateAllEmployeesAvailable(id: id);
      if (employeesUpdate != "success") return employeesUpdate;

      String trucksUpdate = await updateAllTrucksAvailable(id: id);
      if (trucksUpdate != "success") return trucksUpdate;
      work.status = workEmployeeReject;
    }
    await db.collection("works").doc(id).set(work.toFirestore());
    return "success";
  } on Exception catch (e) {
    return e.toString();
  }
}

Future<String> updateWorkStatus({
  required String id,
  required String status,
}) async {
  try {
    var result = await getWorkByID(id: id);
    if (result["message"] != "success") {
      return result["message"];
    }
    Work work = result["object"];
    if ([
      workCancel,
      workFailed,
      workDone,
      workEmployeeReject,
    ].contains(status)) {
      String employeesUpdate = await updateAllEmployeesAvailable(id: id);
      if (employeesUpdate != "success") return employeesUpdate;

      String trucksUpdate = await updateAllTrucksAvailable(id: id);
      if (trucksUpdate != "success") return trucksUpdate;
    }
    work.status = status;
    await db.collection("works").doc(id).set(work.toFirestore());
    return "success";
  } on Exception catch (e) {
    return e.toString();
  }
}

Future<String> updateAllEmployeesAvailable({required String id}) async {
  try {
    var result = await getWorkByID(id: id);
    if (result["message"] != "success") {
      return result["message"];
    }
    Work work = result["object"];
    for (String uid in work.employees.keys) {
      String employeeUpdate =
          await updateEmployeeStatus(uid: uid, status: employeeAvailable);
      if (employeeUpdate != "success") return employeeUpdate;
    }
    return "success";
  } on Exception catch (e) {
    return e.toString();
  }
}

Future<String> updateAllTrucksAvailable({required String id}) async {
  try {
    var result = await getWorkByID(id: id);
    if (result["message"] != "success") {
      return result["message"];
    }
    Work work = result["object"];
    for (String id in work.trucks.keys) {
      String truckUpdate =
          await updateTruckStatus(id: id, status: truckAvailable);
      if (truckUpdate != "success") return truckUpdate;
    }
    return "success";
  } on Exception catch (e) {
    return e.toString();
  }
}

Future<String> uploadReport({
  required Work work,
  required List<String> references,
  required List<Uint8List> files,
}) async {
  try {
    var upload =
        await StorageServices().uploadFiles(references, files, "image/*");
    if (upload["message"] != "success") return upload["message"];
    work.reportReference = upload["object"];
    work.status = workDoneConfirmation;
    await db.collection("works").doc(work.id).set(work.toFirestore());
    return "success";
  } on Exception catch (e) {
    return e.toString();
  }
}
