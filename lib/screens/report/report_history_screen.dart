import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rue_app/config/download_services.dart';
import 'package:rue_app/config/local_notification_services.dart';
import 'package:rue_app/config/theme.dart';
import 'package:rue_app/controllers/report_controller.dart';

class ReportHistoryPage extends StatefulWidget {
  const ReportHistoryPage({super.key});

  @override
  State<ReportHistoryPage> createState() => _ReportHistoryPageState();
}

class _ReportHistoryPageState extends State<ReportHistoryPage> {
  late final LocalNotificationService service;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchList = [];

  Future<Map<String, dynamic>> _downloadFile(String url) async {
    DownloadService downloadService =
        kIsWeb ? WebDownloadService() : MobileDownloadService();
    return await downloadService.download(url: url);
  }

  @override
  void initState() {
    service = LocalNotificationService();
    service.intialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Title(
      color: Colors.blue,
      title: "Report History",
      child: SafeArea(
          child: Scaffold(
        appBar: AppBar(title: const Text("Report History")),
        body: FutureBuilder(
          future: getAllReport(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            List<Map<String, dynamic>> reportList = snapshot.data ?? [];
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: adaptiveConv(context, 8),
                      horizontal: adaptiveConv(context, 50)),
                  child: TextFormField(
                    controller: searchController,
                    decoration: InputDecoration(
                      label: const Text("Search Report By Report Number"),
                      filled: true,
                      hintText: 'Report Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isEmpty) {
                        setState(() {
                          isSearching = false;
                        });
                      } else {
                        isSearching = true;
                        searchList = [];
                        for (Map<String, dynamic> temp in reportList) {
                          if (temp["reportInfo"]
                              .toLowerCase()
                              .contains(searchController.text.toLowerCase())) {
                            searchList.add(temp);
                          }
                        }
                        setState(() {});
                      }
                    },
                    validator: ((value) {
                      if (value == null || value.isEmpty) {
                        return "Report info is required";
                      }
                      return null;
                    }),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: generalPadding(context),
                    separatorBuilder: (context, index) => Divider(
                      thickness: adaptiveConv(context, 3),
                      indent: adaptiveConv(context, 5),
                    ),
                    itemCount:
                        isSearching ? searchList.length : reportList.length,
                    itemBuilder: (BuildContext context, int index) {
                      Map<String, dynamic> data =
                          isSearching ? searchList[index] : reportList[index];
                      return ListTile(
                        leading: const Icon(Icons.receipt),
                        title: Text(data["reportInfo"]),
                        onTap: () async {
                          _downloadFile(data["reference"]).then((value) {
                            if (value["message"] == 'success') {
                              if (!kIsWeb) {
                                service.showNotification(
                                  id: 0,
                                  title: 'Document Successfully Downloaded',
                                  body: 'Downloaded to ${value["object"]}',
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
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      )),
    );
  }
}
