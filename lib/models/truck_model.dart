import 'package:cloud_firestore/cloud_firestore.dart';

class Truck {
  final String id;
  final String name;
  final String licenseNumber;
  final String capacity;
  final String status;

  Truck({
    required this.id,
    required this.name,
    required this.licenseNumber,
    required this.capacity,
    required this.status,
  });
  factory Truck.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Truck(
      id: data?["id"],
      name: data?["name"],
      licenseNumber: data?["licenseNumber"],
      capacity: data?["capacity"],
      status: data?["status"],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "id": id,
      "name": name,
      "licenseNumber": licenseNumber,
      "capacity": capacity,
      "status": status,
    };
  }
}
