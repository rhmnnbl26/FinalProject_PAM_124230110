import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/motor_model.dart';

class MotorService {
  final String baseUrl =
      'https://69063273ee3d0d14c13529b5.mockapi.io/CHILDSPLAY'; // Ganti dengan URL kamu

  Future<List<MotorModel>> getMotors() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => MotorModel.fromJson(item)).toList();
    } else {
      throw Exception('Gagal mengambil data motor');
    }
  }
}
