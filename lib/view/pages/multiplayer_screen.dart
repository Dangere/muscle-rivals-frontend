import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muscle_rivals/providers/common_providers.dart';
import 'package:muscle_rivals/providers/multiplayer_provider.dart';
import 'package:muscle_rivals/utils/snack_bar_alerts.dart';
import 'package:muscle_rivals/view/widgets/hub_connection_status.dart';

class MultiplayerScreen extends ConsumerStatefulWidget {
  const MultiplayerScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MultiplayerScreenState();
}

class _MultiplayerScreenState extends ConsumerState<MultiplayerScreen> {
  void connectToHub() {
    ref.read(multiplayerProvider.notifier).connectToHub();
  }

  @override
  void initState() {
    Future.microtask(() {
      connectToHub();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(multiplayerProvider, (previous, next) {
      if (next.error != null) {
        ref.read(loggerProvider).e(next.error!);
        SnackBarAlerts.showErrorSnackBar(next.error!, context);
      }
    });

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HubConnectioStatus(),

          ElevatedButton(onPressed: connectToHub, child: Icon(Icons.sync)),
        ],
      ),
    );
  }
}
