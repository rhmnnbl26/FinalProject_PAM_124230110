import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class LocalNotificationService {
  static final LocalNotificationService instance =
      LocalNotificationService._init();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  LocalNotificationService._init();

  Future<void> initialize() async {
    // Request notification permission for Android 13+
    await _requestPermission();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);

    // Create notification channels for Android
    await _createNotificationChannels();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  Future<void> _createNotificationChannels() async {
    // Voucher Channel
    const voucherChannel = AndroidNotificationChannel(
      'voucher_channel',
      'Voucher Notifications',
      description: 'Notifications for voucher rewards',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Booking Channel
    const bookingChannel = AndroidNotificationChannel(
      'booking_channel',
      'Booking Notifications',
      description: 'Notifications for service bookings',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Motor Channel
    const motorChannel = AndroidNotificationChannel(
      'motor_channel',
      'Motor Listings',
      description: 'Notifications for motor listing updates',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Create channels
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(voucherChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(bookingChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(motorChannel);
  }

  Future<void> showVoucherNotification({
    required String title,
    required String voucherTitle,
    required int discountPercent,
    required String expiryDate,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'voucher_channel',
        'Voucher Notifications',
        channelDescription: 'Notifications for voucher rewards',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(''),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID
        '🎉 $title',
        '$voucherTitle - Diskon $discountPercent%\nBerlaku hingga $expiryDate',
        details,
      );
    } catch (e) {
      print('Error showing voucher notification: $e');
    }
  }

  Future<void> showBookingNotification({
    required String motorName,
    required String serviceType,
    required String bookingDate,
    required String timeSlot,
    required String queueNumber,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'booking_channel',
        'Booking Notifications',
        channelDescription: 'Notifications for service bookings',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(''),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID
        '✅ Booking Dikonfirmasi!',
        '$serviceType untuk $motorName\n📅 $bookingDate, $timeSlot\n🎟️ No. Antrian: $queueNumber',
        details,
      );
    } catch (e) {
      print('Error showing booking notification: $e');
    }
  }

  Future<void> showMotorAddedNotification(String motorName) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'motor_channel',
        'Motor Listings',
        channelDescription: 'Notifications for motor listing updates',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(''),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID
        '🏍️ Motor Berhasil Ditambahkan!',
        '$motorName telah ditambahkan ke daftar motor Anda',
        details,
      );
    } catch (e) {
      print('Error showing motor added notification: $e');
    }
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
