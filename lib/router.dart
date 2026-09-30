import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:muscle_rivals/models/game/game_match.dart';
import 'package:muscle_rivals/providers/app_init_provider.dart';
import 'package:muscle_rivals/providers/auth_provider.dart';
import 'package:muscle_rivals/providers/common_providers.dart';
import 'package:muscle_rivals/providers/match_provider.dart';
import 'package:muscle_rivals/view/layout_scaffold.dart';
import 'package:muscle_rivals/view/pages/auth/sign_in_screen.dart';
import 'package:muscle_rivals/view/pages/auth/sign_up.screen.dart';
import 'package:muscle_rivals/view/pages/home_screen.dart';
import 'package:muscle_rivals/view/pages/match_screen.dart';
import 'package:muscle_rivals/view/pages/multiplayer_screen.dart';
import 'package:muscle_rivals/view/pages/onboarding_screen.dart';
import 'package:muscle_rivals/view/pages/splash_screen.dart';

class RouteNotifier extends Notifier<GoRouter> {
  @override
  GoRouter build() {
    bool isLogged = ref.watch(isLoggedProvider);

    Logger logger = ref.read(loggerProvider);

    bool runningMatch = ref.watch(
      matchProvider.select((value) => value != null),
    );

    logger.w('Refreshing routes, isLogged: $isLogged');

    const loggedOutPaths = {
      '/onboarding/sign-in',
      '/onboarding/sign-in/reset-password',
      '/onboarding/sign-up',
      '/onboarding/google-sign-up',
      '/onboarding',
    };

    const globalPaths = {'/fatal-error'};

    return GoRouter(
      initialLocation: '/home',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return LayoutScaffold(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  name: 'home',
                  path: '/home',
                  builder: (context, state) {
                    return const HomeScreen();
                  },
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  name: 'multiplayer',
                  path: '/multiplayer',
                  builder: (context, state) {
                    return const MultiplayerScreen();
                  },
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  name: 'profile',
                  path: '/profile',
                  builder: (context, state) {
                    return const MultiplayerScreen();
                  },
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          name: 'splash-screen',
          path: '/splash-screen',
          builder: (context, state) {
            return const SplashScreen();
          },
        ),
        GoRoute(
          name: 'onboarding',
          path: '/onboarding',
          builder: (context, state) {
            return const OnboardingScreen();
          },
          routes: [
            GoRoute(
              name: 'sign-in',
              path: 'sign-in',
              builder: (context, state) {
                return const SignInScreen();
              },
            ),
            GoRoute(
              name: 'sign-up',
              path: 'sign-up',
              builder: (context, state) {
                return const SignUpScreen();
              },
            ),
          ],
        ),

        GoRoute(
          name: 'match',
          path: '/match',
          builder: (context, state) {
            return const MatchScreen();
          },
        ),
      ],

      redirect: (context, state) {
        if (ref.read(appInitializeProvider).isLoading) {
          return '/splash-screen';
        }
        String currentPath = state.fullPath ?? "";

        bool isLoggedOutPath = loggedOutPaths.any((path) {
          return currentPath == path;
        });
        bool inGlobalPath = globalPaths.any((path) {
          return currentPath == path;
        });

        // If we are in a global path (accessed by logged in or logged out users, we let it pass)
        if (inGlobalPath) {
          return null;
        }

        // If we are not logged in and we are in a logged in only path we redirect to splash screen
        if (!isLogged && !isLoggedOutPath) {
          logger.d(
            "You were on ${state.fullPath} and getting redirected to login page",
          );
          return '/splash-screen';
        }
        // If we are logged in and we are in a logged out only path we redirect to home
        if (isLogged && isLoggedOutPath) {
          logger.d(
            "You were on ${state.fullPath} and getting redirected to dashboard",
          );
          return '/home';
        }

        // If we have a match running we redirect to the match screen
        if (runningMatch) return '/match';

        return null;
      },
    );
  }
}

final routeProvider = NotifierProvider<RouteNotifier, GoRouter>(
  RouteNotifier.new,
);
