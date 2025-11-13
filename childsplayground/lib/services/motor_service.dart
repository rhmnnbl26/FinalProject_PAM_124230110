// lib/services/motor_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/motor_model.dart';

class MotorService {
  static const String _baseUrl = 'https://69063273ee3d0d14c13529b5.mockapi.io/CHILDSPLAY';

  /// fetch semua motor dari MockAPI
  static Future<List<MotorModel>> fetchMotors() async {
    final uri = Uri.parse(_baseUrl);
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final List<dynamic> body = json.decode(res.body);
      return body.map((e) => MotorModel.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Gagal mengambil data motor: ${res.statusCode}');
    }
  }
}
