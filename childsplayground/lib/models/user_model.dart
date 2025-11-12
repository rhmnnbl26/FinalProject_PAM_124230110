import 'package:hive/hive.dart';

part 'user_model.g.dart'; // nanti di-generate pakai build_runner

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  String password; // disimpan dalam bentuk hash

  @HiveField(2)
  String namaLengkap;

  @HiveField(3)
  String alamat;

  @HiveField(4)
  String noTelepon;

  @HiveField(5)
  String? email;

  UserModel({
    required this.username,
    required this.password,
    required this.namaLengkap,
    required this.alamat,
    required this.noTelepon,
    this.email,
  });
}
