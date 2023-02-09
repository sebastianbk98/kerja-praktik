import 'package:cloud_firestore/cloud_firestore.dart';

class Employee {
  final String uid;
  final String fullName;
  final String phoneNumber;
  final String position;
  final String email;
  final String status;
  bool checkInStatus;

  Employee({
    required this.uid,
    required this.fullName,
    required this.phoneNumber,
    required this.position,
    required this.email,
    required this.status,
    this.checkInStatus = false,
  });
  factory Employee.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Employee(
      uid: data?["uid"],
      fullName: data?["fullName"],
      phoneNumber: data?["phoneNumber"],
      position: data?["position"],
      email: data?["email"],
      status: data?["status"],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "uid": uid,
      "fullName": fullName,
      "phoneNumber": phoneNumber,
      "position": position,
      "email": email,
      "status": status,
    };
  }
}
