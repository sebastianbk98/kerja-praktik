import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rue_app/config/theme.dart';
import 'package:rue_app/controllers/truck_controller.dart';
import 'package:rue_app/models/truck_model.dart';
import 'package:rue_app/models/work_model.dart';
import 'package:rue_app/screens/work/add_work_driver_screen.dart';
import 'package:rue_app/widget.dart';

class AddWorkTrucksPage extends StatefulWidget {
  const AddWorkTrucksPage({super.key, required this.work, required this.file});
  final Work work;
  final Uint8List? file;

  @override
  State<AddWorkTrucksPage> createState() => _AddWorkTrucksPageState();
}

class _AddWorkTrucksPageState extends State<AddWorkTrucksPage> {
  @override
  Widget build(BuildContext context) {
    Work work = widget.work;
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
                                              AddWorkDriversPage(
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
                            itemCount: trucks.length,
                            itemBuilder: (BuildContext context, int index) {
                              Truck truckData = trucks[index];
                              return ListTile(
                                leading: const Icon(Icons.fire_truck),
                                title: Text(truckData.name),
                                subtitle: Text(truckData.licenseNumber),
                                trailing: Text(truckData.status),
                                selected: work.trucks.containsKey(truckData.id),
                                selectedTileColor: Colors.blue,
                                onTap: (() {
                                  setState(() {
                                    if (work.trucks.containsKey(truckData.id)) {
                                      work.trucks.remove(truckData.id);
                                    } else {
                                      work.trucks[truckData.id] =
                                          "${truckData.name}_${truckData.licenseNumber}";
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
