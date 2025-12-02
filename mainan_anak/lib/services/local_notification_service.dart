import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final LocalNotificationService instance = LocalNotificationService._init();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  LocalNotificationService._init();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  Future<void> showVoucherNotification({
    required String title,
    required String voucherTitle,
    required int discountPercent,
    required String expiryDate,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'voucher_channel',
      'Voucher Notifications',
      channelDescription: 'Notifications for voucher rewards',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      '🎉 $title',
      '$voucherTitle - Diskon $discountPercent%\nBerlaku hingga $expiryDate',
      details,
    );
  }

  Future<void> showBookingNotification({
    required String motorName,
    required String serviceType,
    required String bookingDate,
    required String timeSlot,
    required String queueNumber,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'booking_channel',
      'Booking Notifications',
      channelDescription: 'Notifications for service bookings',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1,
      '✅ Booking Dikonfirmasi!',
      '$serviceType untuk $motorName\n📅 $bookingDate, $timeSlot\n🎟️ No. Antrian: $queueNumber',
      details,
    );
  }

  Future<void> showMotorAddedNotification(String motorName) async {
    const androidDetails = AndroidNotificationDetails(
      'motor_channel',
      'Motor Listings',
      channelDescription: 'Notifications for motor listing updates',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      2,
      '🏍️ Motor Berhasil Ditambahkan!',
      '$motorName telah ditambahkan ke daftar motor Anda',
      details,
    );
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
