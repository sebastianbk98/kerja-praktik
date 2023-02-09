import 'package:flutter/material.dart';
import 'package:rue_app/config/theme.dart';
import 'package:rue_app/screens/truck/add_truck_screen.dart';
import 'package:rue_app/screens/truck/truck_details_screen.dart';
import 'package:rue_app/models/truck_model.dart';
import 'package:rue_app/controllers/truck_controller.dart';

class TruckPage extends StatefulWidget {
  const TruckPage({super.key});

  @override
  State<TruckPage> createState() => _TruckPageState();
}

class _TruckPageState extends State<TruckPage> {
  @override
  Widget build(BuildContext context) {
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
                  return ListView.separated(
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
            }),
          ),
        ),
      ),
    );
  }
}
