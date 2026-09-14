import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muscle_rivals/error_management/error_mapper.dart';
import 'package:muscle_rivals/models/auth_state.dart';
import 'package:muscle_rivals/providers/auth_provider.dart';
import 'package:muscle_rivals/providers/common_providers.dart';
import 'package:muscle_rivals/utils/snack_bar_alerts.dart';

class SignUpScreen extends ConsumerWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void signup() {
      ref
          .read(authProvider.notifier)
          .registerWithEmailAndPassword(
            email: "user@gmail.com",
            password: "123123123",
            firstName: "test",
            lastName: "test",
            username: "test",
          );
    }

    // var authState = ref.watch(authProvider);
    ref.listen(authProvider, (previous, next) {
      if (next.error != null) {
        ref.read(loggerProvider).e(next.error!);

        SnackBarAlerts.showErrorSnackBar(next.error!, context);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Sign up")),
      body: Center(
        child: ElevatedButton(onPressed: signup, child: const Text("Sign up")),
      ),
    );
  }
}
