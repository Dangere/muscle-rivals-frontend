import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muscle_rivals/providers/auth_provider.dart';
import 'package:muscle_rivals/providers/common_providers.dart';
import 'package:muscle_rivals/providers/match_provider.dart';
import 'package:muscle_rivals/providers/multiplayer_provider.dart';
import 'package:muscle_rivals/utils/snack_bar_alerts.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  void logoutButton() {
    ref.read(authProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(multiplayerProvider, (previous, next) {
      if (next.asError != null) {
        ref
            .read(loggerProvider)
            .e("${next.error!}, Stacktrace: ${next.stackTrace}");
        SnackBarAlerts.showErrorSnackBar(next.error!, context);
      }
    });

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(onPressed: logoutButton, child: Icon(Icons.logout)),

          ElevatedButton(
            onPressed: () =>
                ref.read(authProvider.notifier).expireAccessToken(),
            child: Text("Expire access token"),
          ),
          ElevatedButton(
            onPressed: () =>
                ref.read(authProvider.notifier).expireAccessAndRefreshToken(),
            child: Text("Expire access and refresh tokens"),
          ),
          ElevatedButton(
            onPressed: () => ref.read(authProvider.notifier).refreshTokens(),
            child: Text("Refresh tokens"),
          ),
          ElevatedButton(
            onPressed: () =>
                ref.read(multiplayerProvider.notifier).queueIntoMatchmaking(),
            child: Text("Queue into matchmaking"),
          ),
          ElevatedButton(
            onPressed: () =>
                ref.read(matchProvider.notifier).debug_startTempMatch(),
            child: Text("Debug: Start empty match"),
          ),
        ],
      ),
    );
  }
}
