import 'package:flutter/foundation.dart';
import 'package:muscle_rivals/enums/exercise_type.dart';
import 'package:muscle_rivals/enums/match_state.dart';
import 'package:muscle_rivals/models/auth/user.dart';
import 'package:muscle_rivals/models/game/game_modes.dart';

class GameMatch {
  final int roomId;
  final List<User> players;
  final List<int> scores;
  final DateTime date;
  final ExerciseType exerciseType;
  final GameMode gameMode;

  // Matches start paused
  final MatchState state;

  GameMatch({
    required this.roomId,
    required this.players,
    required this.date,
    required this.exerciseType,
    required this.gameMode,
    List<int>? scores,
    required this.state,
  }) : scores = List.from(scores ?? const [0, 0]);

  GameMatch setPlayerScore(int userId, int newScore) {
    int index = players.indexWhere((element) => element.id == userId);
    List<int> newScores = List.from(scores);
    newScores[index] = newScore;

    return GameMatch(
      roomId: roomId,
      players: players,
      date: date,
      exerciseType: exerciseType,
      gameMode: gameMode,
      scores: newScores,
      state: state,
    );
  }

  GameMatch pause(bool pause) {
    return GameMatch(
      roomId: roomId,
      players: players,
      date: date,
      exerciseType: exerciseType,
      gameMode: gameMode,
      scores: scores,
      state: pause ? MatchState.paused : MatchState.inProgress,
    );
  }

  factory GameMatch.fromJson(Map<String, dynamic> json) {
    print(json);

    return GameMatch(
      roomId: json['roomId'],
      players: List<User>.from(json['players'].map((x) => User.fromJson(x))),
      date: DateTime.parse(json['creationDate']),
      exerciseType: ExerciseType.values[json['exerciseType']],
      gameMode: GameMode.fromTypedJson(json['gameMode']),
      state: MatchState.paused,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameMatch &&
          runtimeType == other.runtimeType &&
          roomId == other.roomId &&
          date == other.date &&
          state == other.state &&
          exerciseType == other.exerciseType &&
          listEquals(players, other.players) &&
          listEquals(scores, other.scores);

  @override
  int get hashCode => Object.hash(
    roomId,
    date,
    exerciseType,
    Object.hashAll(players),
    Object.hashAll(scores),
  );
}
