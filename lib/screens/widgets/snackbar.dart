import 'package:flutter/material.dart';

class SnackbarService {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showMessage(String message,
      {SnackBarAction? action,
      Duration duration = const Duration(seconds: 2)}) {
    messengerKey.currentState!.showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(color: Colors.black, fontSize: 16)),
        duration: duration,
        showCloseIcon: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        closeIconColor: Colors.black,
        elevation: 0,
        action: action,
        backgroundColor: const Color.fromARGB(255, 231, 231, 231),
      ),
    );
  }
}
