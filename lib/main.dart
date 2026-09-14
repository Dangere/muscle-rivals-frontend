import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:go_router/go_router.dart';
import 'package:muscle_rivals/providers/common_providers.dart';
import 'package:muscle_rivals/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(overrides: await providerOverrides(), child: const MyApp()),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    GoRouter router = ref.watch(routeProvider);

    return MaterialApp.router(
      title: 'Muscle Rivals',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      routerConfig: router,
    );
  }
}

Future<List<Override>> providerOverrides() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  return [sharedPreferencesProvider.overrideWith((ref) => sharedPreferences)];
}
