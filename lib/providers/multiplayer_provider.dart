import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muscle_rivals/constants.dart';
import 'package:muscle_rivals/providers/auth_provider.dart';
import 'package:muscle_rivals/providers/common_providers.dart';
import 'package:muscle_rivals/repositories/matchmaking_repository.dart';
import 'package:muscle_rivals/utils/result.dart';
import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

class MultiplayerProvider extends Notifier<HubConnectionState> {
  Future<Result<void>> queueIntoMatchmaking() async {
    return Result.wrapAsync(
      () async =>
          await ref.read(matchmakingRepositoryProvider).queueIntoMatchmaking(),
    );
  }

  // Future<Result<void>> cancelQueue() async {
  //   return Result.wrapAsync(() async => await ref
  //       .read(matchmakingRepositoryProvider)
  //       .cancelQueueFromMatchmaking());
  // }

  Future<Result<void>> connectToHub() async {
    return Result.wrapAsync(() async => await ref.read(hubProvider).start());
  }

  @override
  build() {
    ref.read(hubProvider).stateStream.listen((event) {
      state = event;
    });

    return HubConnectionState.Connecting;
  }
}

final multiplayerProvider =
    NotifierProvider<MultiplayerProvider, HubConnectionState>(
      MultiplayerProvider.new,
    );

final matchmakingRepositoryProvider = Provider<MatchmakingRepository>((ref) {
  return MatchmakingRepository(dio: ref.read(dioProvider));
});

final hubProvider = Provider<HubConnection>((ref) {
  return HubConnectionBuilder()
      .withUrl(
        "${Constants.BASE_HUB_URL}/matchmaking",
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
