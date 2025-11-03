import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';

class LocationTimeHelper {
  // Mendapatkan lokasi pengguna
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception("Location service disabled");

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied");
      }
    }
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  // Mendapatkan nama kota atau tempat dari koordinat
  Future<String> getPlaceFromPosition(Position position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isNotEmpty) {
      return placemarks.first.locality ?? 'Unknown Location';
    }
    return 'Unknown';
  }

  // Mengambil waktu berdasarkan zona
  String getCurrentTimeByZone(String zone) {
    DateTime now = DateTime.now().toUtc();
    switch (zone) {
      case 'WIB':
        return DateFormat('HH:mm').format(now.add(const Duration(hours: 7)));
      case 'WITA':
        return DateFormat('HH:mm').format(now.add(const Duration(hours: 8)));
      case 'WIT':
        return DateFormat('HH:mm').format(now.add(const Duration(hours: 9)));
      case 'London':
        return DateFormat('HH:mm').format(now);
      default:
        return DateFormat('HH:mm').format(now);
    }
  }
}
