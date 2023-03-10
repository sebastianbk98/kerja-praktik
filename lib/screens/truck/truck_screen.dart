import 'package:flutter/material.dart';
import 'package:rue_app/config/const.dart';
import 'package:rue_app/config/theme.dart';
import 'package:rue_app/screens/truck/add_truck_screen.dart';
import 'package:rue_app/screens/truck/truck_details_screen.dart';
import 'package:rue_app/models/truck_model.dart';
import 'package:rue_app/controllers/truck_controller.dart';
import 'package:rue_app/widget.dart';

class TruckPage extends StatefulWidget {
  const TruckPage({super.key});

  @override
  State<TruckPage> createState() => _TruckPageState();
}

class _TruckPageState extends State<TruckPage> {
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  List<Truck> searchList = [];
  @override
  Widget build(BuildContext context) {
    return Title(
      color: Colors.blue,
      title: "Trucks",
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
            title: const Text("Trucks"),
            actions: [
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: ((context) => const AddTruckPage())),
                  ).then((_) {
                    setState(() {});
                  });
                },
                icon: const Icon(Icons.fire_truck),
                label: const Text("Add New Truck"),
              ),
            ],
          ),
          body: SafeArea(
            child: FutureBuilder(
              future: getAllTruckModel(),
              builder: ((context, snapshot) {
                if (snapshot.hasData) {
                  Map<String, dynamic>? data = snapshot.data;
                  if (data?["message"] == "success") {
                    List<Truck> trucks = data?["object"];
                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: adaptiveConv(context, 8),
                              horizontal: adaptiveConv(context, 50)),
                          child: TextFormField(
                            controller: searchController,
                            decoration: InputDecoration(
                              label: const Text("Search Truck By Name"),
                              filled: true,
                              hintText: 'Truck Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onChanged: (value) {
                              if (value.isEmpty) {
                                setState(() {
                                  isSearching = false;
                                });
                              } else {
                                isSearching = true;
                                searchList = [];
                                for (Truck temp in trucks) {
                                  if (temp.name.toLowerCase().contains(
                                      searchController.text.toLowerCase())) {
                                    searchList.add(temp);
                                  }
                                }
                                setState(() {});
                              }
                            },
                            validator: ((value) {
                              if (value == null || value.isEmpty) {
                                return "Employee Name is required";
                              }
                              return null;
                            }),
                          ),
                        ),
                        Expanded(
                          child: ListView.separated(
                            padding: generalPadding(context),
                            separatorBuilder: (context, index) => Divider(
                              thickness: adaptiveConv(context, 3),
                              indent: adaptiveConv(context, 5),
                            ),
                            itemCount:
                                isSearching ? searchList.length : trucks.length,
                            itemBuilder: (BuildContext context, int index) {
                              Truck truckData = isSearching
                                  ? searchList[index]
                                  : trucks[index];
                              return ListTile(
                                leading: const Icon(Icons.fire_truck),
                                title: Text(truckData.name),
                                subtitle: Text(truckData.licenseNumber),
                                trailing: Text(
                                  truckData.status,
                                  style: TextStyle(
                                      backgroundColor:
                                          truckData.status == truckAvailable
                                              ? Colors.green
                                              : truckData.status == truckWorking
                                                  ? Colors.yellow
                                                  : Colors.red),
                                ),
                                onTap: (() async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: ((context) =>
                                          TruckDetailPage(id: truckData.id)),
                                    ),
                                  );
                                  setState(() {});
                                }),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  } else {
                    showAlertDialog(context, "Error", data?["message"]);
                    return Container();
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
            ),
          ),
        ),
      ),
    );
  }
}
