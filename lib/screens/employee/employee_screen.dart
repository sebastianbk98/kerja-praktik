import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rue_app/config/theme.dart';
import 'package:rue_app/models/employee_model.dart';
import 'package:rue_app/screens/employee/add_employee_screen.dart';
import 'package:rue_app/screens/employee/profile_screen.dart';
import 'package:rue_app/screens/employee/employee_profile_screen.dart';
import 'package:rue_app/controllers/employee_controller.dart';
import 'package:rue_app/widget.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  List<Employee> searchList = [];
  @override
  Widget build(BuildContext context) {
    return Title(
      color: Colors.blue,
      title: "Employees",
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
                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: adaptiveConv(context, 8),
                              horizontal: adaptiveConv(context, 50)),
                          child: TextFormField(
                            controller: searchController,
                            decoration: InputDecoration(
                              label: const Text("Search Employee By Name"),
                              filled: true,
                              hintText: 'Employee Name',
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
                                for (Employee emp in employees) {
                                  if (emp.fullName.toLowerCase().contains(
                                      searchController.text.toLowerCase())) {
                                    searchList.add(emp);
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
                            itemCount: isSearching
                                ? searchList.length
                                : employees.length,
                            itemBuilder: (BuildContext context, int index) {
                              Employee employee = isSearching
                                  ? searchList[index]
                                  : employees[index];
                              return ListTile(
                                leading: const Icon(Icons.person),
                                title: Text(employee.fullName),
                                subtitle: Text(employee.position),
                                trailing: Text(employee.checkInStatus.isNotEmpty
                                    ? "Check In"
                                    : "Not Check In Yet"),
                                onTap: (() {
                                  if (employee.uid ==
                                      FirebaseAuth.instance.currentUser?.uid) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: ((context) =>
                                            const ProfilePage()),
                                      ),
                                    ).then((_) {
                                      setState(() {});
                                    });
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: ((context) =>
                                            EmployeeProfilePage(
                                                uid: employee.uid)),
                                      ),
                                    ).then((value) {
                                      setState(() {});
                                    });
                                  }
                                }),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  } else {
                    showAlertDialog(context, "Error", data?["message"]);
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
