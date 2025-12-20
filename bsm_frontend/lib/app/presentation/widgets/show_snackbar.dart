import 'package:flutter/material.dart';

class ShowSnackBar {
  static void show(BuildContext context, String message, String type) {
    Color bgColor;

    switch (type) {
      case 'success':
        bgColor = Colors.green;
        break;
      case 'warning':
        bgColor = Colors.orange;
        break;
      case 'error':
        bgColor = Colors.red;
        break;
      default:
        bgColor = Colors.blueGrey;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
