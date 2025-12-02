import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/voucher.dart';
import '../services/database_helper.dart';

class VoucherService {
  static const String _lastShakeKey = 'last_shake_date';
  static const double _maxDistanceKm = 5.0; // Maksimal jarak 5km

  // Voucher templates dengan probability
  static final List<Map<String, dynamic>> _voucherTemplates = [
    {
      'title': 'Diskon Servis 10%',
      'description': 'Dapatkan diskon 10% untuk servis motor Anda',
      'discountPercent': 10,
      'type': 'discount',
      'probability': 50, // 50%
    },
    {
      'title': 'Diskon Servis 20%',
      'description': 'Hemat 20% untuk semua jenis servis',
      'discountPercent': 20,
      'type': 'discount',
      'probability': 30, // 30%
    },
    {
      'title': 'Gratis Servis Ringan',
      'description': 'Gratis ganti oli dan tune-up dasar',
      'discountPercent': 100,
      'type': 'service',
      'probability': 15, // 15%
    },
    {
      'title': 'JACKPOT! Gratis Servis Besar',
      'description': 'Gratis servis besar termasuk tune-up lengkap',
      'discountPercent': 100,
      'type': 'service',
      'probability': 5, // 5%
    },
  ];

  /// Cek apakah user sudah shake hari ini
  Future<bool> canShakeToday() async {
    final prefs = await SharedPreferences.getInstance();
    final lastShakeStr = prefs.getString(_lastShakeKey);
    
    if (lastShakeStr == null) return true;
    
    final lastShake = DateTime.parse(lastShakeStr);
    final now = DateTime.now();
    
    // Cek apakah sudah berbeda hari
    return lastShake.year != now.year ||
           lastShake.month != now.month ||
           lastShake.day != now.day;
  }

  /// Cek apakah user dalam radius yang diperbolehkan
  bool isWithinRange(double? distance) {
    if (distance == null) return false;
    return distance <= _maxDistanceKm;
  }

  /// Generate voucher berdasarkan probability
  Voucher generateVoucher({
    required String bengkelName,
    required double bengkelDistance,
    required int userId, // Add userId parameter
  }) {
    final random = Random();
    final randomValue = random.nextInt(100); // 0-99
    
    int cumulativeProbability = 0;
    Map<String, dynamic>? selectedTemplate;
    
    for (var template in _voucherTemplates) {
      cumulativeProbability += template['probability'] as int;
      if (randomValue < cumulativeProbability) {
        selectedTemplate = template;
        break;
      }
    }
    
    // Fallback (seharusnya tidak terjadi)
    selectedTemplate ??= _voucherTemplates[0];
    
    // Generate unique code
    final code = _generateVoucherCode();
    
    // Set expiry date (30 hari dari sekarang)
    final now = DateTime.now();
    final expiryDate = now.add(const Duration(days: 30));
    
    return Voucher(
      code: code,
      title: selectedTemplate['title'],
      description: selectedTemplate['description'],
      discountPercent: selectedTemplate['discountPercent'],
      type: selectedTemplate['type'],
      dateObtained: now,
      expiryDate: expiryDate,
      bengkelName: bengkelName,
      bengkelDistance: bengkelDistance,
      userId: userId, // Set userId
    );
  }

  /// Generate unique voucher code
  String _generateVoucherCode() {
    final random = Random();
    final now = DateTime.now();
    final dateCode = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final randomCode = random.nextInt(9999).toString().padLeft(4, '0');
    return 'MOTOR-$dateCode-$randomCode';
  }

  /// Simpan voucher ke database dan update last shake date
  Future<Voucher> saveVoucher(Voucher voucher) async {
    // Simpan ke database
    final id = await DatabaseHelper.instance.insertVoucher(voucher);
    
    // Update last shake date
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastShakeKey, DateTime.now().toIso8601String());
    
    return voucher.copyWith(id: id);
  }

  /// Get all user vouchers
  Future<List<Voucher>> getUserVouchers({int? userId}) async {
    return await DatabaseHelper.instance.getAllVouchers(userId: userId);
  }

  /// Get unused vouchers
  Future<List<Voucher>> getUnusedVouchers({int? userId}) async {
    return await DatabaseHelper.instance.getUnusedVouchers(userId: userId);
  }

  /// Mark voucher as used
  Future<void> useVoucher(int voucherId, int bookingId) async {
    await DatabaseHelper.instance.useVoucher(voucherId, bookingId);
  }

  /// Get last shake date
  Future<DateTime?> getLastShakeDate() async {
    final prefs = await SharedPreferences.getInstance();
    final lastShakeStr = prefs.getString(_lastShakeKey);
    return lastShakeStr != null ? DateTime.parse(lastShakeStr) : null;
  }

  /// Get time until next shake available
  Future<Duration?> getTimeUntilNextShake() async {
    final lastShake = await getLastShakeDate();
    if (lastShake == null) return null;
    
    final now = DateTime.now();
    final nextShake = DateTime(lastShake.year, lastShake.month, lastShake.day + 1);
    
    if (now.isAfter(nextShake)) return null;
    
    return nextShake.difference(now);
  }
}
