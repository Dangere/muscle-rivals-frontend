import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muscle_rivals/enums/connection_status.dart';
import 'package:muscle_rivals/providers/multiplayer_provider.dart';
import 'package:signalr_netcore/hub_connection.dart';

class MultiplayerScreen extends ConsumerStatefulWidget {
  const MultiplayerScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MultiplayerScreenState();
}

class _MultiplayerScreenState extends ConsumerState<MultiplayerScreen> {
  @override
  Widget build(BuildContext context) {
    HubConnectionState connectionStatus = ref.watch(multiplayerProvider);

    Icon connectionIcon = switch (connectionStatus) {
      HubConnectionState.Connected => const Icon(Icons.check),
      HubConnectionState.Connecting => const Icon(Icons.sync),
      HubConnectionState.Disconnected => const Icon(Icons.close),
      HubConnectionState.Disconnecting => const Icon(Icons.sync),
      HubConnectionState.Reconnecting => const Icon(Icons.sync),
    };

    return Placeholder();
  }
}
