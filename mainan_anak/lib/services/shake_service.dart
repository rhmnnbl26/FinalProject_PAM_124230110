import 'dart:async';
// ignore: uri_does_not_exist
import 'package:sensors_plus/sensors_plus.dart';
import 'database_helper.dart';

class ShakeService {
  static final ShakeService instance = ShakeService._init();

  ShakeService._init();

  // Shake detection parameters
  static const double _shakeThreshold =
      25.0; // Sensitivity threshold (increased from 15)
  static const int _shakeTimeWindow = 1000; // milliseconds (increased from 500)

  DateTime? _lastShakeTime;
  final _shakeController = StreamController<bool>.broadcast();
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  Stream<bool> get shakeStream => _shakeController.stream;

  /// Start listening to accelerometer for shake detection
  void startListening() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      final acceleration = event.x.abs() + event.y.abs() + event.z.abs();

      if (acceleration > _shakeThreshold) {
        final now = DateTime.now();

        if (_lastShakeTime == null ||
            now.difference(_lastShakeTime!).inMilliseconds > _shakeTimeWindow) {
          _lastShakeTime = now;
          _shakeController.add(true);
        }
      }
    });
  }

  /// Stop listening to accelerometer
  void stopListening() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
  }

  /// Check if user has already shaken (lifetime check)
  Future<bool> hasUserShaken(int userId) async {
    return await DatabaseHelper.instance.hasUserShaken(userId);
  }

  /// Mark user as having shaken (one-time only)
  Future<void> markUserShaken(int userId) async {
    await DatabaseHelper.instance.markUserShaken(userId);
  }

  /// Check if user can shake (not yet shaken)
  Future<bool> canUserShake(int userId) async {
    final hasShaken = await hasUserShaken(userId);
    return !hasShaken;
  }

  void dispose() {
    stopListening();
    _shakeController.close();
  }
}
