import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/cart_page.dart';
import 'pages/kesan_pesan.dart';
import 'providers/motor_provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MotorProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const CartPage(),
    const KesanPesanPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChildsPlay',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purpleAccent),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: NavigationBar(
          backgroundColor: Colors.white,
          indicatorColor: Colors.purpleAccent.withOpacity(0.12),
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), label: "Home"),
            NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), label: "Keranjang"),
            NavigationDestination(icon: Icon(Icons.message_outlined), label: "Kesan Pesan"),
            NavigationDestination(icon: Icon(Icons.person_outline), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
