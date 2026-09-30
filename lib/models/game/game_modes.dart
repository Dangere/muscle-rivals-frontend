import 'package:muscle_rivals/enums/game_mode_type.dart';

sealed class GameMode {
  final int maxLifeTimeMinutes;

  GameMode({required this.maxLifeTimeMinutes});

  factory GameMode.fromTypedJson(Map<String, dynamic> json) {
    GameModeType gameModeType = GameModeType.values[json['typeIndex']];

    GameMode gameMode = switch (gameModeType) {
      GameModeType.timeLimited => TimeLimitedGameMode.fromJson(json),
      GameModeType.maxReps => MaxRepsGameMode.fromJson(json),
    };
    return gameMode;
  }
}

class TimeLimitedGameMode extends GameMode {
  final int timeLimitSeconds;
  TimeLimitedGameMode({
    required super.maxLifeTimeMinutes,
    required this.timeLimitSeconds,
  });

  factory TimeLimitedGameMode.fromJson(Map<String, dynamic> json) =>
      TimeLimitedGameMode(
        maxLifeTimeMinutes: json['maxLifeTimeMinutes'],
        timeLimitSeconds: json['timeLimitSeconds'],
      );
}

class MaxRepsGameMode extends GameMode {
  final int maxReps;
  MaxRepsGameMode({required super.maxLifeTimeMinutes, required this.maxReps});

  factory MaxRepsGameMode.fromJson(Map<String, dynamic> json) =>
      MaxRepsGameMode(
        maxLifeTimeMinutes: json['maxLifeTimeMinutes'],
        maxReps: json['maxReps'],
      );
}

extension GameModeX on GameMode {
  TimeLimitedGameMode? get isTimeLimited =>
      this is TimeLimitedGameMode ? this as TimeLimitedGameMode : null;

  MaxRepsGameMode? get isMaxReps =>
      this is MaxRepsGameMode ? this as MaxRepsGameMode : null;
}
