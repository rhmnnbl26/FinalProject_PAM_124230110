import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/local_notification_service.dart';
import 'screens/splash_screen.dart';

/// ============================================================================
/// MAIN ENTRY POINT - APLIKASI START DARI SINI
/// ============================================================================
/// File ini adalah entry point aplikasi (file pertama yang dijalankan).
/// 
/// PENTING UNTUK PRESENTASI:
/// - Inisialisasi services sebelum app run
/// - Setup theme & UI styling
/// - Navigation flow dimulai dari SplashScreen
/// 
/// FLOW APLIKASI:
/// main() → MyApp → SplashScreen → (check session) → LoginScreen/MainNavigation
/// ============================================================================

void main() async {
  /// WidgetsFlutterBinding: Ensure Flutter framework siap sebelum async operations
  /// WAJIB untuk semua async operations di main()
  WidgetsFlutterBinding.ensureInitialized();
  
  // ========== INITIALIZATION SERVICES ==========
  /// PRESENTASI: Ini adalah setup yang dilakukan SEBELUM app berjalan
  
  /// 1. Initialize date formatting untuk locale Indonesia
  /// Digunakan untuk format tanggal (contoh: "3 Desember 2024")
  await initializeDateFormatting('id_ID', null);
  
  /// 2. Set system UI style (status bar & navigation bar)
  /// PRESENTASI: Ini membuat UI terlihat modern & fullscreen
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,        // Transparent status bar
      statusBarIconBrightness: Brightness.light, // White icons
      systemNavigationBarColor: Color(0xFF121212), // Dark nav bar
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  /// 3. Initialize notification service (FITUR BONUS!)
  /// PRESENTASI: Setup notification channels untuk Android
  /// Notification digunakan untuk: booking confirmation, voucher rewards
  await LocalNotificationService.instance.initialize();
  
  /// 4. Run app!
  runApp(const MyApp());
}

/// ========== ROOT WIDGET ==========
/// MyApp adalah root widget dari seluruh aplikasi
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Children\'s Toys', // Nama app (muncul di recent apps)
      debugShowCheckedModeBanner: false, // Hide debug banner (production ready)
      
      /// ========== THEME CONFIGURATION ==========
      /// PRESENTASI: Custom dark theme untuk modern look
      /// Jelaskan bahwa ini adalah Material Design 3 (modern)
      theme: _buildPremiumDarkTheme(),
      
      /// ========== NAVIGATION FLOW START ==========
      /// FLOW untuk PRESENTASI:
      /// SplashScreen (3 detik loading)
      ///     ↓
      /// Check SharedPreferences (isLoggedIn?)
      ///     ↓
      /// true  → MainNavigation (Home, Jual Motor, Motor Care, Profile)
      /// false → LoginScreen (Form login/register)
      home: const SplashScreen(), // Entry screen
    );
  }

  /// ========== CUSTOM DARK THEME ==========
  /// PRESENTASI: Jelaskan theme & color scheme
  /// Ini adalah Material Design 3 dengan custom colors
  ThemeData _buildPremiumDarkTheme() {
    // Color palette constants
    const primaryColor = Color(0xFF2196F3);   // Modern Blue (primary actions)
    const accentBlue = Color(0xFF1565C0);     // Dark Blue (secondary)
    const bgDark = Color(0xFF121212);         // Dark background (modern dark mode)
    const bgCard = Color(0xFF1E1E1E);         // Card background (slightly lighter)
    const textPrimary = Color(0xFFFFFFFF);    // White text (high contrast)
    const textSecondary = Color(0xFFB0B0B0);  // Grey text (secondary info)

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: bgDark,
      
      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentBlue,
        surface: bgCard,
        error: Color(0xFFFF5252),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF5252), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.6)),
        labelStyle: const TextStyle(color: textSecondary),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgCard,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -1,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textSecondary,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.1),
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: textPrimary,
        size: 24,
      ),
    );
  }
}
