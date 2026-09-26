import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muscle_rivals/providers/auth_provider.dart';
import 'package:muscle_rivals/providers/multiplayer_provider.dart';

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
        ],
      ),
    );
  }
}
