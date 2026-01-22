import 'package:flutter/material.dart';

class CustomSnackbar {
  static void showSnackbar(BuildContext context, String message,
      {String type = 'info'}) {
    Color backgroundColor;

    switch (type) {
      case 'error':
        backgroundColor = Colors.red;
        break;
      case 'warning':
        backgroundColor = Colors.orange;
        break;
      case 'info':
      default:
        backgroundColor = Colors.blue;
    }

    final snackbar = SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      duration: Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}
