import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rue_app/config/const.dart';
import 'package:rue_app/config/download_services.dart';
import 'package:rue_app/config/theme.dart';
import 'package:rue_app/controllers/work_controller.dart';
import 'package:rue_app/models/work_model.dart';
import 'package:rue_app/screens/work/work_report_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkDetailPage extends StatefulWidget {
  const WorkDetailPage({super.key, required this.id});
  final String id;

  @override
  State<WorkDetailPage> createState() => _WorkDetailPageState();
}

class _WorkDetailPageState extends State<WorkDetailPage> {
  late String uid;
  late bool isAdmin;
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((SharedPreferences pref) {
      uid = pref.getString("uid") ?? "";
      isAdmin = pref.getBool("isAdmin") ?? false;
    });
  }

  Future<String> _downloadFile(String url) async {
    DownloadService downloadService =
        kIsWeb ? WebDownloadService() : MobileDownloadService();
    return await downloadService.download(url: url);
  }

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
          title: const Text("Work Detail"),
        ),
        body: SafeArea(
          child: FutureBuilder(
            future: getWorkByID(id: id),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data?["message"] == "success") {
                  Work? work = snapshot.data?["object"];

                  return SingleChildScrollView(
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
                            value: work!.client,
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Document",
                                style: textTheme(context).labelLarge,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _downloadFile(work.documentReference)
                                      .then((value) {
                                    if (value == 'success' && !kIsWeb) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "File is downloaded to folder Download"),
                                        ),
                                      );
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
                                child: const Text("Download Document"),
                              ),
                            ],
                          ),
                          work.reportReference.isNotEmpty
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Report",
                                      style: textTheme(context).labelLarge,
                                    ),
                                    for (var i = 0;
                                        i < work.reportReference.length;
                                        i++)
                                      ElevatedButton(
                                        onPressed: () async {
                                          await _downloadFile(
                                              work.reportReference[i]);
                                        },
                                        child: Text("Image ${i + 1}"),
                                      ),
                                  ],
                                )
                              : Container(),
                          SizedBox(
                            height: adaptiveConv(context, 25),
                          ),
                          isAdmin &&
                                  ![workDone, workCancel, workFailed]
                                      .contains(work.status)
                              ? Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            await updateWorkStatus(
                                                id: id, status: workCancel);
                                            setState(() {});
                                          },
                                          child: const Text("Cancel"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            await updateWorkStatus(
                                                id: id, status: workFailed);
                                            setState(() {});
                                          },
                                          child: const Text("Failed"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            await updateWorkStatus(
                                                id: id, status: workDone);
                                            setState(() {});
                                          },
                                          child: const Text("Done"),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : work.status == workRequestEmployee
                                  ? work.employees[uid][1] == "REQUESTING"
                                      ? Center(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Row(
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    await updateDriverStatus(
                                                        id: id,
                                                        uid: uid,
                                                        status: "ACCEPTED");
                                                    setState(() {});
                                                  },
                                                  child: const Text("Accept"),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    await updateDriverStatus(
                                                        id: id,
                                                        uid: uid,
                                                        status: "REJECTED");
                                                    setState(() {});
                                                  },
                                                  child: const Text("Reject"),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Container()
                                  : work.status == workInProgress
                                      ? Center(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Row(
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            WorkReportPage(
                                                                work: work),
                                                      ),
                                                    ).then((value) {
                                                      setState(() {});
                                                    });
                                                  },
                                                  child: const Text("Report"),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Container()
                        ],
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: Text(snapshot.data?["message"]),
                  );
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
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
