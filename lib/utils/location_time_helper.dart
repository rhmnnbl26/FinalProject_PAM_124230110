import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

class LocationTimeHelper {
  /// Mendapatkan posisi terkini (latitude & longitude)
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Layanan lokasi tidak aktif.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak permanen.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Mengubah koordinat menjadi nama tempat (kota, negara)
  Future<String> getPlaceFromPosition(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return "${place.locality}, ${place.country}";
      } else {
        return "Tidak diketahui";
      }
    } catch (e) {
      return "Gagal mengambil lokasi";
    }
  }

  /// Mendapatkan waktu berdasarkan zona waktu
  /// Parameter wajib: zone → WIB / WITA / WIT / London
  String getCurrentTimeByZone(String zone) {
    DateTime now = DateTime.now().toUtc();

    switch (zone) {
      case 'WIB':
        now = now.add(const Duration(hours: 7));
        break;
      case 'WITA':
        now = now.add(const Duration(hours: 8));
        break;
      case 'WIT':
        now = now.add(const Duration(hours: 9));
        break;
      case 'London':
        // UTC+0, jadi biarkan tanpa tambahan
        break;
      default:
        now = now.add(const Duration(hours: 7)); // Default ke WIB
    }

    return DateFormat('HH:mm:ss').format(now);
  }
}
