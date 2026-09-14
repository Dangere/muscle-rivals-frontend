import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LayoutScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const LayoutScaffold({required this.navigationShell, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        indicatorColor: Theme.of(context).colorScheme.primary,
        destinations: [
          NavigationDestination(label: 'Home', icon: Icon(Icons.home)),
          NavigationDestination(label: 'Multiplayer', icon: Icon(Icons.people)),
          NavigationDestination(label: 'Profile', icon: Icon(Icons.person)),
        ],
      ),
    );
  }
}
