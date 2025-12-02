import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'database_helper.dart';

class LbsService {
  // Request location permission
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  // Check if location permission is granted
  Future<bool> isLocationPermissionGranted() async {
    return await Permission.location.isGranted;
  }

  // Get current position
  Future<Position?> getCurrentPosition() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }

      // Get position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }

  // Calculate distance to bengkel
  Future<double?> calculateDistanceToBengkel() async {
    try {
      // Get current position
      final currentPosition = await getCurrentPosition();
      if (currentPosition == null) {
        return null;
      }

      // Get bengkel location
      final bengkel = await DatabaseHelper.instance.getBengkel();
      if (bengkel == null) {
        return null;
      }

      // Calculate distance in meters
      final distanceInMeters = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        bengkel.latitude,
        bengkel.longitude,
      );

      // Convert to kilometers
      return distanceInMeters / 1000;
    } catch (e) {
      return null;
    }
  }

  // Get distance to bengkel with formatted string
  Future<String> getDistanceToBengkelFormatted() async {
    final distance = await calculateDistanceToBengkel();
    if (distance == null) {
      return 'Tidak dapat menghitung jarak';
    }

    if (distance < 1) {
      return '${(distance * 1000).toStringAsFixed(0)} meter';
    } else {
      return '${distance.toStringAsFixed(2)} km';
    }
  }

  // Get bengkel info with distance
  Future<Map<String, dynamic>?> getBengkelWithDistance() async {
    try {
      final bengkel = await DatabaseHelper.instance.getBengkel();
      final distance = await calculateDistanceToBengkel();

      if (bengkel == null) return null;

      return {
        'bengkel': bengkel,
        'distance': distance,
        'distanceFormatted': distance != null
            ? (distance < 1
                ? '${(distance * 1000).toStringAsFixed(0)} m'
                : '${distance.toStringAsFixed(2)} km')
            : 'N/A',
      };
    } catch (e) {
      return null;
    }
  }

  // Calculate distance between two coordinates
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    final distanceInMeters = Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    );
    return distanceInMeters / 1000; // Convert to km
  }

  // Calculate distance from current position to motor location
  Future<double?> calculateDistanceToMotor(double? motorLat, double? motorLng) async {
    if (motorLat == null || motorLng == null) return null;

    try {
      final currentPosition = await getCurrentPosition();
      if (currentPosition == null) return null;

      return calculateDistance(
        currentPosition.latitude,
        currentPosition.longitude,
        motorLat,
        motorLng,
      );
    } catch (e) {
      print('Error calculating distance to motor: $e');
      return null;
    }
  }

  // Format distance to readable string
  String formatDistance(double? distanceKm) {
    if (distanceKm == null) return 'Lokasi tidak tersedia';
    
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toStringAsFixed(0)} m';
    } else if (distanceKm < 10) {
      return '${distanceKm.toStringAsFixed(2)} km';
    } else {
      return '${distanceKm.toStringAsFixed(1)} km';
    }
  }
}

