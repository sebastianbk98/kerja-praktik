import 'package:flutter/material.dart';
import 'package:rue_app/config/const.dart';
import 'package:rue_app/config/theme.dart';
import 'package:rue_app/screens/truck/edit_truck_screen.dart';
import 'package:rue_app/models/truck_model.dart';
import 'package:rue_app/controllers/truck_controller.dart';
import 'package:rue_app/widget.dart';

class TruckDetailPage extends StatefulWidget {
  const TruckDetailPage({super.key, required this.id});
  final String id;

  @override
  State<TruckDetailPage> createState() => _TruckDetailPageState();
}

class _TruckDetailPageState extends State<TruckDetailPage> {
  @override
  Widget build(BuildContext context) {
    String id = widget.id;
    return Title(
      color: Colors.blue,
      title: "Truck Details",
      child: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/rianindautamaekspress.jpg"),
              fit: BoxFit.cover),
        ),
        child: Scaffold(
          backgroundColor: Colors.white.withOpacity(0.9),
          appBar: AppBar(
            title: const Text("Truck Detail"),
          ),
          body: SafeArea(
              child: FutureBuilder(
            future: getTruckByID(id: id),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Map<String, dynamic>? data = snapshot.data;
                if (data?["message"] == "success") {
                  Truck truck = data?["object"];
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(
                              "Truck Name",
                              style: textTheme(context).labelMedium,
                            ),
                            Text(
                              truck.name,
                              style: textTheme(context).displaySmall,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "License Number",
                              style: textTheme(context).labelMedium,
                            ),
                            Text(
                              truck.licenseNumber,
                              style: textTheme(context).displaySmall,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "Max. Capacity",
                              style: textTheme(context).labelMedium,
                            ),
                            Text(
                              truck.capacity,
                              style: textTheme(context).displaySmall,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "Status",
                              style: textTheme(context).labelMedium,
                            ),
                            Text(
                              truck.status,
                              style: textTheme(context).displaySmall?.copyWith(
                                  backgroundColor:
                                      truck.status == truckAvailable
                                          ? Colors.green
                                          : truck.status == truckWorking
                                              ? Colors.yellow
                                              : Colors.red),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: adaptiveConv(context, 25),
                        ),
                        truck.status != truckWorking
                            ? Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditTruckPage(
                                                truck: truck,
                                              ),
                                            ),
                                          ).then((value) {
                                            setState(() {});
                                          });
                                        },
                                        child: const Text("Edit"),
                                      ),
                                      SizedBox(
                                        width: adaptiveConv(context, 15),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text("Confirm"),
                                                content:
                                                    const Text("Are you sure?"),
                                                actions: [
                                                  ElevatedButton(
                                                    child: const Text("No"),
                                                    onPressed: () {
                                                      Navigator.pop(
                                                          context, false);
                                                    },
                                                  ),
                                                  ElevatedButton(
                                                    child: const Text("Yes"),
                                                    onPressed: () {
                                                      Navigator.pop(
                                                          context, true);
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          ).then((value) {
                                            if (value != null && value) {
                                              String status =
                                                  truck.status == truckAvailable
                                                      ? truckUnavailable
                                                      : truckAvailable;
                                              updateTruckStatus(
                                                      id: id, status: status)
                                                  .then((value) {
                                                if (value == "success") {
                                                  setState(() {});
                                                } else {
                                                  showAlertDialog(
                                                      context, "Error", value);
                                                }
                                              });
                                            }
                                          });
                                        },
                                        child: Text(
                                            truck.status == truckAvailable
                                                ? "Unavailable"
                                                : "Available"),
                                      ),
                                      SizedBox(
                                        width: adaptiveConv(context, 15),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text("Confirm"),
                                                content:
                                                    const Text("Are you sure?"),
                                                actions: [
                                                  ElevatedButton(
                                                    child: const Text("No"),
                                                    onPressed: () {
                                                      Navigator.pop(
                                                          context, false);
                                                    },
                                                  ),
                                                  ElevatedButton(
                                                    child: const Text("Yes"),
                                                    onPressed: () {
                                                      Navigator.pop(
                                                          context, true);
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          ).then((value) {
                                            if (value != null && value) {
                                              deleteTruckByID(id).then((value) {
                                                if (value == "success") {
                                                  Navigator.pop(context);
                                                } else {
                                                  showAlertDialog(
                                                      context, "Error", value);
                                                }
                                              });
                                            }
                                          });
                                        },
                                        child: const Text("Delete"),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  );
                } else {
                  showAlertDialog(context, "Error", data?["message"]);
                  Navigator.pop(context);
                  return Container();
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          )),
        ),
      ),
    );
  }
}
