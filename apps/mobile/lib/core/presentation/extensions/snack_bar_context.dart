import 'package:flutter/material.dart';

extension SnackBarContext on BuildContext {
  /// Shows [message] at the bottom, replacing any message already there.
  void showAppSnackBar(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
