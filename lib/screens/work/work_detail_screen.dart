import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rue_app/config/const.dart';
import 'package:rue_app/config/download_services.dart';
import 'package:rue_app/config/firebase_storage_utils.dart';
import 'package:rue_app/config/local_notification_services.dart';
import 'package:rue_app/config/theme.dart';
import 'package:rue_app/controllers/work_controller.dart';
import 'package:rue_app/models/work_model.dart';
import 'package:rue_app/screens/work/edit_ongoing_work_screen.dart';
import 'package:rue_app/screens/work/edit_work_screen.dart';
import 'package:rue_app/screens/work/work_report_screen.dart';
import 'package:rue_app/widget.dart';
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
  late final LocalNotificationService service;
  List<Uint8List> imagesByte = [];

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((SharedPreferences pref) {
      uid = pref.getString("uid") ?? "";
      isAdmin = pref.getBool("isAdmin") ?? false;
    });
    service = LocalNotificationService();
    service.intialize();
    super.initState();
  }

  Future<Map<String, dynamic>> _downloadFile(String url) async {
    DownloadService downloadService =
        kIsWeb ? WebDownloadService() : MobileDownloadService();
    return await downloadService.download(url: url);
  }

  @override
  Widget build(BuildContext context) {
    String id = widget.id;

    return Title(
      color: Colors.blue,
      title: "Work Details",
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
            title: const Text("Work Detail"),
          ),
          body: SafeArea(
            child: FutureBuilder(
              future: getWorkByID(id: id),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data?["message"] == "success") {
                    Work? work = snapshot.data?["object"];
                    for (String url in work!.reportReference) {
                      StorageServices().getImageByte(url).then((value) {
                        imagesByte.add(value);
                      });
                    }
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
                            work.deliveryDate.isNotEmpty
                                ? ColumnDetailText(
                                    label: "Delivery Date",
                                    value: work.deliveryDate,
                                  )
                                : Container(),
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
                                    truck.replaceAll("_", "-"),
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
                                      if (value["message"] == 'success') {
                                        if (!kIsWeb) {
                                          service.showNotification(
                                            id: 0,
                                            title:
                                                'Document Successfully Downloaded',
                                            body:
                                                'Downloaded to ${value["object"]}',
                                            payload: value["object"],
                                          );
                                        }
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text('Error'),
                                            content: Text(value["message"]),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Report",
                                        style: textTheme(context).labelLarge,
                                      ),
                                      for (String url in work.reportReference)
                                        Container(
                                          height: adaptiveConv(context, 250),
                                          margin: EdgeInsets.all(
                                            adaptiveConv(context, 5),
                                          ),
                                          child: GestureDetector(
                                            child: Image.network(
                                              url,
                                              fit: BoxFit.fitHeight,
                                            ),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ImageView(url: url),
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                    ],
                                  )
                                : Container(),
                            SizedBox(
                              height: adaptiveConv(context, 25),
                            ),
                            Center(
                                child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                        children: isAdmin
                                            ? [workDone, workCancel, workFailed]
                                                    .contains(work.status)
                                                ? [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title: const Text(
                                                                  "Confirm"),
                                                              content: const Text(
                                                                  "Are you sure?"),
                                                              actions: [
                                                                ElevatedButton(
                                                                  child:
                                                                      const Text(
                                                                          "No"),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context,
                                                                        false);
                                                                  },
                                                                ),
                                                                ElevatedButton(
                                                                  child:
                                                                      const Text(
                                                                          "Yes"),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context,
                                                                        true);
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        ).then((value) {
                                                          if (value != null &&
                                                              value) {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        EditWorkPage(
                                                                            work:
                                                                                work))).then(
                                                                (value) {
                                                              setState(() {});
                                                            });
                                                          }
                                                        });
                                                      },
                                                      child: const Text("Edit"),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title: const Text(
                                                                  "Confirm"),
                                                              content: const Text(
                                                                  "Are you sure?"),
                                                              actions: [
                                                                ElevatedButton(
                                                                  child:
                                                                      const Text(
                                                                          "No"),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context,
                                                                        false);
                                                                  },
                                                                ),
                                                                ElevatedButton(
                                                                  child:
                                                                      const Text(
                                                                          "Yes"),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context,
                                                                        true);
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        ).then((value) {
                                                          if (value != null &&
                                                              value) {
                                                            deleteWorkByID(
                                                                    id: id)
                                                                .then((value) {
                                                              if (value !=
                                                                  "success") {
                                                              } else {
                                                                Navigator.pop(
                                                                    context);
                                                              }
                                                            });
                                                          }
                                                        });
                                                      },
                                                      child:
                                                          const Text("Delete"),
                                                    ),
                                                  ]
                                                : [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title: const Text(
                                                                  "Confirm"),
                                                              content: const Text(
                                                                  "Are you sure?"),
                                                              actions: [
                                                                ElevatedButton(
                                                                  child:
                                                                      const Text(
                                                                          "No"),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context,
                                                                        false);
                                                                  },
                                                                ),
                                                                ElevatedButton(
                                                                  child:
                                                                      const Text(
                                                                          "Yes"),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context,
                                                                        true);
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        ).then((value) {
                                                          if (value != null &&
                                                              value) {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        [
                                                                          workDone,
                                                                          workDoneConfirmation,
                                                                          workInProgress,
                                                                        ].contains(work
                                                                                .status)
                                                                            ? EditWorkPage(
                                                                                work:
                                                                                    work)
                                                                            : EditOngoingWorkPage(work: work))).then(
                                                                (value) {
                                                              setState(() {});
                                                            });
                                                          }
                                                        });
                                                      },
                                                      child: const Text("Edit"),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title: const Text(
                                                                  "Confirm"),
                                                              content: const Text(
                                                                  "Are you sure?"),
                                                              actions: [
                                                                ElevatedButton(
                                                                  child:
                                                                      const Text(
                                                                          "No"),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context,
                                                                        false);
                                                                  },
                                                                ),
                                                                ElevatedButton(
                                                                  child:
                                                                      const Text(
                                                                          "Yes"),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context,
                                                                        true);
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        ).then((value) {
                                                          if (value != null &&
                                                              value) {
                                                            updateWorkStatus(
                                                              id: id,
                                                              status:
                                                                  workCancel,
                                                            ).then((value) {
                                                              setState(() {});
                                                            });
                                                          }
                                                        });
                                                      },
                                                      child:
                                                          const Text("Cancel"),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title: const Text(
                                                                  "Confirm"),
                                                              content: const Text(
                                                                  "Are you sure?"),
                                                              actions: [
                                                                ElevatedButton(
                                                                  child:
                                                                      const Text(
                                                                          "No"),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context,
                                                                        false);
                                                                  },
                                                                ),
                                                                ElevatedButton(
                                                                  child:
                                                                      const Text(
                                                                          "Yes"),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context,
                                                                        true);
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        ).then((value) {
                                                          if (value != null &&
                                                              value) {
                                                            updateWorkStatus(
                                                              id: id,
                                                              status:
                                                                  workFailed,
                                                            ).then((value) {
                                                              setState(() {});
                                                            });
                                                          }
                                                        });
                                                      },
                                                      child:
                                                          const Text("Failed"),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title: const Text(
                                                                  "Confirm"),
                                                              content: const Text(
                                                                  "Are you sure?"),
                                                              actions: [
                                                                ElevatedButton(
                                                                  child:
                                                                      const Text(
                                                                          "No"),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context,
                                                                        false);
                                                                  },
                                                                ),
                                                                ElevatedButton(
                                                                  child:
                                                                      const Text(
                                                                          "Yes"),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context,
                                                                        true);
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        ).then((value) {
                                                          if (value != null &&
                                                              value) {
                                                            updateWorkStatus(
                                                              id: id,
                                                              status: workDone,
                                                            ).then((value) {
                                                              setState(() {});
                                                            });
                                                          }
                                                        });
                                                      },
                                                      child: const Text("Done"),
                                                    ),
                                                  ]
                                            : work.status ==
                                                        workRequestEmployee &&
                                                    work.employees[uid][1] ==
                                                        "REQUESTING"
                                                ? [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title: const Text(
                                                                  "Confirm"),
                                                              content: const Text(
                                                                  "Are you sure?"),
                                                              actions: [
                                                                ElevatedButton(
                                                                  child:
                                                                      const Text(
                                                                          "No"),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context,
                                                                        false);
                                                                  },
                                                                ),
                                                                ElevatedButton(
                                                                  child:
                                                                      const Text(
                                                                          "Yes"),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context,
                                                                        true);
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        ).then((value) {
                                                          if (value != null &&
                                                              value) {
                                                            updateDriverStatus(
                                                                    id: id,
                                                                    uid: uid,
                                                                    status:
                                                                        "ACCEPTED")
                                                                .then((value) {
                                                              setState(() {});
                                                            });
                                                          }
                                                        });
                                                      },
                                                      child:
                                                          const Text("Accept"),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title: const Text(
                                                                  "Confirm"),
                                                              content: const Text(
                                                                  "Are you sure?"),
                                                              actions: [
                                                                ElevatedButton(
                                                                  child:
                                                                      const Text(
                                                                          "No"),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context,
                                                                        false);
                                                                  },
                                                                ),
                                                                ElevatedButton(
                                                                  child:
                                                                      const Text(
                                                                          "Yes"),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context,
                                                                        true);
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        ).then((value) {
                                                          if (value != null &&
                                                              value) {
                                                            updateDriverStatus(
                                                                    id: id,
                                                                    uid: uid,
                                                                    status:
                                                                        "REJECTED")
                                                                .then((value) {
                                                              setState(() {});
                                                            });
                                                          }
                                                        });
                                                      },
                                                      child:
                                                          const Text("Reject"),
                                                    ),
                                                  ]
                                                : work.status == workInProgress
                                                    ? [
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) =>
                                                                    WorkReportPage(
                                                                        work:
                                                                            work),
                                                              ),
                                                            ).then((value) {
                                                              setState(() {});
                                                            });
                                                          },
                                                          child: const Text(
                                                              "Report"),
                                                        ),
                                                      ]
                                                    : [
                                                        const SizedBox(
                                                          width: 1,
                                                          height: 1,
                                                        )
                                                      ]))),
                          ],
                        ),
                      ),
                    );
                  } else {
                    showAlertDialog(
                        context, "Error", snapshot.data?["message"]);
                    Navigator.pop(context);
                    return Container();
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

class ImageView extends StatelessWidget {
  const ImageView({super.key, required this.url});
  final String url;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Image Viewer"),
        ),
        body: Container(
          color: Colors.black,
          height: double.infinity,
          width: double.infinity,
          child: InteractiveViewer(child: Image.network(url)),
        ),
      ),
    );
  }
}
