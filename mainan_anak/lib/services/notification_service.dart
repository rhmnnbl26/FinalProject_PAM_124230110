import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._init();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
    );

    // Request permissions
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    final iosPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> showMotorAddedNotification(String motorName) async {
    const androidDetails = AndroidNotificationDetails(
      'motor_added_channel',
      'Motor Added',
      channelDescription: 'Notifications when a new motor is added',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Motor Berhasil Ditambahkan!',
      'Motor "$motorName" telah berhasil ditambahkan ke listing',
      notificationDetails,
    );
  }
}
