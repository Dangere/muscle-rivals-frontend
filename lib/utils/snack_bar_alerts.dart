import 'package:flutter/material.dart';
import 'package:muscle_rivals/error_management/error_mapper.dart';

class SnackBarAlerts {
  static void showSnackBar(String message, BuildContext context) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  static void showSuccessSnackBar(String message, BuildContext context) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  /// Takes an exception and maps it to an errorCode then to a localized text
  static void showErrorSnackBar(Object e, BuildContext context) {
    if (!context.mounted) return;

    String message = ErrorMapper.mapError(e).toString();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  static void showAlertSnackBar(String message, BuildContext context) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.yellowAccent.shade400,
      ),
    );
  }
}
