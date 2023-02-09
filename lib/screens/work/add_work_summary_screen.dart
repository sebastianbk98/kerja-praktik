import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rue_app/config/theme.dart';
import 'package:rue_app/controllers/work_controller.dart';
import 'package:rue_app/models/work_model.dart';
import 'package:rue_app/screens/home_screen.dart';
import 'package:rue_app/screens/work/work_screen.dart';

class AddWorkSummaryPage extends StatefulWidget {
  const AddWorkSummaryPage({super.key, required this.work, required this.file});
  final Work work;
  final Uint8List? file;
  @override
  State<AddWorkSummaryPage> createState() => _AddWorkSummaryPageState();
}

class _AddWorkSummaryPageState extends State<AddWorkSummaryPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    Work work = widget.work;
    List<String> drivers = [];
    for (List<String> driver in work.employees.values) {
      drivers.add(driver[0]);
    }
    List<String> trucks = [];
    for (String truckName in work.trucks.values) {
      trucks.add(truckName);
    }
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Container(
            constraints: const BoxConstraints.expand(),
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/rianindautamaekspress.jpg"),
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
                            ),
                            for (List<dynamic> employee
                                in work.employees.values)
                              Text(
                                "(${employee[1]}) ${employee[0]}",
                                style: textTheme(context).displaySmall,
                              ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "truck(s)",
                              style: textTheme(context).labelLarge,
                            ),
                            for (String truck in work.trucks.values)
                              Text(
                                truck,
                                style: textTheme(context).displaySmall,
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
                        ElevatedButton(
                          onPressed: () {
                            createWork(work: work, file: widget.file)
                                .then((value) {
                              if (value?.compareTo('success') == 0) {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const HomePage()),
                                    (route) => false);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const WorkPage()),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(value ?? ""),
                                  ),
                                );
                              }
                              setState(() {
                                _isLoading = false;
                              });
                            });
                          },
                          child: const Text("Create Work"),
                        )
                      ],
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
