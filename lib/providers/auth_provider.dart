import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muscle_rivals/error_management/app_error_code.dart';
import 'package:muscle_rivals/models/auth_state.dart';
import 'package:muscle_rivals/models/dtos/auth_response_dto.dart';
import 'package:muscle_rivals/models/tokens.dart';
import 'package:muscle_rivals/models/user.dart';
import 'package:muscle_rivals/providers/common_providers.dart';
import 'package:muscle_rivals/repositories/auth_repository.dart';
import 'package:muscle_rivals/utils/result.dart';

class AuthNotifier extends AsyncNotifier<AuthState> {
  Tokens? _tokens;

  Tokens? get tokens => _tokens;

  // void expireAccessToken() {
  //   if (_tokens == null) {
  //     return;
  //   }

  //   _tokens = _tokens!.copyWith(
  //     accessToken:
  //         'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJlZTk5ZjNjYy0wNmUwLTQwMjEtOGUyNS0zNWJlNmY4ZTUzZDUiLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJVc2VyIiwiaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvd3MvMjAwNS8wNS9pZGVudGl0eS9jbGFpbXMvbmFtZWlkZW50aWZpZXIiOiIzIiwiaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvd3MvMjAwNS8wNS9pZGVudGl0eS9jbGFpbXMvbmFtZSI6InRlc3QiLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL2V4cGlyYXRpb24iOiI5LzE0LzIwMjYgMTI6MDI6MjQgQU0iLCJleHAiOjE3ODkzNDQxNDQsImlzcyI6IlN5bmNvcmFCYWNrZW5kIiwiYXVkIjoiU3luY29yYUZyb250ZW5kIn0.DK_sOgpYxsLwADYfr8Fp0th2RsRGYhpVdUzLIJr0NJU',
  //   );
  // }

  // void expireAccessAndRefreshToken() {
  //   if (_tokens == null) {
  //     return;
  //   }

  //   _tokens = _tokens!.copyWith(
  //     refreshToken: 'OWqt7uaisnzrUSRbxsHWGhXmpZN7Yis55461aIJPVuY=',
  //     accessToken:
  //         'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJlZTk5ZjNjYy0wNmUwLTQwMjEtOGUyNS0zNWJlNmY4ZTUzZDUiLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJVc2VyIiwiaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvd3MvMjAwNS8wNS9pZGVudGl0eS9jbGFpbXMvbmFtZWlkZW50aWZpZXIiOiIzIiwiaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvd3MvMjAwNS8wNS9pZGVudGl0eS9jbGFpbXMvbmFtZSI6InRlc3QiLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL2V4cGlyYXRpb24iOiI5LzE0LzIwMjYgMTI6MDI6MjQgQU0iLCJleHAiOjE3ODkzNDQxNDQsImlzcyI6IlN5bmNvcmFCYWNrZW5kIiwiYXVkIjoiU3luY29yYUZyb250ZW5kIn0.DK_sOgpYxsLwADYfr8Fp0th2RsRGYhpVdUzLIJr0NJU',
  //   );
  // }

  void loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (state == const AsyncValue.loading()) return;
    state = await AsyncValue.guard(() async {
      AuthResponseDTO authResponse = await ref
          .read(authRepositoryProvider)
          .loginWithEmailAndPassword(email: email, password: password);

      _tokens = authResponse.tokens;
      await ref.read(storageProvider).saveUser(authResponse.user);
      await ref.read(storageProvider).saveTokens(authResponse.tokens);

      return AuthAuthenticated(authResponse.user.id, authResponse.isVerified);
    });
  }

  void registerWithEmailAndPassword({
    required String email,
    required String username,
    required String firstName,
    required String lastName,
    required String password,
  }) async {
    if (state == const AsyncValue.loading()) return;

    state = await AsyncValue.guard(() async {
      AuthResponseDTO authResponse = await ref
          .read(authRepositoryProvider)
          .registerWithEmailAndPassword(
            email: email,
            username: username,
            firstName: firstName,
            lastName: lastName,
            password: password,
            preferences: null,
          );

      _tokens = authResponse.tokens;

      await ref.read(storageProvider).saveUser(authResponse.user);
      await ref.read(storageProvider).saveTokens(authResponse.tokens);

      return AuthAuthenticated(authResponse.user.id, authResponse.isVerified);
    });
  }

  void logout() {
    _tokens = null;
    state = AsyncValue.data(const AuthUnauthenticated());
  }

  Future<Result<void>> refreshTokens() async {
    if (_tokens == null) {
      return Result.failureCode(
        AppErrorCode.HTTP_UNAUTHORIZED,
        StackTrace.current,
      );
    }

    ref.read(loggerProvider).w("Refreshing tokens");

    Result<Tokens> result = await Result.wrapAsync(
      () async => await ref
          .read(authRepositoryProvider)
          .refreshAccessToken(tokens: _tokens!),
    );

    // If the result is not a success and the error code is INVALID_TOKEN, then we logout
    if (result.isSuccess) {
      _tokens = result.data!;
      await ref.read(storageProvider).saveTokens(result.data!);
      ref.read(loggerProvider).w("Refresh tokens updated");
    } else if (result.error!.errorCode == AppErrorCode.INVALID_TOKEN) {
      ref.read(loggerProvider).w("Refresh token expired, logging out");

      logout();
    } else {
      ref
          .read(loggerProvider)
          .e("Failed to refresh tokens ${result.error!.errorCode}");
    }

    return result;
  }

  @override
  FutureOr<AuthState> build() async {
    Tokens? storedTokens = await ref.read(storageProvider).getTokens();
    User? storedUser = await ref.read(storageProvider).loadUser();

    ref.read(loggerProvider).i("Stored tokens: $storedTokens");
    ref.read(loggerProvider).i("Stored user: $storedUser");

    if (storedTokens != null && storedUser != null) {
      _tokens = storedTokens;
      return AuthAuthenticated(storedUser.id, false);
    } else if (storedUser != null) {
      return AuthGuest();
    }

    return const AuthUnauthenticated();
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    dio: ref.read(dioProvider),
    unauthenticatedDio: ref.read(unauthenticatedDioProvider),
  );
});

final isLoggedProvider = Provider<bool>((ref) {
  AuthState authState =
      ref.watch(authProvider).value ?? const AuthUnauthenticated();
  return authState.isAuthenticated;
});
