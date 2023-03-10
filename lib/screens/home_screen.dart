import 'package:flutter/material.dart';
import 'package:rue_app/config/const.dart';
import 'package:rue_app/screens/report/create_report_screen.dart';
import 'package:rue_app/screens/employee/profile_screen.dart';
import 'package:rue_app/screens/attendance/attendance_screen.dart';
import 'package:rue_app/screens/attendance/scan_qr_screen.dart';
import 'package:rue_app/screens/truck/truck_screen.dart';
import 'package:rue_app/screens/work/work_screen.dart';
import 'package:rue_app/config/theme.dart';
import 'package:rue_app/widget.dart';
import 'package:rue_app/screens/employee/employee_screen.dart';
import 'package:rue_app/models/employee_model.dart';
import 'package:rue_app/controllers/employee_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
        future: getLoggedInEmployee(),
        builder: ((context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic>? data = snapshot.data;
            if (data?["message"] == "success") {
              Employee employee = data?["object"];
              List<GridItem> gridItems = [
                const GridItem(
                  icon: Icons.work,
                  title: "Work",
                  route: WorkPage(),
                ),
                GridItem(
                  icon: Icons.calendar_month,
                  title: "Attendance",
                  route: TableEventsExample(uid: employee.uid),
                ),
                const GridItem(
                  icon: Icons.people,
                  title: "Employee",
                  route: EmployeePage(),
                ),
                const GridItem(
                  icon: Icons.car_rental,
                  title: "Truck",
                  route: TruckPage(),
                ),
              ];
              return Title(
                color: Colors.black,
                title: "Home Page",
                child: Container(
                  constraints: const BoxConstraints.expand(),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                            "assets/images/rianindautamaekspress.jpg"),
                        fit: BoxFit.cover),
                  ),
                  child: Scaffold(
                    floatingActionButtonLocation:
                        FloatingActionButtonLocation.endFloat,
                    floatingActionButton: employee.position == positionManager
                        ? ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const CreateWorkReportPage()));
                            },
                            label: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Create Report"),
                            ),
                            icon: const Icon(Icons.create),
                          )
                        : Container(),
                    backgroundColor: Colors.white.withOpacity(0.9),
                    appBar: AppBar(
                      title: Text("Welcome, ${employee.fullName}"),
                      leading: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ProfilePage()),
                          );
                        },
                        icon: const Icon(Icons.account_circle_outlined),
                      ),
                    ),
                    body: SafeArea(
                      child: ListView(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: adaptiveConv(context, 10),
                              horizontal: adaptiveConv(context, 20),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    vertical: adaptiveConv(context, 10),
                                    horizontal: adaptiveConv(context, 20),
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(
                                          adaptiveConv(context, 30)),
                                    ),
                                    boxShadow: [
                                      const BoxShadow(blurRadius: 0.5),
                                      BoxShadow(color: primaryColor(context)),
                                    ],
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Working in the office?",
                                              style: textTheme(context)
                                                  .headlineSmall!
                                                  .copyWith(
                                                      color: Colors.white),
                                            ),
                                            Text(
                                              "Don't forget to check-in",
                                              style: textTheme(context)
                                                  .bodyLarge!
                                                  .copyWith(
                                                      color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          width: adaptiveConv(context, 75),
                                        ),
                                        Icon(
                                          Icons.maps_home_work,
                                          size: adaptiveConv(context, 50),
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    vertical: adaptiveConv(context, 10),
                                    horizontal: adaptiveConv(context, 20),
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(
                                      bottom: Radius.circular(
                                          adaptiveConv(context, 30)),
                                    ),
                                    boxShadow: const [
                                      BoxShadow(blurRadius: 0.5),
                                      BoxShadow(color: Colors.white),
                                    ],
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text("Status: "),
                                        Text(employee.checkInStatus.isNotEmpty
                                            ? "Check In"
                                            : "Not Check In"),
                                        SizedBox(
                                          width: adaptiveConv(context, 10),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => QrScanner(
                                                  id: employee.checkInStatus,
                                                  uid: employee.uid,
                                                  fullName: employee.fullName,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text(
                                              employee.checkInStatus.isNotEmpty
                                                  ? "Check Out"
                                                  : "Check In"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GridView.count(
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                              vertical: adaptiveConv(context, 5),
                              horizontal: adaptiveConv(context, 20),
                            ),
                            crossAxisCount: 2,
                            crossAxisSpacing: adaptiveConv(context, 10),
                            mainAxisSpacing: adaptiveConv(context, 10),
                            shrinkWrap: true,
                            childAspectRatio: 1 / .3,
                            children: employee.position == positionManager
                                ? gridItems
                                : gridItems.sublist(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else {
              showAlertDialog(context, "Error", data?["message"]);
              Navigator.pop(context);
              return Title(
                  color: Colors.black, title: "Home Page", child: Container());
            }
          } else {
            return Title(
              color: Colors.black,
              title: "Home Page",
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        }),
      ),
    );
  }
}
