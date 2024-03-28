import 'package:Bloomee/theme_data/default.dart';
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
            style: const TextStyle(
                color: Default_Theme.primaryColor1, fontSize: 16)),
        duration: duration,
        showCloseIcon: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        closeIconColor: Default_Theme.primaryColor1,
        elevation: 0,
        action: action,
        backgroundColor: Color.fromARGB(255, 16, 15, 15),
      ),
    );
  }
}
