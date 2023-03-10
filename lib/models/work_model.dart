import 'package:cloud_firestore/cloud_firestore.dart';

class Work {
  String id;
  String client;
  String numberDN;
  String destination;
  String receivingCompany;
  String weight;
  String shippingDate;
  String deliveryDate;
  String transportationType;
  Map<String, dynamic> employees;
  Map<String, String> trucks;
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
    this.deliveryDate = "",
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
      deliveryDate: data?["deliveryDate"] ?? "",
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
      "deliveryDate": deliveryDate,
      "transportationType": transportationType,
      "employees": employees,
      "trucks": trucks,
      "status": status,
      "documentReference": documentReference,
      "reportReference": reportReference,
    };
  }
}
