import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rue_app/config/const.dart';
import 'package:rue_app/models/truck_model.dart';

var db = FirebaseFirestore.instance;

Future<String?> createTruck({
  required String name,
  required String licenseNumber,
  required String capacity,
}) async {
  try {
    var temp = await db.collection("trucks").add({});
    Truck truckModel = Truck(
      id: temp.id,
      name: name,
      licenseNumber: licenseNumber,
      capacity: capacity,
      status: truckAvailable,
    );
    await temp.set(truckModel.toFirestore());
    return "success";
  } on Exception catch (e) {
    return e.toString();
  }
}

Future<String?> editTruck({
  required String id,
  required String name,
  required String licenseNumber,
  required String capacity,
}) async {
  try {
    await db.collection("trucks").doc(id).update({
      "name": name,
      "licenseNumber": licenseNumber,
      "capacity": capacity,
    });
    return "success";
  } on Exception catch (e) {
    return e.toString();
  }
}

Future<Map<String, dynamic>> getTruckByID({required String id}) async {
  try {
    final ref = await db
        .collection("trucks")
        .doc(id)
        .withConverter(
          fromFirestore: Truck.fromFirestore,
          toFirestore: (Truck truckModel, _) => truckModel.toFirestore(),
        )
        .get();
    return {"message": "success", "object": ref.data()};
  } on Exception catch (e) {
    return {"message": e.toString()};
  }
}

Future<Map<String, dynamic>> getAllTruckModel() async {
  try {
    List<Truck> list = [];
    final ref = await db
        .collection("trucks")
        .orderBy("status")
        .orderBy("name")
        .withConverter(
          fromFirestore: Truck.fromFirestore,
          toFirestore: (Truck truckModel, _) => truckModel.toFirestore(),
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

Future<Map<String, dynamic>> getAllAvailableTruck() async {
  try {
    List<Truck> list = [];
    final ref = await db
        .collection("trucks")
        .where("status", isEqualTo: truckAvailable)
        .withConverter(
          fromFirestore: Truck.fromFirestore,
          toFirestore: (Truck truckModel, _) => truckModel.toFirestore(),
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

Future<String> updateTruckStatus(
    {required String id, required String status}) async {
  try {
    await db.collection("trucks").doc(id).update({"status": status});
    return "success";
  } on Exception catch (e) {
    return e.toString();
  }
}

Future<String> deleteTruckByID(String id) async {
  try {
    await db.collection("trucks").doc(id).delete();
    return 'success';
  } on Exception catch (e) {
    return e.toString();
  }
}
