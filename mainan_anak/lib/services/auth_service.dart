import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'database_helper.dart';

class AuthService {
  static const String _sessionKey = 'user_session';
  static const String _usernameKey = 'username';
  static const String _userIdKey = 'user_id';

  String hashPassword(String password, String userSalt) {
    final saltedPassword = password + userSalt;
    final bytes = utf8.encode(saltedPassword);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Encode(saltBytes);
  }

  String? validatePassword(String password) {
    if (password.length < 6) {
      return 'Password minimal 6 karakter';
    }
    if (!password.contains(RegExp(r'[A-Za-z]'))) {
      return 'Password harus mengandung huruf';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password harus mengandung angka';
    }
    return null;
  }

  Future<bool> register(String username, String password) async {
    try {
      final passwordError = validatePassword(password);
      if (passwordError != null) {
        throw Exception(passwordError);
      }

      final existingUser = await DatabaseHelper.instance.getUserByUsername(
        username,
      );
      if (existingUser != null) {
        return false;
      }

      final userSalt = generateSalt();
      final passwordHash = hashPassword(password, userSalt);

      final user = User(
        username: username,
        passwordHash: passwordHash,
        salt: userSalt,
      );

      await DatabaseHelper.instance.createUser(user);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      final user = await DatabaseHelper.instance.getUserByUsername(username);
      if (user == null) {
        return false;
      }

      final passwordHash = hashPassword(password, user.salt);

      if (passwordHash != user.passwordHash) {
        return false;
      }

      await saveSession(username);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> saveSession(String username) async {
    final prefs = await SharedPreferences.getInstance();

    final user = await DatabaseHelper.instance.getUserByUsername(username);

    await prefs.setBool(_sessionKey, true);
    await prefs.setString(_usernameKey, username);
    if (user?.id != null) {
      await prefs.setInt(_userIdKey, user!.id!);
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_sessionKey) ?? false;
  }

  Future<String?> getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_userIdKey);
  }

  Future<bool> deleteAccount() async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) {
        return false;
      }

      await DatabaseHelper.instance.deleteUserAccount(userId);

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      return true;
    } catch (e) {
      return false;
    }
  }
}
