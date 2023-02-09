import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rue_app/auth/auth_utils.dart';
import 'package:rue_app/config/const.dart';
import 'package:rue_app/controllers/attendance_controller.dart';
import 'package:rue_app/models/employee_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

var db = FirebaseFirestore.instance;

Future<String> createEmployee({
  required String email,
  required String password,
  required String fullName,
  required String phoneNumber,
  required String position,
}) async {
  try {
    Map<String, dynamic> registration =
        await AuthService().registration(email: email, password: password);
    if (registration["message"] == "success") {
      String uid = registration["object"];
      Employee employee = Employee(
        uid: uid,
        fullName: fullName,
        phoneNumber: phoneNumber,
        position: position,
        email: email,
        status: employeeAvailable,
      );
      db.collection("employees").doc(uid).set(employee.toFirestore());
      return "success";
    } else {
      return registration["message"];
    }
  } on Exception catch (e) {
    return e.toString();
  }
}

Future<Map<String, dynamic>> getLoggedInEmployee() async {
  try {
    var firebaseUser = FirebaseAuth.instance.currentUser;
    final ref = db.collection("employees").doc(firebaseUser!.uid).withConverter(
          fromFirestore: Employee.fromFirestore,
          toFirestore: (Employee userModel, _) => userModel.toFirestore(),
        );
    var docSnap = await ref.get();
    final userModel = docSnap.data();
    Map<String, dynamic> attendanceResult =
        await checkTodayAttendanceByUid(userModel!.uid);
    if (attendanceResult["message"] == "success") {
      userModel.checkInStatus = attendanceResult["object"];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('uid', userModel.uid);
      await prefs.setBool('isAdmin', userModel.position == "MANAGER");
      return {"message": "success", "object": userModel};
    } else {
      return {"message": attendanceResult["message"]};
    }
  } on Exception catch (e) {
    return {"message": e.toString()};
  }
}

Future<Map<String, dynamic>> getAllEmployeesWithTodayAttendance() async {
  try {
    final ref = db.collection("employees").withConverter(
          fromFirestore: Employee.fromFirestore,
          toFirestore: (Employee userModel, _) => userModel.toFirestore(),
        );
    List<Employee> listEmployees = [];
    final docSnap = await ref.get();
    for (var element in docSnap.docs) {
      var temp = element.data();
      var attendanceResult = await checkTodayAttendanceByUid(temp.uid);
      if (attendanceResult["message"] == "success") {
        temp.checkInStatus = attendanceResult["object"];
      } else {
        return {"message": attendanceResult["message"]};
      }
      listEmployees.add(temp);
    }
    return {"message": "success", "object": listEmployees};
  } on Exception catch (e) {
    return {"message": e.toString()};
  }
}

Future<Map<String, dynamic>> getEmployeeByUid(String uid) async {
  try {
    Employee? employee;

    final ref = db.collection("employees").doc(uid).withConverter(
          fromFirestore: Employee.fromFirestore,
          toFirestore: (Employee employee, _) => employee.toFirestore(),
        );
    var docSnap = await ref.get();
    employee = docSnap.data();

    var attendanceResult = await checkTodayAttendanceByUid(employee!.uid);
    if (attendanceResult["message"] == "success") {
      employee.checkInStatus = attendanceResult["object"];
      return {"message": "success", "object": employee};
    } else {
      return {"message": attendanceResult["message"]};
    }
  } on Exception catch (e) {
    return {"message": e.toString()};
  }
}

Future<Map<String, dynamic>> getAllEmployeesForDriver() async {
  try {
    final ref = db
        .collection("employees")
        .where("position", isEqualTo: positionStaffOperation)
        .where("status", isEqualTo: employeeAvailable)
        .withConverter(
          fromFirestore: Employee.fromFirestore,
          toFirestore: (Employee userModel, _) => userModel.toFirestore(),
        );
    List<Employee> listEmployees = [];
    final docSnap = await ref.get();
    for (var element in docSnap.docs) {
      listEmployees.add(element.data());
    }
    return {
      "message": "success",
      "object": listEmployees,
    };
  } on Exception catch (e) {
    return {"message": e.toString()};
  }
}

Future<String> updateEmployeeStatus(
    {required String uid, required String status}) async {
  try {
    await db.collection("employees").doc(uid).update({"status": status});
    return "success";
  } on Exception catch (e) {
    return e.toString();
  }
}

Future<String> deleteEmployeeByUid(String uid) async {
  try {
    await db.collection("employees").doc(uid).delete();
    return 'success';
  } on Exception catch (e) {
    return e.toString();
  }
}
