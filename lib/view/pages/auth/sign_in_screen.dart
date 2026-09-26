import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muscle_rivals/providers/auth_provider.dart';
import 'package:muscle_rivals/providers/common_providers.dart';
import 'package:muscle_rivals/utils/snack_bar_alerts.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print("object");

    void signin(int i) {
      ref
          .read(authProvider.notifier)
          .loginWithEmailAndPassword(
            email: "user$i@gmail.com",
            password: "123123123",
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
      appBar: AppBar(title: const Text("Sign in")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => signin(0),
              child: const Text("Sign in"),
            ),
            ElevatedButton(
              onPressed: () => signin(1),
              child: const Text("Sign in"),
            ),
          ],
        ),
      ),
    );
  }
}
