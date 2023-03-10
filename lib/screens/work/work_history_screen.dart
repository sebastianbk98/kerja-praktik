import 'package:flutter/material.dart';
import 'package:rue_app/config/theme.dart';
import 'package:rue_app/models/work_model.dart';
import 'package:rue_app/screens/work/work_detail_screen.dart';
import 'package:rue_app/controllers/work_controller.dart';
import 'package:rue_app/widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkHistoryPage extends StatefulWidget {
  const WorkHistoryPage({super.key});

  @override
  State<WorkHistoryPage> createState() => _WorkHistoryPageState();
}

class _WorkHistoryPageState extends State<WorkHistoryPage> {
  late bool isAdmin;
  late String uid;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  List<Work> searchList = [];
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
    return Title(
      color: Colors.blue,
      title: "Work History",
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
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: adaptiveConv(context, 8),
                              horizontal: adaptiveConv(context, 50)),
                          child: TextFormField(
                            controller: searchController,
                            decoration: InputDecoration(
                              label: const Text("Search Work By Client Name"),
                              filled: true,
                              hintText: 'Client Name',
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
                                for (Work temp in works) {
                                  if (temp.client.toLowerCase().contains(
                                      searchController.text.toLowerCase())) {
                                    searchList.add(temp);
                                  }
                                }
                                setState(() {});
                              }
                            },
                            validator: ((value) {
                              if (value == null || value.isEmpty) {
                                return "Employee Name is required";
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
                                isSearching ? searchList.length : works.length,
                            itemBuilder: (BuildContext context, int index) {
                              Work workData = isSearching
                                  ? searchList[index]
                                  : works[index];
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
                    showAlertDialog(context, "Error", data?["message"]);
                    Navigator.pop(context);
                    return Container();
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
      ),
    );
  }
}
