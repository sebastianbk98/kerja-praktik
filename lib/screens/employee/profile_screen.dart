import 'package:flutter/material.dart';
import 'package:rue_app/auth/auth_utils.dart';
import 'package:rue_app/config/theme.dart';
import 'package:rue_app/screens/employee/edit_employee_screen.dart';
import 'package:rue_app/screens/login_screen.dart';
import 'package:rue_app/widget.dart';
import 'package:rue_app/models/employee_model.dart';
import 'package:rue_app/controllers/employee_controller.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
          title: const Text("Profile"),
          actions: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: TextButton(
                  onPressed: () {
                    AuthService().logout().then((value) {
                      if (value == "success") {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                          (route) => false,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(value),
                          ),
                        );
                      }
                    });
                  },
                  child: Row(
                    children: const [Icon(Icons.logout), Text("Logout")],
                  ),
                ),
              ),
            )
          ],
        ),
        body: SafeArea(
            child: FutureBuilder(
          future: getLoggedInEmployee(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Map<String, dynamic>? data = snapshot.data;
              if (data?["message"] == "success") {
                Employee? employee = data?["object"];
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: AccountDetails(employee: employee!),
                      ),
                      SizedBox(
                        height: adaptiveConv(context, 25),
                      ),
                      Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: ElevatedButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfilePage(
                                    isManager: false,
                                    employee: employee,
                                  ),
                                ),
                              );
                              setState(() {});
                            },
                            child: const Text("Edit"),
                          ),
                        ),
                      ),
                    ],
                  ),
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
          },
        )),
      ),
    );
  }
}
