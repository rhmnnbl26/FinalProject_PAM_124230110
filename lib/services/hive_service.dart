import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_models.dart';

class HiveService {
  static late Box userBox;

  /// Inisialisasi Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserModelAdapter());
    userBox = await Hive.openBox<UserModel>('userBox');
  }

  /// Enkripsi password dengan SHA256
  static String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  /// Registrasi user baru
  static bool registerUser(String username, String password) {
    if (userBox.containsKey(username)) {
      return false; // Username sudah ada
    }
    final newUser = UserModel(username: username, password: hashPassword(password));
    userBox.put(username, newUser);
    return true;
  }

  /// Login user
  static bool loginUser(String username, String password) {
    final user = userBox.get(username);
    if (user == null) return false;
    final hashed = hashPassword(password);
    if (user.password == hashed) {
      Hive.box('session').put('loggedInUser', username);
      return true;
    }
    return false;
  }

  /// Logout user
  static void logoutUser() {
    final sessionBox = Hive.box('session');
    sessionBox.delete('loggedInUser');
  }

  /// Mengecek apakah user masih login
  static bool isLoggedIn() {
    if (!Hive.isBoxOpen('session')) return false;
    final sessionBox = Hive.box('session');
    return sessionBox.get('loggedInUser') != null;
  }

  /// Mendapatkan username yang sedang login
  static String? getLoggedInUser() {
    if (!Hive.isBoxOpen('session')) return null;
    return Hive.box('session').get('loggedInUser');
  }
}
