import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("Onboarding")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                // backgroundColor: Colors.green,
              ),
              onPressed: () => context.pushNamed('sign-up'),
              child: Text("Create an account"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                // backgroundColor: Colors.green,
              ),
              onPressed: () => context.pushNamed('sign-in'),
              child: Text("Already a member? Sign in"),
            ),
          ],
        ),
      ),
    );
  }
}
