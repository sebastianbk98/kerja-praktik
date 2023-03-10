import 'package:flutter/material.dart';
import 'package:rue_app/config/const.dart';
import 'package:rue_app/config/theme.dart';
import 'package:rue_app/screens/employee/edit_employee_screen.dart';
import 'package:rue_app/widget.dart';
import 'package:rue_app/models/employee_model.dart';
import 'package:rue_app/controllers/employee_controller.dart';

class EmployeeProfilePage extends StatefulWidget {
  const EmployeeProfilePage({super.key, required this.uid});
  final String uid;

  @override
  State<EmployeeProfilePage> createState() => _EmployeeProfilePageState();
}

class _EmployeeProfilePageState extends State<EmployeeProfilePage> {
  @override
  Widget build(BuildContext context) {
    String uid = widget.uid;
    return Title(
      color: Colors.blue,
      title: "Employee Profile",
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
            title: const Text("Profile"),
          ),
          body: SafeArea(
              child: FutureBuilder(
            future: getEmployeeByUid(uid),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Map<String, dynamic>? data = snapshot.data;
                if (data?["message"] == "success") {
                  Employee employee = data?["object"];
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: AccountDetails(employee: employee),
                        ),
                        SizedBox(
                          height: adaptiveConv(context, 25),
                        ),
                        Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditProfilePage(
                                          isManager: true,
                                          employee: employee,
                                        ),
                                      ),
                                    ).then((_) {
                                      setState(() {});
                                    });
                                  },
                                  child: const Text("Edit"),
                                ),
                                SizedBox(
                                  width: adaptiveConv(context, 15),
                                ),
                                employee.status == employeeAvailable
                                    ? ElevatedButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text("Confirm"),
                                                content:
                                                    const Text("Are you sure?"),
                                                actions: [
                                                  ElevatedButton(
                                                    child: const Text("No"),
                                                    onPressed: () {
                                                      Navigator.pop(
                                                          context, false);
                                                    },
                                                  ),
                                                  ElevatedButton(
                                                    child: const Text("Yes"),
                                                    onPressed: () {
                                                      Navigator.pop(
                                                          context, true);
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          ).then((value) {
                                            if (value != null && value) {
                                              deleteEmployeeByUid(uid)
                                                  .then((value) {
                                                if (value == "success") {
                                                  Navigator.pop(context);
                                                } else {
                                                  showAlertDialog(
                                                      context, "Error", value);
                                                }
                                              });
                                            }
                                          });
                                        },
                                        child: const Text("Delete"),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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
            },
          )),
        ),
      ),
    );
  }
}
