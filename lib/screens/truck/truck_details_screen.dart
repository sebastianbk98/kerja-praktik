import 'package:flutter/material.dart';
import 'package:rue_app/config/const.dart';
import 'package:rue_app/config/theme.dart';
import 'package:rue_app/screens/truck/edit_truck_screen.dart';
import 'package:rue_app/models/truck_model.dart';
import 'package:rue_app/controllers/truck_controller.dart';

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
    return Container(
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
                        // crossAxisAlignment: CrossAxisAlignment.start,
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
                            style: textTheme(context).displaySmall,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: adaptiveConv(context, 25),
                      ),
                      Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: truck.status != truckWorking
                              ? Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditTruckPage(
                                              truck: truck,
                                            ),
                                          ),
                                        );
                                        setState(() {});
                                      },
                                      child: const Text("Edit"),
                                    ),
                                    SizedBox(
                                      width: adaptiveConv(context, 15),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
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
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(value),
                                              ),
                                            );
                                          }
                                        });
                                      },
                                      child: Text(truck.status == truckAvailable
                                          ? "Unavailable"
                                          : "Available"),
                                    ),
                                    SizedBox(
                                      width: adaptiveConv(context, 15),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        deleteTruckByID(id).then((value) {
                                          if (value == "success") {
                                            Navigator.pop(context);
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(value),
                                              ),
                                            );
                                          }
                                        });
                                      },
                                      child: const Text("Delete"),
                                    ),
                                  ],
                                )
                              : Container(),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Center(
                  child: Text(data?["message"]),
                );
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        )),
      ),
    );
  }
}
