import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rue_app/config/theme.dart';
import 'package:rue_app/models/employee_model.dart';
import 'package:rue_app/screens/employee/add_employee_screen.dart';
import 'package:rue_app/screens/employee/profile_screen.dart';
import 'package:rue_app/screens/employee/employee_profile_screen.dart';
import 'package:rue_app/controllers/employee_controller.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
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
          title: const Text("Employee"),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: ((context) => const AddEmployeePage())),
                ).then((_) {
                  setState(() {});
                });
              },
              icon: const Icon(Icons.person_add_alt),
              label: const Text("Add New Employee"),
            ),
          ],
        ),
        body: SafeArea(
          child: FutureBuilder(
            future: getAllEmployeesWithTodayAttendance(),
            builder: ((context, snapshot) {
              if (snapshot.hasData) {
                Map<String, dynamic>? data = snapshot.data;

                if (data?["message"] == "success") {
                  List<Employee> employees = data?["object"];
                  return ListView.separated(
                    padding: generalPadding(context),
                    separatorBuilder: (context, index) => Divider(
                      thickness: adaptiveConv(context, 3),
                      indent: adaptiveConv(context, 5),
                    ),
                    itemCount: employees.length,
                    itemBuilder: (BuildContext context, int index) {
                      Employee employee = employees[index];
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(employee.fullName),
                        subtitle: Text(employee.position),
                        trailing: Text(employee.checkInStatus
                            ? "Check In"
                            : "Not Check In Yet"),
                        onTap: (() {
                          if (employee.uid ==
                              FirebaseAuth.instance.currentUser?.uid) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: ((context) => const ProfilePage()),
                              ),
                            ).then((_) {
                              setState(() {});
                            });
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: ((context) =>
                                    EmployeeProfilePage(uid: employee.uid)),
                              ),
                            ).then((value) {
                              setState(() {});
                            });
                          }
                        }),
                      );
                    },
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
