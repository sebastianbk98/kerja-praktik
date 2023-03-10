import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rue_app/config/theme.dart';
import 'package:rue_app/controllers/employee_controller.dart';
import 'package:rue_app/models/employee_model.dart';
import 'package:rue_app/models/work_model.dart';
import 'package:rue_app/screens/work/edit_work_summary_screen.dart';
import 'package:rue_app/widget.dart';

class EditWorkDriversPage extends StatefulWidget {
  const EditWorkDriversPage(
      {super.key,
      required this.work,
      required this.file,
      required this.truckMap});
  final Work work;
  final Uint8List? file;
  final Map<String, String> truckMap;
  @override
  State<EditWorkDriversPage> createState() => _EditWorkDriversPageState();
}

class _EditWorkDriversPageState extends State<EditWorkDriversPage> {
  Map<String, dynamic> oldEmployeeMap = {};
  Map<String, dynamic> employeeMap = {};
  @override
  Widget build(BuildContext context) {
    Work work = widget.work;

    for (String uid in work.employees.keys) {
      oldEmployeeMap[uid] = work.employees[uid] ?? [];
    }
    return Title(
        color: Colors.blue,
        title: "Choose Driver(s)",
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

                              for (String uid in work.employees.keys) {
                                employeeMap[uid] = work.employees[uid] ?? [];
                              }
                              for (Employee employee in employees) {
                                employeeMap[employee.uid] = [
                                  employee.fullName,
                                  ""
                                ];
                              }
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
                                                          EditWorkSummaryPage(
                                                        work: work,
                                                        file: widget.file,
                                                        employeeMap:
                                                            oldEmployeeMap,
                                                        truckMap:
                                                            widget.truckMap,
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
                                            separatorBuilder: (context,
                                                    index) =>
                                                Divider(
                                                  thickness:
                                                      adaptiveConv(context, 3),
                                                  indent:
                                                      adaptiveConv(context, 5),
                                                ),
                                            itemCount: employeeMap.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              String uid = employeeMap.keys
                                                  .toList()[index];
                                              return ListTile(
                                                  leading: const Icon(
                                                      Icons.fire_truck),
                                                  title:
                                                      Text(employeeMap[uid][0]),
                                                  selected: work.employees
                                                      .containsKey(uid),
                                                  selectedTileColor:
                                                      Colors.blue,
                                                  onTap: (() {
                                                    if (work.employees
                                                        .containsKey(uid)) {
                                                      setState(() {
                                                        work.employees
                                                            .remove(uid);
                                                      });
                                                    } else {
                                                      if (work.employees
                                                              .length <
                                                          work.trucks.length) {
                                                        setState(() {
                                                          work.employees[uid] =
                                                              [
                                                            employeeMap[uid][0],
                                                            "REQUESTING"
                                                          ];
                                                        });
                                                      } else {
                                                        showAlertDialog(
                                                            context,
                                                            "Driver(s)",
                                                            "Enough Driver(s)");
                                                      }
                                                    }
                                                  }));
                                            }))
                                  ]);
                            } else {
                              showAlertDialog(
                                  context, "Error", data?["message"]);
                              Navigator.pop(context);
                              return Container();
                            }
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        }))))));
  }
}
