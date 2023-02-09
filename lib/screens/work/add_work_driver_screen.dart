import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rue_app/config/theme.dart';
import 'package:rue_app/controllers/employee_controller.dart';
import 'package:rue_app/models/employee_model.dart';
import 'package:rue_app/models/work_model.dart';
import 'package:rue_app/screens/work/add_work_summary_screen.dart';

class AddWorkDriversPage extends StatefulWidget {
  const AddWorkDriversPage({super.key, required this.work, required this.file});
  final Work work;
  final Uint8List? file;

  @override
  State<AddWorkDriversPage> createState() => _AddWorkDriversPageState();
}

class _AddWorkDriversPageState extends State<AddWorkDriversPage> {
  @override
  Widget build(BuildContext context) {
    Work work = widget.work;
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
          title: const Text("Select Drivers"),
        ),
        body: SafeArea(
          child: FutureBuilder(
            future: getAllEmployeesForDriver(),
            builder: ((context, snapshot) {
              if (snapshot.hasData) {
                Map<String, dynamic>? data = snapshot.data;
                if (data?["message"] == "success") {
                  List<Employee> employees = data?["object"];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                              "Need ${work.trucks.length - work.employees.length} driver(s)"),
                          ElevatedButton(
                            onPressed: work.employees.isEmpty
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddWorkSummaryPage(
                                          work: work,
                                          file: widget.file,
                                        ),
                                      ),
                                    );
                                  },
                            child: const Text("Summary"),
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
                          itemCount: employees.length,
                          itemBuilder: (BuildContext context, int index) {
                            Employee employee = employees[index];
                            return ListTile(
                              leading: const Icon(Icons.fire_truck),
                              title: Text(employee.fullName),
                              subtitle: Text(employee.position),
                              trailing: Text(employee.status),
                              selected:
                                  work.employees.containsKey(employee.uid),
                              selectedTileColor: Colors.blue,
                              onTap: (() {
                                if (work.employees.containsKey(employee.uid)) {
                                  setState(() {
                                    work.employees.remove(employee.uid);
                                  });
                                } else {
                                  if (work.employees.length <
                                      work.trucks.length) {
                                    setState(() {
                                      work.employees[employee.uid] = [
                                        employee.fullName,
                                        "REQUESTING"
                                      ];
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Enough Drivers"),
                                      ),
                                    );
                                  }
                                }
                              }),
                            );
                          },
                        ),
                      ),
                    ],
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
