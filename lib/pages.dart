import 'package:flutter/material.dart';

void openPage(BuildContext context, dynamic page) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => page,
    ),
  );
}

void switchPage(BuildContext context, dynamic page) {
  Navigator.pop(context);
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => page));
}
