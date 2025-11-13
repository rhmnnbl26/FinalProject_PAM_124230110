import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/motor_model.dart';

class MotorProvider with ChangeNotifier {
  List<MotorModel> _motors = [];
  bool _isLoading = false;
  bool _isError = false;

  List<MotorModel> get motors => _motors;
  bool get isLoading => _isLoading;
  bool get isError => _isError;

  Future<void> fetchMotors() async {
    _isLoading = true;
    _isError = false;
    notifyListeners();

    final url = Uri.parse('https://69063273ee3d0d14c13529b5.mockapi.io/CHILDSPLAY');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        _motors = data.map((e) => MotorModel.fromJson(e)).toList();
      } else {
        _isError = true;
      }
    } catch (e) {
      _isError = true;
    }

    _isLoading = false;
    notifyListeners();
  }
}
