import 'package:flutter/material.dart';
import 'package:rue_app/config/theme.dart';
import 'package:rue_app/models/work_model.dart';
import 'package:rue_app/screens/work/add_work_screen.dart';
import 'package:rue_app/screens/work/work_detail_screen.dart';
import 'package:rue_app/screens/work/work_history_screen.dart';
import 'package:rue_app/controllers/work_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkPage extends StatefulWidget {
  const WorkPage({super.key});

  @override
  State<WorkPage> createState() => _WorkPageState();
}

class _WorkPageState extends State<WorkPage> {
  late bool isAdmin;
  late String uid;
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((SharedPreferences pref) {
      isAdmin = pref.getBool("isAdmin") ?? false;
      uid = pref.getString("uid") ?? "";
    });
  }

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
          title: const Text("Ongoing Work"),
          actions: [
            TextButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: ((context) => const WorkHistoryPage())),
                );
                setState(() {});
              },
              icon: const Icon(Icons.work_history),
              label: const Text("Work History"),
            ),
          ],
        ),
        body: SafeArea(
          child: FutureBuilder(
            future: getAllOngoingWorks(),
            builder: ((context, snapshot) {
              if (snapshot.hasData) {
                Map<String, dynamic>? data = snapshot.data;
                if (data?["message"] == "success") {
                  List<Work> works = data?["object"];
                  if (!isAdmin) {
                    List<Work> temp = [];
                    for (Work work in works) {
                      if (work.employees.containsKey(uid)) {
                        temp.add(work);
                      }
                    }
                    works = temp;
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isAdmin
                          ? Padding(
                              padding: generalPadding(context),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: ((context) =>
                                                const AddWorkPage())));
                                    setState(() {});
                                  },
                                  child: Row(
                                    children: [
                                      const Icon(Icons.add_circle_outline),
                                      SizedBox(
                                        width: adaptiveConv(context, 5),
                                      ),
                                      const Text("Add New Work"),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                      Expanded(
                        child: ListView.separated(
                          padding: generalPadding(context),
                          separatorBuilder: (context, index) => Divider(
                            thickness: adaptiveConv(context, 3),
                            indent: adaptiveConv(context, 5),
                          ),
                          itemCount: works.length,
                          itemBuilder: (BuildContext context, int index) {
                            Work workData = works[index];
                            return ListTile(
                              leading: const Icon(Icons.person),
                              title: Text(workData.client),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "${workData.receivingCompany}-${workData.destination}"),
                                  Text(workData.status),
                                ],
                              ),
                              onTap: (() {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: ((context) =>
                                        WorkDetailPage(id: workData.id)),
                                  ),
                                ).then((value) {
                                  setState(() {});
                                });
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
