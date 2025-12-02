import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/motor_baru.dart';
import '../models/exchange_rate.dart';
import '../models/apparel.dart';
import '../models/aksesoris.dart';

class ApiService {
  static const String mockApiBaseUrl = 'https://69063273ee3d0d14c13529b5.mockapi.io';
  static const String exchangeRateApiUrl = 'https://api.frankfurter.app/latest';
  static const String apparelApiUrl = 'https://692f397f91e00bafccd6f9b3.mockapi.io/apparel';
  static const String aksesorisApiUrl = 'https://692f397f91e00bafccd6f9b3.mockapi.io/aksesoris';

  // Fetch motor baru from MockAPI
  Future<List<MotorBaru>> getMotorBaru() async {
    try {
      final url = '$mockApiBaseUrl/motor';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => MotorBaru.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load motor baru: ${response.statusCode}');
      }
    } catch (e) {
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
      return idrAmount;
    }
  }

  // Fetch motors by brand
  Future<List<MotorBaru>> getMotorByBrand(String brand) async {
    try {
      final allMotors = await getMotorBaru();
      return allMotors.where((motor) => motor.brand.toLowerCase() == brand.toLowerCase()).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Convert USD to other currencies
  Future<double> convertFromUsd(double usdAmount, String targetCurrency) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.frankfurter.app/latest?from=USD&to=$targetCurrency'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final rate = jsonData['rates'][targetCurrency];
        return usdAmount * rate;
      } else {
        throw Exception('Failed to convert currency');
      }
    } catch (e) {
      // Default rates if API fails
      switch (targetCurrency) {
        case 'IDR': return usdAmount * 15800;
        case 'EUR': return usdAmount * 0.92;
        case 'JPY': return usdAmount * 149.5;
        default: return usdAmount;
      }
    }
  }

  // Fetch apparel from MockAPI
  Future<List<Apparel>> getApparel() async {
    try {
      
      final response = await http.get(
        Uri.parse(apparelApiUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Apparel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load apparel: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Fetch aksesoris from MockAPI
  Future<List<Aksesoris>> getAksesoris() async {
    try {
      
      final response = await http.get(
        Uri.parse(aksesorisApiUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Aksesoris.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load aksesoris: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
