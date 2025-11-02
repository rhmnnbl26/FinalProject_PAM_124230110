import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class LocationTimeHelper {
  // Mendapatkan lokasi user (kota, negara)
  static Future<String> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Cek apakah layanan GPS aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return 'Yogyakarta, Indonesia'; // fallback
    }

    // Cek izin lokasi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return 'Yogyakarta, Indonesia'; // fallback
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return 'Yogyakarta, Indonesia';
    }

    // Ambil posisi
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Untuk demo, kita hanya tampilkan koordinat + teks default
    // Kamu bisa menambahkan reverse geocoding kalau mau hasil lebih detail
    return '(${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}) - Indonesia';
  }

  // Mengambil waktu sekarang dalam zona lokal
  static String getLocalTime({int offsetHours = 0}) {
    final now = DateTime.now().toUtc().add(const Duration(hours: 7)); // default WIB
    final converted = now.add(Duration(hours: offsetHours));
    final format = DateFormat('HH:mm');
    return format.format(converted);
  }
}
