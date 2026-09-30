import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muscle_rivals/enums/match_state.dart';
import 'package:muscle_rivals/models/game/game_match.dart';
import 'package:muscle_rivals/providers/match_provider.dart';

class MatchScreen extends ConsumerStatefulWidget {
  const MatchScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen> {
  // Shows an end match pop up and quits this screen gracefully
  void showEndMatchPopup() {
    context.pop();
  }

  void quitMatch() {
    ref.read(matchProvider.notifier).quitMatch();
  }

  void countRep() {
    ref.read(matchProvider.notifier).countRep();
  }

  @override
  Widget build(BuildContext context) {
    GameMatch? match = ref.watch(matchProvider);

    // If we at any point, have a null match (means it ended) we show a pop up and quit the match (this) screen
    if (match == null) {
      showEndMatchPopup();
      return Scaffold(body: Center(child: Text("Match ended")));
    }

    return Scaffold(
      appBar: AppBar(title: Text(match.gameMode.toString())),
      body: Center(
        child: Container(
          color: match.state == MatchState.paused ? Colors.red : Colors.green,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Match ID: ${match.roomId}"),
              Container(
                child: Column(
                  children: [
                    // Text("Rep count: ${match.score1}"),
                    Text(
                      "Player 1 ${match.players[0].username}, score: ${match.scores[0]}",
                    ),
                    Text(
                      "Player 2 ${match.players[1].username}, score: ${match.scores[1]}",
                    ),
                  ],
                ),
              ),
              ElevatedButton(onPressed: countRep, child: Text("Count rep")),
              ElevatedButton(onPressed: quitMatch, child: Text("Quit Match")),
            ],
          ),
        ),
      ),
    );
  }
}
