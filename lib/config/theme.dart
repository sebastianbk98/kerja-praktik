import 'package:flutter/material.dart';

Color primaryColor(BuildContext context) => Theme.of(context).primaryColor;

TextTheme textTheme(BuildContext context) => Theme.of(context).textTheme;

double adaptiveConv(BuildContext context, double size) {
  if (MediaQuery.of(context).size.width < MediaQuery.of(context).size.height) {
    return MediaQuery.of(context).size.width / 375 * size;
  } else {
    return MediaQuery.of(context).size.height / 667 * size;
  }
}

EdgeInsets generalPadding(BuildContext context) => EdgeInsets.symmetric(
    vertical: adaptiveConv(context, 10), horizontal: adaptiveConv(context, 20));
