import 'package:flutter/material.dart';
import 'package:rue_app/config/const.dart';
import 'package:rue_app/config/theme.dart';
import 'package:rue_app/controllers/attendance_controller.dart';
import 'package:rue_app/controllers/report_controller.dart';
import 'package:rue_app/controllers/work_controller.dart';
import 'package:rue_app/models/attendance_model.dart';
import 'package:rue_app/models/work_model.dart';
import 'package:rue_app/screens/report/report_history_screen.dart';
import 'package:rue_app/widget.dart';

class CreateWorkReportPage extends StatefulWidget {
  const CreateWorkReportPage({super.key});

  @override
  State<CreateWorkReportPage> createState() => _CreatWorkeReportPageState();
}

class _CreatWorkeReportPageState extends State<CreateWorkReportPage> {
  bool isWorkReport = false;
  final TextEditingController _reportFilterController = TextEditingController();
  final TextEditingController _workStatusController = TextEditingController();
  final TextEditingController _firstDateController = TextEditingController();
  final TextEditingController _lastDateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final List<String> _chooseReportList = ["Work Report", "Attendance Report"];
  Map<String, bool> workReportFilter = {
    "List All Works": true,
    "Recap Employees": true,
    "Recap Trucks": true,
  };
  Map<String, bool> attendanceReportFilter = {
    "List All Attendances Records": true,
    "Recap Attendances": true,
  };

  Map<String, bool> workStatusFilter = {
    workCancel: true,
    workDone: true,
    workDoneConfirmation: true,
    workEmployeeReject: true,
    workFailed: true,
    workInProgress: true,
    workRequestEmployee: true,
  };

  @override
  void initState() {
    super.initState();
    mapKeyToString(attendanceReportFilter, _reportFilterController);
    mapKeyToString(workStatusFilter, _workStatusController);
  }

  @override
  Widget build(BuildContext context) {
    // createReport();
    return Title(
      color: Colors.blue,
      title: "Create Report",
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Create Report"),
            actions: [
              TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ReportHistoryPage()));
                  },
                  icon: const Icon(Icons.receipt),
                  label: const Text("Report History"))
            ],
          ),
          body: Padding(
            padding: EdgeInsets.all(adaptiveConv(context, 20)),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  chooseReportDropdownButton(),
                  reportFilterDialog(context),
                  isWorkReport && workReportFilter["List All Works"] == true
                      ? workStatusDialog(context)
                      : Container(),
                  selectDateDatePicker(
                    context,
                    label: "Date:SInce",
                    hintText: "Choose the first date",
                    tec: _firstDateController,
                    validator: "Date:Since is required",
                  ),
                  selectDateDatePicker(
                    context,
                    label: "Date:Until",
                    hintText: "Choose the last date",
                    tec: _lastDateController,
                    validator: "Date:Until is required",
                  ),
                  ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          String firstDate = _firstDateController.text;
                          String lastDate = _lastDateController.text;
                          if (isWorkReport) {
                            getAllWorksWithDate(firstDate, lastDate)
                                .then((value) {
                              if (value["message"] != "success") {
                                return showAlertDialog(
                                    context, "Error", value["message"]);
                              }
                              List<Work> works = value["object"];
                              List<Map<String, dynamic>> list = [];
                              if (workReportFilter["List All Works"] == true) {
                                List<String> workStatus =
                                    _workStatusController.text.split(", ");
                                Map<String, dynamic> map = {};
                                List<String> header = [
                                  "No.",
                                  "Client",
                                  "Shipping Date",
                                  "Delivery Date",
                                  "Destination",
                                  "Receiving Company",
                                  "Driver",
                                  "Truck",
                                  "Status",
                                ];

                                List<List<String>> data = [];

                                if (works.isEmpty) {
                                  List<String> row = [];
                                  row.add("-");
                                  row.add("-");
                                  row.add("-");
                                  row.add("-");
                                  row.add("-");
                                  row.add("-");
                                  row.add("-");
                                  row.add("-");
                                  row.add("-");
                                  data.add(row);
                                } else {
                                  int index = 1;
                                  for (Work work in works) {
                                    if (workStatus.contains(work.status)) {
                                      List<String> row = [];
                                      row.add(index.toString());
                                      row.add(work.client);
                                      row.add(work.shippingDate);
                                      row.add(work.deliveryDate);
                                      row.add(work.destination);
                                      row.add(work.receivingCompany);
                                      row.add([
                                        for (var temp in work.employees.values)
                                          temp[0]
                                      ].join(", "));
                                      row.add(work.trucks.values.join(", "));
                                      row.add(work.status);
                                      index++;
                                      data.add(row);
                                    }
                                  }
                                }
                                map["header"] = header;
                                map["data"] = data;
                                list.add(map);
                              }
                              if (workReportFilter["Recap Employees"] == true) {
                                Map<String, dynamic> map = {};
                                List<String> header = [
                                  "No.",
                                  "Employee",
                                  "Rejected",
                                  "Accepted",
                                  "Successful",
                                ];
                                List<List<String>> data = [];
                                if (works.isEmpty) {
                                  List<String> row = [];
                                  row.add("-");
                                  row.add("-");
                                  row.add("-");
                                  row.add("-");
                                  row.add("-");
                                  data.add(row);
                                } else {
                                  Map<String, Map<String, dynamic>>
                                      employeesRecap = {};
                                  for (Work work in works) {
                                    for (String uid in work.employees.keys) {
                                      List<dynamic> temp = work.employees[uid];
                                      if (!employeesRecap.containsKey(uid)) {
                                        employeesRecap[uid] = {
                                          "fullName": temp[0],
                                          "REJECTED": 0,
                                          "ACCEPTED": 0,
                                          "SUCCESSFUL": 0,
                                        };
                                      }
                                      if (temp[1] == "REJECTED") {
                                        employeesRecap[uid]!["REJECTED"] =
                                            employeesRecap[uid]!["REJECTED"] +
                                                1;
                                      } else if (work.status == workDone) {
                                        employeesRecap[uid]!["SUCCESSFUL"] =
                                            employeesRecap[uid]!["SUCCESSFUL"] +
                                                1;
                                        employeesRecap[uid]!["ACCEPTED"] =
                                            employeesRecap[uid]!["ACCEPTED"] +
                                                1;
                                      } else if (temp[1] == "ACCEPTED") {
                                        employeesRecap[uid]!["ACCEPTED"] =
                                            employeesRecap[uid]!["ACCEPTED"] +
                                                1;
                                      }
                                    }
                                  }
                                  var sortedMap = Map.fromEntries(
                                      employeesRecap.entries.toList()
                                        ..sort((e1, e2) => e2
                                            .value["SUCCESSFUL"]
                                            .toString()
                                            .compareTo(e1.value["SUCCESSFUL"]
                                                .toString())));
                                  int index = 1;
                                  for (String uid in sortedMap.keys) {
                                    List<String> row = [];
                                    row.add(index.toString());
                                    row.add(employeesRecap[uid]!["fullName"]);
                                    row.add((employeesRecap[uid]!["REJECTED"])
                                        .toString());
                                    row.add((employeesRecap[uid]!["ACCEPTED"])
                                        .toString());
                                    row.add((employeesRecap[uid]!["SUCCESSFUL"])
                                        .toString());
                                    data.add(row);
                                    index++;
                                  }
                                }

                                map["header"] = header;
                                map["data"] = data;
                                list.add(map);
                              }
                              if (workReportFilter["Recap Trucks"] == true) {
                                Map<String, dynamic> map = {};
                                List<String> header = [
                                  "No.",
                                  "Truck",
                                  "Selected",
                                  "Successful",
                                ];
                                List<List<String>> data = [];
                                if (works.isEmpty) {
                                  List<String> row = [];
                                  row.add("-");
                                  row.add("-");
                                  row.add("-");
                                  row.add("-");
                                  row.add("-");
                                  data.add(row);
                                } else {
                                  Map<String, Map<String, dynamic>>
                                      trucksRecap = {};
                                  for (Work work in works) {
                                    for (String id in work.trucks.keys) {
                                      if (!trucksRecap.containsKey(id)) {
                                        String temp = work.trucks[id]
                                                ?.replaceAll("_", "-") ??
                                            "";
                                        trucksRecap[id] = {
                                          "fullName": temp,
                                          "SELECTED": 0,
                                          "SUCCESSFUL": 0,
                                        };
                                      }
                                      trucksRecap[id]!["SELECTED"] =
                                          trucksRecap[id]!["SELECTED"] + 1;
                                      if (work.status == workDone) {
                                        trucksRecap[id]!["SUCCESSFUL"] =
                                            trucksRecap[id]!["SUCCESSFUL"] + 1;
                                      }
                                    }
                                  }
                                  var sortedMap = Map.fromEntries(
                                      trucksRecap.entries.toList()
                                        ..sort((e1, e2) => e2
                                            .value["SUCCESSFUL"]
                                            .toString()
                                            .compareTo(e1.value["SUCCESSFUL"]
                                                .toString())));
                                  int index = 1;
                                  for (String id in sortedMap.keys) {
                                    List<String> row = [];
                                    row.add(index.toString());
                                    row.add((trucksRecap[id]!["fullName"])
                                        .toString());
                                    row.add((trucksRecap[id]!["SELECTED"])
                                        .toString());
                                    row.add((trucksRecap[id]!["SUCCESSFUL"])
                                        .toString());
                                    index++;
                                    data.add(row);
                                  }

                                  map["header"] = header;
                                  map["data"] = data;
                                  list.add(map);
                                }
                              }
                              createReport(list);
                            });
                          } else {
                            getAttendanceRecordsWithDate(firstDate, lastDate)
                                .then((value) {
                              List<AttendanceModel> attendances = value;
                              List<Map<String, dynamic>> list = [];
                              if (attendanceReportFilter[
                                      "List All Attendances Records"] ==
                                  true) {
                                Map<String, dynamic> map = {};
                                List<String> header = [
                                  "No.",
                                  "Employee",
                                  "Date",
                                  "Check In",
                                  "Check Out",
                                ];
                                List<List<String>> data = [];
                                if (attendances.isEmpty) {
                                  List<String> row = [];
                                  row.add("-");
                                  row.add("-");
                                  row.add("-");
                                  row.add("-");
                                  row.add("-");
                                  data.add(row);
                                } else {
                                  int index = 1;
                                  for (AttendanceModel attendance
                                      in attendances) {
                                    List<String> row = [];
                                    row.add(index.toString());
                                    row.add(attendance.fullName);
                                    row.add(attendance.date);
                                    row.add(attendance.checkInTime);
                                    row.add(attendance.checkOutTime);
                                    index++;
                                    data.add(row);
                                  }
                                }

                                map["header"] = header;
                                map["data"] = data;
                                list.add(map);
                              }
                              if (attendanceReportFilter["Recap Attendances"] ==
                                  true) {
                                Map<String, dynamic> map = {};
                                List<String> header = [
                                  "No.",
                                  "Employee",
                                  "Attendance",
                                ];
                                List<List<String>> data = [];
                                if (attendances.isEmpty) {
                                  List<String> row = [];
                                  row.add("-");
                                  row.add("-");
                                  row.add("-");
                                  data.add(row);
                                } else {
                                  Map<String, dynamic> attendanceRecap = {};
                                  for (AttendanceModel attendance
                                      in attendances) {
                                    if (!attendanceRecap
                                        .containsKey(attendance.uid)) {
                                      attendanceRecap[attendance.uid] = {
                                        "fullName": attendance.fullName,
                                        "attendances": []
                                      };
                                    }
                                    if (!attendanceRecap[attendance.uid]![
                                            "attendances"]
                                        .contains(attendance.date)) {
                                      attendanceRecap[attendance.uid]
                                              ["attendances"]
                                          .add(attendance.date);
                                    }
                                  }
                                  var sortedMap = Map.fromEntries(
                                      attendanceRecap.entries.toList()
                                        ..sort((e1, e2) => e2
                                            .value["attendances"]!.length
                                            .toString()
                                            .compareTo(e1
                                                .value["attendances"]!.length
                                                .toString())));
                                  int index = 1;
                                  for (String key in sortedMap.keys) {
                                    List<String> row = [];
                                    row.add(index.toString());
                                    row.add(attendanceRecap[key]["fullName"]);
                                    row.add(
                                        "${attendanceRecap[key]["attendances"]!.length} days");
                                    index++;
                                    data.add(row);
                                  }
                                }

                                map["header"] = header;
                                map["data"] = data;
                                list.add(map);
                              }
                              createReport(list);
                            });
                          }
                        }
                      },
                      child: const Text("Create Report"))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  mapKeyToString(Map<String, bool> map, TextEditingController tec) {
    List<String> filter = [];
    for (String key in map.keys) {
      if (map[key] == true) {
        filter.add(key);
      }
    }
    setState(() {
      tec.text = filter.join(", ");
    });
  }

  changeMapValue(var variable, bool value) {
    setState(() {
      variable = value;
    });
  }

  final DateTime _selectedDate = DateTime.now();
  Future<void> _selectDate(
      BuildContext context, TextEditingController tec) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime.parse("2022-01-01"),
        lastDate: DateTime.now().add(const Duration(days: 365 * 10)));
    if (picked != null) {
      setState(() {
        tec.text = picked.toString().split(" ")[0];
      });
    }
  }

  Padding selectDateDatePicker(BuildContext context,
      {required String label,
      required String hintText,
      required TextEditingController tec,
      required String validator}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: tec,
        readOnly: true,
        onTap: () => _selectDate(context, tec),
        decoration: InputDecoration(
          label: Text(label),
          filled: true,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return validator;
          }
          return null;
        },
      ),
    );
  }

  Padding workStatusDialog(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: _workStatusController,
        readOnly: true,
        onTap: () {
          showDialog(
              context: context,
              builder: (context) {
                return StatefulBuilder(builder: (context, setState) {
                  return filterDialog(setState, context, workStatusFilter,
                      "Work Status Filter");
                });
              }).then((value) {
            mapKeyToString(workStatusFilter, _workStatusController);
          });
        },
        decoration: InputDecoration(
          label: const Text("Work Status"),
          filled: true,
          hintText: 'Work Status',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (value) {
          if (isWorkReport &&
              workReportFilter["List All Works"] == true &&
              (value == null || value.isEmpty)) {
            return "Work Status required";
          }
          return null;
        },
      ),
    );
  }

  Padding reportFilterDialog(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: _reportFilterController,
        readOnly: true,
        onTap: () {
          showDialog(
              context: context,
              builder: (context) {
                return StatefulBuilder(builder: (context, setState) {
                  return filterDialog(
                      setState,
                      context,
                      isWorkReport ? workReportFilter : attendanceReportFilter,
                      "Report Filter");
                });
              }).then((value) {
            mapKeyToString(
                isWorkReport ? workReportFilter : attendanceReportFilter,
                _reportFilterController);
          });
        },
        decoration: InputDecoration(
          label: const Text("Report Filter"),
          filled: true,
          hintText: 'Report Filter',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Filter Report required";
          }
          return null;
        },
      ),
    );
  }

  Padding chooseReportDropdownButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonFormField(
        hint: const Text("Choose Report"),
        value: "Attendance Report",
        decoration: InputDecoration(
          label: const Text("Report"),
          filled: true,
          hintText: 'Choose Report',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        items: _chooseReportList
            .map((String value) => DropdownMenuItem(
                  value: value,
                  child: Text(value),
                ))
            .toList(),
        onChanged: (value) {
          isWorkReport = value! == "Work Report";
          mapKeyToString(
              isWorkReport ? workReportFilter : attendanceReportFilter,
              _reportFilterController);
        },
        validator: ((value) {
          if (value == null || value.isEmpty) {
            return "Choose Report!";
          }
          return null;
        }),
      ),
    );
  }

  AlertDialog filterDialog(StateSetter setState, BuildContext context,
      Map<String, bool> map, String title) {
    return AlertDialog(title: Text(title), actions: [
      for (String key in map.keys)
        Row(children: [
          Checkbox(
              value: map[key],
              onChanged: (value) {
                setState(() {
                  map[key] = value!;
                });
              }),
          Text(key)
        ]),
      ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("OK"))
    ]);
  }
}
