import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muscle_rivals/providers/app_init_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  // once the app has been initialized, go to the home page
  void goToApp() async {
    await Future.delayed(Duration(seconds: 1));
    if (mounted) context.pushReplacementNamed('onboarding');
  }

  @override
  Widget build(BuildContext context) {
    var initialize = ref.watch(appInitializeProvider);

    if (!initialize.isLoading && !initialize.hasError) {
      goToApp();
    }

    if (initialize.hasError && initialize.error != null) {
      return Center(child: Text(initialize.error!.toString()));
    }

    return Center(child: const CircularProgressIndicator());
  }
}
