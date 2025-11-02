import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_models.dart';

class HiveService {
  static const String _userBox = 'users';
  static const String _sessionBox = 'session';

  // Inisialisasi Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserModelAdapter());
    await Hive.openBox<UserModel>(_userBox);
    await Hive.openBox<String>(_sessionBox);
  }

  // Tambah user baru
  static Future<bool> registerUser(String username, String password) async {
    var box = Hive.box<UserModel>(_userBox);
    bool exists = box.values.any((user) => user.username == username);
    if (exists) return false; // Username sudah ada

    await box.add(UserModel(username: username, password: password));
    return true;
  }

  // Login user
  static bool loginUser(String username, String password) {
    var box = Hive.box<UserModel>(_userBox);
    var user = box.values.firstWhere(
      (u) => u.username == username && u.password == password,
      orElse: () => UserModel(username: '', password: ''),
    );

    if (user.username.isNotEmpty) {
      Hive.box<String>(_sessionBox).put('loggedInUser', username);
      return true;
    }
    return false;
  }

  // Cek apakah user sedang login
  static bool isLoggedIn() {
    var box = Hive.box<String>(_sessionBox);
    return box.get('loggedInUser') != null;
  }

  // Logout user
  static void logout() {
    Hive.box<String>(_sessionBox).delete('loggedInUser');
  }

  // Ambil nama user aktif
  static String getCurrentUser() {
    return Hive.box<String>(_sessionBox).get('loggedInUser', defaultValue: '')!;
  }
}
