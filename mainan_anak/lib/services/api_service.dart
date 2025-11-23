import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/motor_baru.dart';
import '../models/exchange_rate.dart';

class ApiService {
  static const String mockApiBaseUrl = 'https://69063273ee3d0d14c13529b5.mockapi.io';
  static const String exchangeRateApiUrl = 'https://api.frankfurter.app/latest';

  // Fetch motor baru from MockAPI
  Future<List<MotorBaru>> getMotorBaru() async {
    try {
      final response = await http.get(
        Uri.parse('$mockApiBaseUrl/CHILDSPLAY'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => MotorBaru.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load motor baru: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching motor baru: $e');
      rethrow;
    }
  }

  // Fetch exchange rates (IDR to USD, EUR, JPY)
  Future<ExchangeRate> getExchangeRates() async {
    try {
      // Frankfurter API - convert from IDR to other currencies
      final response = await http.get(
        Uri.parse('$exchangeRateApiUrl?from=IDR&to=USD,EUR,JPY'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ExchangeRate.fromJson(jsonData);
      } else {
        throw Exception('Failed to load exchange rates: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching exchange rates: $e');
      // Return default rates if API fails
      return ExchangeRate(
        usd: 0.000063, // Approximate IDR to USD
        eur: 0.000058, // Approximate IDR to EUR
        jpy: 0.0095,   // Approximate IDR to JPY
      );
    }
  }

  // Convert IDR to other currency
  Future<double> convertCurrency(double idrAmount, String targetCurrency) async {
    try {
      final rates = await getExchangeRates();
      return rates.convertFromIdr(idrAmount, targetCurrency);
    } catch (e) {
      print('Error converting currency: $e');
      return idrAmount;
    }
  }
}
