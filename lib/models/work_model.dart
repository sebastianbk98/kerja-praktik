import 'package:cloud_firestore/cloud_firestore.dart';

class Work {
  String id;
  final String client;
  final String numberDN;
  final String destination;
  final String receivingCompany;
  final String weight;
  final String shippingDate;
  final String transportationType;
  final Map<String, dynamic> employees;
  final Map<String, String> trucks;
  String status;
  String documentReference;
  List<String> reportReference;

  Work({
    this.id = "",
    required this.client,
    required this.numberDN,
    required this.destination,
    required this.receivingCompany,
    required this.weight,
    required this.shippingDate,
    required this.transportationType,
    required this.employees,
    required this.trucks,
    required this.status,
    required this.documentReference,
    required this.reportReference,
  });
  factory Work.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    Map<String, dynamic> employees = Map.from(data?["employees"] ?? {});
    Map<String, String> trucks = Map.from(data?["trucks"] ?? {});
    List<String> reportReference = List.from(data?["reportReference"] ?? []);
    return Work(
      id: data?["id"],
      client: data?["client"],
      numberDN: data?["numberDN"],
      destination: data?["destination"],
      receivingCompany: data?["receivingCompany"],
      weight: data?["weight"],
      shippingDate: data?["shippingDate"],
      transportationType: data?["transportationType"],
      employees: employees,
      trucks: trucks,
      status: data?["status"],
      documentReference: data?["documentReference"],
      reportReference: reportReference,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "id": id,
      "client": client,
      "numberDN": numberDN,
      "destination": destination,
      "receivingCompany": receivingCompany,
      "weight": weight,
      "shippingDate": shippingDate,
      "transportationType": transportationType,
      "employees": employees,
      "trucks": trucks,
      "status": status,
      "documentReference": documentReference,
      "reportReference": reportReference,
    };
  }
}
