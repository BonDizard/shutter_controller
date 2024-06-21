import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import '../constants/constants.dart';

class CustomToast {
  static void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: kTertiary,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
