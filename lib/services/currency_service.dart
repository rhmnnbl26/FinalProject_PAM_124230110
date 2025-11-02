import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static const _baseUrl = 'https://api.exchangerate.host/latest?base=IDR&symbols=USD,EUR';

  static Future<Map<String, double>> getRates() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Map<String, dynamic> rates = data['rates'];
        return {
          'IDR': 1.0,
          'USD': rates['USD'] ?? 0.000062,
          'EUR': rates['EUR'] ?? 0.000056,
        };
      } else {
        throw Exception('Failed to load currency rates');
      }
    } catch (e) {
      print("Error fetching rates: $e");
      // fallback ke nilai default
      return {
        'IDR': 1.0,
        'USD': 0.000062,
        'EUR': 0.000056,
      };
    }
  }
}
