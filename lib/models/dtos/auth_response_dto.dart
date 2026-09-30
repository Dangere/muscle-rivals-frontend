import 'package:muscle_rivals/models/auth/tokens.dart';
import 'package:muscle_rivals/models/auth/user.dart';
import 'package:muscle_rivals/models/auth/user_preferences.dart';

class AuthResponseDTO {
  final User user;
  final Tokens tokens;
  final bool isVerified;
  final UserPreferences? userPreferences;

  AuthResponseDTO({
    required this.user,
    required this.tokens,
    required this.isVerified,
    this.userPreferences,
  });

  factory AuthResponseDTO.fromJson(Map<String, dynamic> json) {
    print(json);
    return AuthResponseDTO(
      isVerified: json['isVerified'],
      tokens: Tokens.fromJson(json['tokens']),
      user: User.fromJson(json['userData']),
      // userPreferences: UserPreferences.fromJson(json['userPreferences']),
    );
  }
}
