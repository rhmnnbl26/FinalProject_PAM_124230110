import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/motor_baru.dart';
import '../models/exchange_rate.dart';
import '../models/apparel.dart';
import '../models/aksesoris.dart';

/// ============================================================================
/// API SERVICE - CENTRAL API MANAGEMENT
/// ============================================================================
/// File ini adalah PUSAT semua API call dalam aplikasi.
/// 
/// PENTING UNTUK PRESENTASI:
/// - Ada 4 API berbeda yang digunakan (sesuai ketentuan project)
/// - Semua API menggunakan HTTP GET (read data)
/// - Error handling dengan try-catch dan fallback values
/// 
/// TEKNOLOGI:
/// - Package: http ^1.1.0 untuk HTTP requests
/// - JSON parsing menggunakan dart:convert
/// - Async/Await untuk asynchronous operations
/// ============================================================================

class ApiService {
  // ========== API BASE URLs ==========
  // PRESENTASI: Jelaskan bahwa kita pakai 4 API berbeda
  
  /// API #1: MockAPI untuk data motor baru (katalog resmi)
  /// URL ini menyediakan data motor dari berbagai brand
  static const String mockApiBaseUrl = 'https://69063273ee3d0d14c13529b5.mockapi.io';
  
  /// API #2: Frankfurter API untuk real-time currency exchange
  /// Free API untuk konversi mata uang (IDR → USD, EUR, JPY)
  static const String exchangeRateApiUrl = 'https://api.frankfurter.app/latest';
  
  /// API #3: MockAPI untuk katalog apparel (jaket, celana motor, dll)
  static const String apparelApiUrl = 'https://692f397f91e00bafccd6f9b3.mockapi.io/apparel';
  
  /// API #4: MockAPI untuk katalog aksesoris (helm, sarung tangan, dll)
  static const String aksesorisApiUrl = 'https://692f397f91e00bafccd6f9b3.mockapi.io/aksesoris';

  // ========== API CALL #1: Fetch Motor Baru ==========
  /// FLOW DATA UNTUK PRESENTASI:
  /// 1. User buka screen "Harga Motor Baru"
  /// 2. Method ini dipanggil
  /// 3. HTTP GET request ke MockAPI
  /// 4. Response JSON di-decode
  /// 5. JSON di-parse jadi List<MotorBaru> objects
  /// 6. Return ke UI untuk ditampilkan
  /// 
  /// ERROR HANDLING:
  /// - Timeout 10 detik (prevent hanging)
  /// - Status code validation (200 = success)
  /// - Try-catch untuk network errors
  Future<List<MotorBaru>> getMotorBaru() async {
    try {
      final url = '$mockApiBaseUrl/motor';
      
      // HTTP GET request dengan timeout
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10)); // Prevent infinite loading

      if (response.statusCode == 200) {
        // SUCCESS: Parse JSON response
        final List<dynamic> jsonData = json.decode(response.body);
        
        // PENTING: Convert JSON array → List<MotorBaru> objects
        // Menggunakan .map() untuk transform setiap item
        return jsonData.map((json) => MotorBaru.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load motor baru: ${response.statusCode}');
      }
    } catch (e) {
      rethrow; // Pass error ke UI untuk ditampilkan
    }
  }

  // ========== API CALL #2: Real-Time Currency Exchange ==========
  /// FITUR UNGGULAN UNTUK PRESENTASI:
  /// - Real-time exchange rates dari API eksternal
  /// - Convert harga motor dari IDR ke USD, EUR, JPY
  /// - Fallback ke default rates jika API error (robust design)
  /// 
  /// FLOW:
  /// 1. Request ke Frankfurter API dengan query params: from=IDR&to=USD,EUR,JPY
  /// 2. Get latest rates
  /// 3. Parse response → ExchangeRate object
  /// 4. Jika error → gunakan default rates (hardcoded)
  Future<ExchangeRate> getExchangeRates() async {
    try {
      // Query parameter: from=IDR (base currency) to=USD,EUR,JPY (target currencies)
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
      // FALLBACK MECHANISM: Jika API error, gunakan approximate rates
      // PRESENTASI: Ini menunjukkan robust error handling
      return ExchangeRate(
        usd: 0.000063, // 1 IDR ≈ 0.000063 USD (approximate)
        eur: 0.000058, // 1 IDR ≈ 0.000058 EUR
        jpy: 0.0095,   // 1 IDR ≈ 0.0095 JPY
      );
    }
  }

  // ========== UTILITY: Currency Converter ==========
  /// Helper method untuk convert harga dari IDR ke mata uang lain
  /// Digunakan di UI untuk menampilkan harga dalam berbagai currency
  Future<double> convertCurrency(double idrAmount, String targetCurrency) async {
    try {
      final rates = await getExchangeRates();
      return rates.convertFromIdr(idrAmount, targetCurrency);
    } catch (e) {
      return idrAmount; // Return original jika error
    }
  }

  // ========== FILTER: Motor by Brand ==========
  /// Filter motor berdasarkan brand (Honda, Yamaha, Kawasaki, dll)
  /// TEKNIK: Client-side filtering (fetch all → filter lokal)
  Future<List<MotorBaru>> getMotorByBrand(String brand) async {
    try {
      final allMotors = await getMotorBaru();
      // Filter menggunakan .where() - case insensitive
      return allMotors.where((motor) => 
        motor.brand.toLowerCase() == brand.toLowerCase()
      ).toList();
    } catch (e) {
      rethrow;
    }
  }

  // ========== UTILITY: USD Converter ==========
  /// Convert dari USD ke currency lain (untuk harga motor import)
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
      // FALLBACK: Default rates jika API error
      switch (targetCurrency) {
        case 'IDR': return usdAmount * 15800;
        case 'EUR': return usdAmount * 0.92;
        case 'JPY': return usdAmount * 149.5;
        default: return usdAmount;
      }
    }
  }

  // ========== API CALL #3: Fetch Apparel ==========
  /// API untuk katalog apparel motor (jaket, celana, sepatu, dll)
  /// SAMA seperti motor API, tapi endpoint berbeda
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

  // ========== API CALL #4: Fetch Aksesoris ==========
  /// API untuk katalog aksesoris motor (helm, sarung tangan, dll)
  /// PRESENTASI: Ini API ke-4 (bukti bahwa kita pakai multiple APIs)
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

/// ============================================================================
/// SUMMARY UNTUK PRESENTASI:
/// ============================================================================
/// 
/// ✅ 4 API BERBEDA digunakan (memenuhi ketentuan):
///    1. MockAPI Motor Baru
///    2. Frankfurter Currency Exchange (Real-time)
///    3. MockAPI Apparel
///    4. MockAPI Aksesoris
/// 
/// ✅ SEMUA API menggunakan READ operation (HTTP GET)
/// 
/// ✅ ERROR HANDLING lengkap:
///    - Timeout protection (10 detik)
///    - Status code validation
///    - Try-catch blocks
///    - Fallback values untuk currency
/// 
/// ✅ JSON PARSING:
///    - dart:convert untuk decode JSON
///    - Model classes dengan fromJson() factory constructors
///    - Type-safe dengan List<Model>
/// 
/// 🎯 FLOW DATA:
///    UI Screen → Service Method → HTTP GET → JSON Response → Parse → Return Object → UI Update
/// 
/// ============================================================================
