import 'package:flutter/material.dart';
import 'package:rue_app/config/theme.dart';
import 'package:rue_app/models/employee_model.dart';

class GridItem extends StatelessWidget {
  const GridItem(
      {super.key,
      required this.icon,
      required this.title,
      required this.route});
  final IconData icon;
  final String title;
  final Widget route;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => route));
      },
      child: Container(
        padding: EdgeInsets.all(adaptiveConv(context, 5)),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.all(Radius.circular(adaptiveConv(context, 15))),
          boxShadow: const [
            BoxShadow(blurRadius: 1),
            BoxShadow(color: Colors.white),
          ],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: adaptiveConv(context, 50),
              ),
              SizedBox(
                width: adaptiveConv(context, 20),
              ),
              Text(
                title,
                style: textTheme(context).titleLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AccountDetails extends StatelessWidget {
  const AccountDetails({super.key, required this.employee});
  final Employee employee;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(
              "Full Name",
              style: textTheme(context).labelMedium,
            ),
            Text(
              employee.fullName,
              style: textTheme(context).displaySmall,
            ),
          ],
        ),
        Column(
          children: [
            Text(
              "Phone Number",
              style: textTheme(context).labelMedium,
            ),
            Text(
              employee.phoneNumber,
              style: textTheme(context).displaySmall,
            ),
          ],
        ),
        Column(
          children: [
            Text(
              "Position",
              style: textTheme(context).labelMedium,
            ),
            Text(
              employee.position,
              style: textTheme(context).displaySmall,
            ),
          ],
        ),
        Column(
          children: [
            Text(
              "Email",
              style: textTheme(context).labelMedium,
            ),
            Text(
              employee.email,
              style: textTheme(context).displaySmall,
            ),
          ],
        ),
        Column(
          children: [
            Text(
              "Status",
              style: textTheme(context).labelMedium,
            ),
            Text(
              employee.status,
              style: textTheme(context).displaySmall,
            ),
          ],
        ),
      ],
    );
  }
}
