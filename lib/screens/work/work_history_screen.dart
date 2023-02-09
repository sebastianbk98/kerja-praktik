import 'package:flutter/material.dart';
import 'package:rue_app/config/theme.dart';
import 'package:rue_app/models/work_model.dart';
import 'package:rue_app/screens/work/work_detail_screen.dart';
import 'package:rue_app/controllers/work_controller.dart';

class WorkHistoryPage extends StatefulWidget {
  const WorkHistoryPage({super.key});

  @override
  State<WorkHistoryPage> createState() => _WorkHistoryPageState();
}

class _WorkHistoryPageState extends State<WorkHistoryPage> {
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
          title: const Text("Work History"),
        ),
        body: SafeArea(
          child: FutureBuilder(
            future: getAllWorksHistory(),
            builder: ((context, snapshot) {
              if (snapshot.hasData) {
                Map<String, dynamic>? data = snapshot.data;
                if (data?["message"] == "success") {
                  List<Work> works = data?["object"];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              subtitle: Text(
                                  "${workData.receivingCompany}-${workData.destination}"),
                              trailing: Text(workData.status),
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
