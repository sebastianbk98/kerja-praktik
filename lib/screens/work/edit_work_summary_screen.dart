import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rue_app/config/theme.dart';
import 'package:rue_app/controllers/work_controller.dart';
import 'package:rue_app/models/work_model.dart';
import 'package:rue_app/screens/home_screen.dart';
import 'package:rue_app/screens/work/work_screen.dart';
import 'package:rue_app/widget.dart';

class EditWorkSummaryPage extends StatefulWidget {
  const EditWorkSummaryPage(
      {super.key,
      required this.work,
      required this.file,
      required this.truckMap,
      required this.employeeMap});
  final Work work;
  final Map<String, String> truckMap;
  final Map<String, dynamic> employeeMap;
  final Uint8List? file;
  @override
  State<EditWorkSummaryPage> createState() => _EditWorkSummaryPageState();
}

class _EditWorkSummaryPageState extends State<EditWorkSummaryPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    Work work = widget.work;
    List<String> drivers = [];
    for (List<dynamic> driver in work.employees.values) {
      drivers.add(driver[0]);
    }
    List<String> trucks = [];
    for (String truckName in work.trucks.values) {
      trucks.add(truckName);
    }
    return Title(
      color: Colors.blue,
      title: "New Work Summary",
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              constraints: const BoxConstraints.expand(),
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image:
                        AssetImage("assets/images/rianindautamaekspress.jpg"),
                    fit: BoxFit.cover),
              ),
              child: Scaffold(
                backgroundColor: Colors.white.withOpacity(0.9),
                appBar: AppBar(
                  title: const Text("Add New Work"),
                ),
                body: SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        adaptiveConv(context, 50),
                        adaptiveConv(context, 20),
                        adaptiveConv(context, 50),
                        adaptiveConv(context, 20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ColumnDetailText(
                            label: "Client",
                            value: work.client,
                          ),
                          ColumnDetailText(
                            label: "Receiving Company",
                            value: work.receivingCompany,
                          ),
                          ColumnDetailText(
                            label: "Destination",
                            value: work.destination,
                          ),
                          ColumnDetailText(
                            label: "Weight",
                            value: work.weight,
                          ),
                          ColumnDetailText(
                            label: "Shiping Date",
                            value: work.shippingDate,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Employee(s)",
                                style: textTheme(context).labelLarge,
                                textAlign: TextAlign.center,
                              ),
                              for (List<dynamic> employee
                                  in work.employees.values)
                                Text(
                                  "(${employee[1]}) ${employee[0]}",
                                  style: textTheme(context).displaySmall,
                                  textAlign: TextAlign.center,
                                ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "truck(s)",
                                style: textTheme(context).labelLarge,
                                textAlign: TextAlign.center,
                              ),
                              for (String truck in work.trucks.values)
                                Text(
                                  truck,
                                  style: textTheme(context).displaySmall,
                                  textAlign: TextAlign.center,
                                ),
                            ],
                          ),
                          ColumnDetailText(
                            label: "Status",
                            value: work.status,
                          ),
                          ColumnDetailText(
                            label: "Document",
                            value: work.documentReference,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Confirm"),
                                        content: const Text(
                                            "All progress will be deleted. Are you sure?"),
                                        actions: [
                                          ElevatedButton(
                                            child: const Text("No"),
                                            onPressed: () {
                                              Navigator.pop(context, false);
                                            },
                                          ),
                                          ElevatedButton(
                                            child: const Text("Yes"),
                                            onPressed: () {
                                              Navigator.pop(context, true);
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  ).then((value) {
                                    if (value != null && value) {
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const HomePage()),
                                          (route) => false);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const WorkPage()),
                                      );
                                    }
                                  });
                                },
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Confirm"),
                                        content: const Text("Are you sure?"),
                                        actions: [
                                          ElevatedButton(
                                            child: const Text("No"),
                                            onPressed: () {
                                              Navigator.pop(context, false);
                                            },
                                          ),
                                          ElevatedButton(
                                            child: const Text("Yes"),
                                            onPressed: () {
                                              Navigator.pop(context, true);
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  ).then((value) {
                                    if (value != null && value) {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      editOngoingWork(
                                        work: work,
                                        file: widget.file,
                                        employeeMap: widget.employeeMap,
                                        truckMap: widget.truckMap,
                                      ).then((value) {
                                        if (value?.compareTo('success') == 0) {
                                          Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const HomePage()),
                                              (route) => false);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const WorkPage()),
                                          );
                                        } else {
                                          showAlertDialog(context, "Error",
                                              value.toString());
                                        }
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      });
                                    }
                                  });
                                },
                                child: const Text("Edit Work"),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class ColumnDetailText extends StatelessWidget {
  const ColumnDetailText({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: textTheme(context).labelLarge,
          textAlign: TextAlign.center,
        ),
        Text(
          value,
          style: textTheme(context).displaySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
