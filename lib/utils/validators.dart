import 'package:email_validator/email_validator.dart';

class Validators {
  static bool validateEmail(String email) {
    return EmailValidator.validate(email);
  }

  static bool validatePassword(String password) {
    //password must be between 6 and 16 characters
    if (password.length > 32 || password.length < 6) return false;

    return true;
  }

  static bool validateUsername(String username) {
    final regex = RegExp(r'^[a-zA-Z0-9]{3,20}$');
    return regex.hasMatch(username);
  }

  static bool validateName(String name) {
    final regex = RegExp(r"^[^';<>\s\\]{3,20}$");
    return regex.hasMatch(name);
  }
}
