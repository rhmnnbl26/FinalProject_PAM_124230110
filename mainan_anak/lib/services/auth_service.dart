import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'database_helper.dart';

/// ============================================================================
/// AUTHENTICATION SERVICE - LOGIN, REGISTER, SESSION MANAGEMENT
/// ============================================================================
/// File ini mengelola autentikasi user dan session management.
/// 
/// PENTING UNTUK PRESENTASI:
/// - Menggunakan SHARED PREFERENCES untuk session storage (materi wajib!)
/// - Password security dengan SHA-256 hashing + unique salt
/// - Session persistence (tetap login setelah close app)
/// 
/// TEKNOLOGI:
/// - shared_preferences: ^2.2.2 untuk local storage
/// - crypto: ^3.0.3 untuk SHA-256 hashing
/// - SQLite untuk menyimpan user credentials
/// ============================================================================

class AuthService {
  // ========== SHARED PREFERENCES KEYS ==========
  // PRESENTASI: Ini adalah KEY yang digunakan untuk save data ke SharedPreferences
  
  /// Key untuk status login (true/false)
  /// Digunakan untuk check apakah user sudah login atau belum
  static const String _sessionKey = 'user_session';
  
  /// Key untuk menyimpan username user yang sedang login
  static const String _usernameKey = 'username';
  
  /// Key untuk menyimpan user ID (foreign key untuk data lain)
  static const String _userIdKey = 'user_id';

  // ========== PASSWORD SECURITY ==========
  /// FITUR BONUS: Secure Password Hashing
  /// 
  /// FLOW HASHING:
  /// 1. Password plain text + Salt unik → Gabung jadi string
  /// 2. String di-encode jadi bytes (UTF-8)
  /// 3. Bytes di-hash dengan SHA-256
  /// 4. Hasil hash (hex string 64 karakter) disimpan ke database
  /// 
  /// KEAMANAN:
  /// - Salt unik per user → Prevent rainbow table attack
  /// - SHA-256 → Irreversible, tidak bisa di-decrypt
  /// - Same password, different salt = different hash
  String hashPassword(String password, String userSalt) {
    final saltedPassword = password + userSalt; // Gabung password + salt
    final bytes = utf8.encode(saltedPassword);  // Convert ke bytes
    final digest = sha256.convert(bytes);        // Hash dengan SHA-256
    return digest.toString();                    // Return hex string
  }

  /// Generate random salt (32 bytes) untuk setiap user baru
  /// PRESENTASI: Setiap user punya salt yang beda, jadi lebih aman
  String generateSalt() {
    final random = Random.secure(); // Cryptographically secure random
    final saltBytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Encode(saltBytes); // Encode to string untuk storage
  }

  /// Validate password strength (min 6 char, harus ada huruf + angka)
  /// PRESENTASI: Input validation untuk UX yang lebih baik
  String? validatePassword(String password) {
    if (password.length < 6) {
      return 'Password minimal 6 karakter';
    }
    if (!password.contains(RegExp(r'[A-Za-z]'))) {
      return 'Password harus mengandung huruf';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password harus mengandung angka';
    }
    return null; // Valid
  }

  // ========== REGISTER USER ==========
  /// FLOW REGISTER untuk PRESENTASI:
  /// 1. Validate password strength
  /// 2. Check username sudah ada atau belum (prevent duplicate)
  /// 3. Generate unique salt untuk user ini
  /// 4. Hash password dengan salt
  /// 5. Simpan user (username, hash, salt) ke SQLite database
  /// 6. Return true jika berhasil
  Future<bool> register(String username, String password) async {
    try {
      // Step 1: Validate password
      final passwordError = validatePassword(password);
      if (passwordError != null) {
        throw Exception(passwordError);
      }

      // Step 2: Check username availability
      final existingUser = await DatabaseHelper.instance.getUserByUsername(username);
      if (existingUser != null) {
        return false; // Username already taken
      }

      // Step 3 & 4: Generate salt and hash password
      final userSalt = generateSalt();
      final passwordHash = hashPassword(password, userSalt);

      // Step 5: Create user object
      final user = User(
        username: username,
        passwordHash: passwordHash, // Hashed password (NOT plain text!)
        salt: userSalt,             // Unique salt untuk user ini
      );

      // Step 6: Save to database
      await DatabaseHelper.instance.createUser(user);
      return true; // Success
    } catch (e) {
      rethrow;
    }
  }

  // ========== LOGIN USER ==========
  /// FLOW LOGIN untuk PRESENTASI:
  /// 1. Get user dari database berdasarkan username
  /// 2. Hash password input dengan salt user tersebut
  /// 3. Compare hash: jika sama → login success
  /// 4. Save session ke SharedPreferences
  /// 
  /// PERPINDAHAN DATA:
  /// Form Input → AuthService.login() → DatabaseHelper.getUserByUsername() 
  /// → SQLite → User object → Hash & Compare → Save to SharedPreferences
  Future<bool> login(String username, String password) async {
    try {
      // Step 1: Get user from database
      final user = await DatabaseHelper.instance.getUserByUsername(username);
      if (user == null) {
        return false; // User not found
      }

      // Step 2: Hash input password dengan salt user
      final passwordHash = hashPassword(password, user.salt);
      
      // Step 3: Compare hashes
      if (passwordHash != user.passwordHash) {
        return false; // Wrong password
      }

      // Step 4: Save session (SHARED PREFERENCES!)
      await saveSession(username);
      return true; // Login success
    } catch (e) {
      return false;
    }
  }

  // ========== SAVE SESSION (SHARED PREFERENCES) ==========
  /// ⭐ INI ADALAH IMPLEMENTASI SHARED PREFERENCES (MATERI WAJIB) ⭐
  /// 
  /// FLOW untuk PRESENTASI:
  /// 1. Get SharedPreferences instance
  /// 2. Get user dari database untuk ambil user ID
  /// 3. Save 3 data:
  ///    - user_session = true (status login)
  ///    - username = "nama_user"
  ///    - user_id = 123
  /// 
  /// PERSISTENSI:
  /// Data disimpan di local storage (persistent storage)
  /// Tetap ada meskipun app di-close atau HP di-restart
  Future<void> saveSession(String username) async {
    // Get SharedPreferences instance (singleton)
    final prefs = await SharedPreferences.getInstance();
    
    // Get user data untuk ambil ID
    final user = await DatabaseHelper.instance.getUserByUsername(username);
    
    // SAVE TO SHARED PREFERENCES (KEY-VALUE STORAGE)
    await prefs.setBool(_sessionKey, true);          // Status: logged in
    await prefs.setString(_usernameKey, username);   // Simpan username
    if (user?.id != null) {
      await prefs.setInt(_userIdKey, user!.id!);     // Simpan user ID
    }
  }

  // ========== CHECK LOGIN STATUS ==========
  /// Check apakah user sudah login atau belum
  /// DIGUNAKAN saat app start (SplashScreen)
  /// 
  /// FLOW APP START:
  /// SplashScreen → AuthService.isLoggedIn() → Read SharedPreferences
  /// → true? → MainNavigation : false? → LoginScreen
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    // Get value dari key 'user_session', default false jika belum ada
    return prefs.getBool(_sessionKey) ?? false;
  }

  // ========== GET CURRENT USER DATA ==========
  /// Get username user yang sedang login (dari SharedPreferences)
  Future<String?> getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  /// Get user ID yang sedang login (untuk relasi database)
  /// PENTING: ID ini digunakan untuk:
  /// - Motor listings (motor milik user mana)
  /// - Favorites (favorite milik user mana)
  /// - Bookings (booking oleh user mana)
  /// - Vouchers (voucher milik user mana)
  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  // ========== LOGOUT ==========
  /// Logout user: hapus data session dari SharedPreferences
  /// PRESENTASI: Ini adalah cara "membersihkan" session
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Hapus semua session keys
    await prefs.remove(_sessionKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_userIdKey);
  }

  // ========== DELETE ACCOUNT ==========
  /// Hapus akun user: delete semua data dari database & clear storage
  Future<bool> deleteAccount() async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) {
        return false;
      }

      // Delete all user data dari SQLite (cascade delete)
      await DatabaseHelper.instance.deleteUserAccount(userId);

      // Clear SharedPreferences (hapus session)
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      return true;
    } catch (e) {
      return false;
    }
  }
}

/// ============================================================================
/// SUMMARY UNTUK PRESENTASI:
/// ============================================================================
/// 
/// ✅ SHARED PREFERENCES (MATERI WAJIB):
///    - Menyimpan session login (key: user_session)
///    - Menyimpan username (key: username)
///    - Menyimpan user ID (key: user_id)
///    - Persistent storage (tetap ada setelah close app)
/// 
/// ✅ PASSWORD SECURITY (FITUR BONUS):
///    - SHA-256 hashing
///    - Unique salt per user (32 bytes random)
///    - Password validation (min 6 char, huruf + angka)
/// 
/// ✅ AUTHENTICATION FLOW:
///    Register: Input → Validate → Hash → Save to DB
///    Login: Input → Get User → Hash → Compare → Save Session
///    Check: Read SharedPreferences → true/false
///    Logout: Clear SharedPreferences
/// 
/// 🎯 PERPINDAHAN DATA:
///    Login Form → AuthService → DatabaseHelper → SQLite
///                           ↓
///                  SharedPreferences (session storage)
///                           ↓
///                  UI Navigation (MainNavigation/LoginScreen)
/// 
/// ============================================================================
