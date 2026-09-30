import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:muscle_rivals/models/auth/tokens.dart';
import 'package:muscle_rivals/models/auth/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _shardPreferences;

  StorageService({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences shardPreferences,
  }) : _shardPreferences = shardPreferences,
       _secureStorage = secureStorage;

  Future<void> saveUser(User user) async {
    await _shardPreferences.setString('user', jsonEncode(user.toJson()));
  }

  Future<User?> loadUser() async {
    String? userJson = _shardPreferences.getString('user');

    if (userJson == null) return null;
    Map<String, dynamic> json = jsonDecode(userJson);
    return User.fromJson(json);
  }

  Future<void> saveTokens(Tokens tokens) async {
    await _secureStorage.write(key: 'accessToken', value: tokens.accessToken);
    await _secureStorage.write(key: 'refreshToken', value: tokens.refreshToken);
  }

  Future<Tokens?> getTokens() async {
    String? accessToken = await _secureStorage.read(key: 'accessToken');
    String? refreshToken = await _secureStorage.read(key: 'refreshToken');
    if (accessToken != null && refreshToken != null) {
      return Tokens(accessToken: accessToken, refreshToken: refreshToken);
    } else {
      return null;
    }
  }
}
