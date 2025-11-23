import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'database_helper.dart';

class AuthService {
  static const String _staticSalt = 'mainan_anak_2025_salt_key';
  static const String _sessionKey = 'user_session';
  static const String _usernameKey = 'username';

  // Hash password with SHA-256 and static salt
  String hashPassword(String password, String userSalt) {
    final saltedPassword = password + _staticSalt + userSalt;
    final bytes = utf8.encode(saltedPassword);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Generate a simple salt based on timestamp
  String generateSalt() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Register new user
  Future<bool> register(String username, String password) async {
    try {
      // Check if username already exists
      final existingUser = await DatabaseHelper.instance.getUserByUsername(username);
      if (existingUser != null) {
        return false; // Username already taken
      }

      // Create new user
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
      print('Register error: $e');
      return false;
    }
  }

  // Login user
  Future<bool> login(String username, String password) async {
    try {
      final user = await DatabaseHelper.instance.getUserByUsername(username);
      if (user == null) {
        return false; // User not found
      }

      // Verify password
      final passwordHash = hashPassword(password, user.salt);
      if (passwordHash != user.passwordHash) {
        return false; // Wrong password
      }

      // Save session
      await saveSession(username);
      return true;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // Save user session
  Future<void> saveSession(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sessionKey, true);
    await prefs.setString(_usernameKey, username);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_sessionKey) ?? false;
  }

  // Get current username
  Future<String?> getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove(_usernameKey);
  }
}
