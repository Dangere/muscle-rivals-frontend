import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muscle_rivals/providers/multiplayer_provider.dart';
import 'package:signalr_netcore/hub_connection.dart';

class HubConnectioStatus extends ConsumerWidget {
  const HubConnectioStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder(
      stream: ref.read(hubProvider).stateStream,
      builder: (context, snapshot) {
        HubConnectionState connectionStatus =
            snapshot.data ??
            ref.read(hubProvider).state ??
            HubConnectionState.Disconnected;

        Icon connectionIcon = switch (connectionStatus) {
          HubConnectionState.Connected => const Icon(Icons.check),
          HubConnectionState.Connecting => const Icon(Icons.sync),
          HubConnectionState.Disconnected => const Icon(Icons.close),
          HubConnectionState.Disconnecting => const Icon(Icons.sync),
          HubConnectionState.Reconnecting => const Icon(Icons.sync),
        };

        return connectionIcon;
      },
    );
  }
}
