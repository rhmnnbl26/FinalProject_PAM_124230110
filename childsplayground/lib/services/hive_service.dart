import 'package:hive/hive.dart';
import '../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveLoginSession(String username) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('loggedInUser', username);
}

Future<String?> getLoginSession() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('loggedInUser');
}

Future<void> clearLoginSession() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('loggedInUser');
}


class HiveService {
  final Box<UserModel> _userBox = Hive.box<UserModel>('users');

  Future<void> registerUser(UserModel user) async {
    await _userBox.put(user.username, user);
  }

  UserModel? getUser(String username) {
    return _userBox.get(username);
  }

  bool checkUserExists(String username) {
    return _userBox.containsKey(username);
  }

  Future<void> updateUser(UserModel user) async {
    await _userBox.put(user.username, user);
  }
}
