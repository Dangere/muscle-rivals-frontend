import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:muscle_rivals/constants.dart';
import 'package:muscle_rivals/models/dtos/auth_response_dto.dart';
import 'package:muscle_rivals/models/tokens.dart';
import 'package:muscle_rivals/models/user_preferences.dart';

/// Class used to do remote API CRUD operations for auth
class AuthRepository {
  final Dio _dio;
  final Dio _unauthenticatedDio;
  AuthRepository({required Dio dio, required Dio unauthenticatedDio})
    : _dio = dio,
      _unauthenticatedDio = unauthenticatedDio;

  Future<AuthResponseDTO> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Getting the login response
    final response = await _dio
        .post(
          "${Constants.BASE_API_URL}/auth/login",
          data: {"Email": email, "Password": password},
        )
        .timeout(const Duration(seconds: 20));

    AuthResponseDTO authResponse = AuthResponseDTO.fromJson(response.data);

    // Returning the auth response
    return authResponse;
  }

  Future<AuthResponseDTO> registerWithEmailAndPassword({
    required String email,
    required String username,
    required String firstName,
    required String lastName,
    required String password,
    UserPreferences? preferences,
  }) async {
    // Getting the register response
    final response = await _dio
        .post(
          "${Constants.BASE_API_URL}/auth/register",
          data: {
            "Email": email,
            "Username": username,
            "Password": password,
            "FirstName": firstName,
            "LastName": lastName,
            if (preferences != null)
              "preferences": {
                "darkMode": preferences.darkMode,
                "languageCode": preferences.locale.languageCode,
              },
          },
        )
        .timeout(const Duration(seconds: 20));

    AuthResponseDTO authResponse = AuthResponseDTO.fromJson(response.data);

    // Returning the auth response
    return authResponse;
  }

  Future<AuthResponseDTO> loginWithGoogle(String idToken) async {
    // Getting the login response
    final response = await _dio
        .post(
          "${Constants.BASE_API_URL}/auth/login/google",
          data: jsonEncode(idToken),
          options: Options(contentType: 'application/json'),
        )
        .timeout(const Duration(seconds: 20));

    AuthResponseDTO authResponse = AuthResponseDTO.fromJson(response.data);

    // Returning the auth response
    return authResponse;
  }

  // We could first ask for additional information from the user before registering
  Future<AuthResponseDTO> registerWithGoogle(
    String idToken, {
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    UserPreferences? preferences,
  }) async {
    // Getting the register response
    final response = await _dio
        .post(
          "${Constants.BASE_API_URL}/auth/register/google",
          data: {
            "IdToken": idToken,
            "FirstName": firstName,
            "LastName": lastName,
            "Username": username,
            "Password": password,
            if (preferences != null)
              "preferences": {
                "darkMode": preferences.darkMode,
                "languageCode": preferences.locale.languageCode,
              },
          },
        )
        .timeout(const Duration(seconds: 20));

    AuthResponseDTO authResponse = AuthResponseDTO.fromJson(response.data);

    // Returning the auth response
    return authResponse;
  }

  Future<Tokens> refreshAccessToken({required Tokens tokens}) async {
    // Using a different instance of Dio because the main instance is calling this method
    // To refresh tokens

    final response = await _unauthenticatedDio
        .post(
          "${Constants.BASE_API_URL}/auth/refresh-token",
          data: {
            "RefreshToken": tokens.refreshToken,
            "AccessToken": tokens.accessToken,
          },
        )
        .timeout(const Duration(seconds: 10));

    String fetchedAccessToken = response.data['accessToken'] as String;
    String fetchedRefreshToken = response.data['refreshToken'] as String;

    return Tokens(
      accessToken: fetchedAccessToken,
      refreshToken: fetchedRefreshToken,
    );
  }

  Future<void> sendVerificationEmail() async {
    await _dio
        .post("${Constants.BASE_API_URL}/auth/verify/send")
        .timeout(const Duration(seconds: 10));
  }

  Future<bool> checkVerificationStatus() async {
    final response = await _dio
        .post("${Constants.BASE_API_URL}/auth/verify/status")
        .timeout(const Duration(seconds: 10));

    return response.data as bool;
  }

  Future<void> requestPasswordReset(String email) async {
    await _dio
        .post("${Constants.BASE_API_URL}/auth/password-reset/send/$email")
        .timeout(const Duration(seconds: 20));
  }
}
