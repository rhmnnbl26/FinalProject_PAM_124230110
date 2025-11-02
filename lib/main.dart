import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/cart_service.dart';
import 'utils/notification_helper.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await CartService.init();
  await NotificationHelper.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(username: 'user'),
    );
  }
}
