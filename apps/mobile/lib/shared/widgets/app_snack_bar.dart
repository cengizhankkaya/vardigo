import 'package:flutter/material.dart';

/// Shows [message] at the bottom, replacing any message already there.
void showAppSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
