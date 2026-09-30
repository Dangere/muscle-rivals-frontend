import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muscle_rivals/models/game/game_match.dart';
import 'package:muscle_rivals/providers/common_providers.dart';
import 'package:muscle_rivals/providers/multiplayer_provider.dart';

class MatchNotifier extends Notifier<GameMatch?> {
  /// Quits match for player
  void quitMatch() {
    if (state == null) return;

    try {
      ref.read(hubProvider).send("QuitMatch");
      ref.read(loggerProvider).i("Player quit match");
    } catch (e) {
      ref.read(loggerProvider).e("Failed to quit match");
    }
    state = null;
  }

  /// Counts rep for the player, but only updates state when the server calls `_countForPlayer`
  void countRep() {
    if (state == null) return;

    try {
      ref.read(hubProvider).send("CountRep");
    } catch (e) {
      ref.read(loggerProvider).e("Failed to count rep");
      state = null;
    }
  }

  /// Triggers by the client when their WebRTC fails and needs reconnection with other player
  void reestablishWebRTC() {
    if (state == null) return;

    try {
      ref.read(hubProvider).send("ReestablishWebRTC");
    } catch (e) {
      ref.read(loggerProvider).e("Failed to reestablish WebRTC");
      state = null;
    }
  }

  /// Gets called by the server to start the match
  void _startMatch(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) return;
    final json = arguments[0] as Map<String, dynamic>;
    final match = GameMatch.fromJson(json);

    ref.read(loggerProvider).i("Match started");
    state = match;
  }

  /// Gets called by the server to end the match, for any reasons that ends the game beside winning/losing
  void _endMatch(List<Object?>? arguments) {
    if (state == null) return;
    if (arguments == null || arguments.isEmpty) return;

    String reason = arguments[0] as String;
    ref.read(loggerProvider).i("Match ended, $reason");
    state = null;
  }

  /// Gets called by the server when the match is concluded
  void _concludeMatch(List<Object?>? arguments) {
    if (state == null) return;
    if (arguments == null || arguments.isEmpty) return;

    int winnerId = arguments[0] as int;
    ref.read(loggerProvider).i("Match ended, winner is $winnerId");
    state = null;
  }

  /// Counts a rep for a user by the server
  void _setRep(List<Object?>? arguments) {
    if (state == null) return;
    if (arguments == null || arguments.isEmpty) return;

    int userId = arguments[0] as int;
    int newScore = arguments[1] as int;

    state = state!.setPlayerScore(userId, newScore);
    ref.read(loggerProvider).i("Player did a rep!");
  }

  /// The server pausing or unpausing a game for any technical reasons such as reestablishing WebRTC or poor connection
  void _pauseGame(List<Object?>? arguments) {
    if (state == null) return;
    if (arguments == null || arguments.isEmpty) return;

    bool pause = arguments[0] as bool;
    state = state!.pause(pause);
    if (pause) {
      ref.read(loggerProvider).i("Match paused");
    } else {
      ref.read(loggerProvider).i("Match resumed");
    }
  }

  @override
  build() {
    ref.read(hubProvider).on("StartMatch", _startMatch);
    ref.read(hubProvider).on("EndMatch", _endMatch);
    ref.read(hubProvider).on("MatchConcluded", _concludeMatch);

    ref.read(hubProvider).on("SetRep", (arguments) => _setRep(arguments));
    ref.read(hubProvider).on("PauseGame", (arguments) => _pauseGame(arguments));

    return null;
  }
}

final matchProvider = NotifierProvider<MatchNotifier, GameMatch?>(
  MatchNotifier.new,
);
