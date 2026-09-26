import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muscle_rivals/constants.dart';
import 'package:muscle_rivals/error_management/app_error_code.dart';
import 'package:muscle_rivals/providers/auth_provider.dart';
import 'package:muscle_rivals/providers/common_providers.dart';
import 'package:muscle_rivals/repositories/matchmaking_repository.dart';
import 'package:muscle_rivals/utils/result.dart';
import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

class MultiplayerNotifier extends AsyncNotifier<void> {
  Future<Result<void>> queueIntoMatchmaking() async {
    return Result.wrapAsync(
      () async =>
          await ref.read(matchmakingRepositoryProvider).queueIntoMatchmaking(),
    );
  }

  Future<void> connectToHub() async {
    if (ref.read(hubProvider).state != HubConnectionState.Disconnected) return;

    state = AsyncValue.loading();
    ref.read(loggerProvider).i("Connecting to hub");
    Result<void> connectResult = await Result.wrapAsync(
      () async => await ref.read(hubProvider).start(),
    );

    if (!connectResult.isSuccess) {
      // If we got an authorized error, it might mean our token expired and we need to refresh it
      if (connectResult.error!.errorCode == AppErrorCode.HTTP_UNAUTHORIZED) {
        ref
            .read(loggerProvider)
            .e(
              "Failed to connect to hub due to unauthorized error, trying to refresh tokens",
            );

        // Request a new access token
        Result refreshResult = await ref
            .read(authProvider.notifier)
            .refreshTokens();

        // If the result is a success, we can retry the connection
        if (refreshResult.isSuccess) {
          await connectToHub();
          return;
        } else {
          ref.read(loggerProvider).e("Failed to refresh tokens");
          state = AsyncValue.error(
            refreshResult.error!.exception!,
            refreshResult.error!.stackTrace,
          );
          return;
        }
      }

      ref.read(loggerProvider).e("Failed to connect to hub");
      state = AsyncValue.error(
        connectResult.error!.exception!,
        connectResult.error!.stackTrace,
      );
      return;
    }
    ref.read(loggerProvider).i("Connected to hub");

    state = AsyncValue.data(null);
  }

  void _dispose() {
    ref.read(hubProvider).stop();
  }

  @override
  FutureOr<void> build() async {
    ref.listen(isLoggedProvider, (previous, next) {
      if (!next) {
        _dispose();
      }
    });

    ref.onDispose(() {
      _dispose();
    });

    return null;
  }
}

final multiplayerProvider = AsyncNotifierProvider<MultiplayerNotifier, void>(
  MultiplayerNotifier.new,
);

// final multiplayerProvider =
//     NotifierProvider<MultiplayerProvider, HubConnectionState>(
//       MultiplayerProvider.new,
//     );

final matchmakingRepositoryProvider = Provider<MatchmakingRepository>((ref) {
  return MatchmakingRepository(dio: ref.read(dioProvider));
});

final hubProvider = Provider<HubConnection>((ref) {
  return HubConnectionBuilder()
      .withUrl(
        "${Constants.BASE_HUB_URL}/game",
        // By default our backend allows connection to persists even if a token expires as long as it was valid at the first handshake
        // This can be overwritten in the backend's signalR options
        options: HttpConnectionOptions(
          accessTokenFactory: () async =>
              ref.read(authProvider.notifier).tokens?.accessToken ?? "",
        ),
      )
      .withAutomaticReconnect(retryDelays: [2000])
      .build();
});
