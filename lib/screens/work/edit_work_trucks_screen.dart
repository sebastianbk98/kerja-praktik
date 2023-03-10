import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rue_app/config/theme.dart';
import 'package:rue_app/controllers/truck_controller.dart';
import 'package:rue_app/models/truck_model.dart';
import 'package:rue_app/models/work_model.dart';
import 'package:rue_app/screens/work/edit_work_driver_screen.dart';
import 'package:rue_app/widget.dart';

class EditWorkTrucksPage extends StatefulWidget {
  const EditWorkTrucksPage({super.key, required this.work, required this.file});
  final Work work;
  final Uint8List? file;

  @override
  State<EditWorkTrucksPage> createState() => _EditWorkTrucksPageState();
}

class _EditWorkTrucksPageState extends State<EditWorkTrucksPage> {
  Map<String, String> oldTruckMap = {};
  Map<String, String> truckMap = {};
  @override
  Widget build(BuildContext context) {
    Work work = widget.work;

    for (String id in work.trucks.keys) {
      oldTruckMap[id] = work.trucks[id] ?? "";
    }
    return Title(
      color: Colors.blue,
      title: "Choose Truck(s)",
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
            title: const Text("Select Trucks"),
          ),
          body: SafeArea(
            child: FutureBuilder(
              future: getAllAvailableTruck(),
              builder: ((context, snapshot) {
                if (snapshot.hasData) {
                  Map<String, dynamic>? data = snapshot.data;
                  if (data?["message"] == "success") {
                    List<Truck> trucks = data?["object"];

                    for (String id in work.trucks.keys) {
                      truckMap[id] = work.trucks[id] ?? "";
                    }
                    for (Truck truck in trucks) {
                      truckMap[truck.id] =
                          "${truck.name}_${truck.licenseNumber}";
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text("${work.trucks.length} selected"),
                            ElevatedButton(
                              onPressed: work.trucks.isEmpty
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditWorkDriversPage(
                                            truckMap: oldTruckMap,
                                            work: work,
                                            file: widget.file,
                                          ),
                                        ),
                                      );
                                    },
                              child: const Text("Select Drivers"),
                            ),
                          ],
                        ),
                        Expanded(
                          child: ListView.separated(
                            padding: generalPadding(context),
                            separatorBuilder: (context, index) => Divider(
                              thickness: adaptiveConv(context, 3),
                              indent: adaptiveConv(context, 5),
                            ),
                            itemCount: truckMap.length,
                            itemBuilder: (BuildContext context, int index) {
                              String id = truckMap.keys.toList()[index];
                              return ListTile(
                                leading: const Icon(Icons.fire_truck),
                                title: Text(truckMap[id]?.split("_")[0] ?? ""),
                                subtitle:
                                    Text(truckMap[id]?.split("_")[1] ?? ""),
                                selected: work.trucks.containsKey(id),
                                selectedTileColor: Colors.blue,
                                onTap: (() {
                                  setState(() {
                                    if (work.trucks.containsKey(id)) {
                                      work.trucks.remove(id);
                                    } else {
                                      work.trucks[id] = truckMap[id] ?? "";
                                    }
                                  });
                                }),
                              );
                            },
                          ),
                        ),
                      ],
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
              }),
            ),
          ),
        ),
      ),
    );
  }
}
