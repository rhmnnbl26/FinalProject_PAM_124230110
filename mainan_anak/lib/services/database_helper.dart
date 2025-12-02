import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/motor_listing.dart';
import '../models/bengkel.dart';
import '../models/voucher.dart';

/// ============================================================================
/// DATABASE HELPER - SQLITE LOCAL DATABASE MANAGEMENT
/// ============================================================================
/// File ini adalah CORE untuk semua operasi database lokal.
/// 
/// PENTING UNTUK PRESENTASI:
/// - Menggunakan SQLITE (local database - materi wajib!)
/// - Ada 8 TABEL berbeda untuk berbagai fitur
/// - FULL CRUD operations (Create, Read, Update, Delete)
/// - Relational database dengan foreign keys
/// 
/// TEKNOLOGI:
/// - sqflite: ^2.3.0 untuk SQLite database
/// - path: untuk database file path
/// - Singleton pattern untuk instance management
/// ============================================================================

class DatabaseHelper {
  /// Singleton pattern: hanya ada 1 instance DatabaseHelper di seluruh app
  /// PRESENTASI: Ini best practice untuk database management
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init(); // Private constructor

  /// Get database instance (lazy initialization)
  /// Jika belum ada → create baru, jika sudah ada → return yang lama
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mainan_anak.db'); // Database filename
    return _database!;
  }

  /// Initialize database
  /// FLOW: Get database path → Open/create database → Set version
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath(); // Android: /data/data/.../databases/
    final path = join(dbPath, filePath);      // Full path: .../mainan_anak.db

    return await openDatabase(
      path,
      version: 4, // Database version (untuk migration/upgrade)
      onCreate: _createDB,     // Callback saat create database baru
      onUpgrade: _upgradeDB,   // Callback saat upgrade version
    );
  }

  // ========== CREATE DATABASE TABLES ==========
  /// Dipanggil HANYA sekali saat database pertama kali dibuat
  /// PRESENTASI: Jelaskan struktur 8 tabel yang ada
  Future<void> _createDB(Database db, int version) async {
    // SQL data types (constants untuk consistency)
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';
    const textTypeNull = 'TEXT';
    const realTypeNull = 'REAL';
    const intTypeNull = 'INTEGER';

    // ========== TABEL #1: USERS ==========
    /// Menyimpan data user (username, hashed password, salt)
    /// PRESENTASI: Ini untuk autentikasi (register & login)
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        username $textType UNIQUE,    -- UNIQUE: tidak boleh duplicate
        password_hash $textType,      -- SHA-256 hashed password
        salt $textType                -- Unique salt per user
      )
    ''');

    // ========== TABEL #2: MOTOR LISTING (MAIN CRUD) ==========
    /// ⭐ INI ADALAH TABEL UTAMA UNTUK CRUD OPERATIONS ⭐
    /// Menyimpan iklan motor bekas yang dijual oleh user
    /// 
    /// FITUR:
    /// - Multiple photos (5 foto)
    /// - Geolocation (latitude, longitude)
    /// - User ownership (foreign key ke users)
    /// - Instagram link untuk contact seller
    await db.execute('''
      CREATE TABLE motor_listing (
        id $idType,
        nama $textType,               -- Nama motor (contoh: "Honda CBR 250RR")
        brand $textType,              -- Brand (Honda, Yamaha, Kawasaki, dll)
        cc $intType,                  -- Kapasitas mesin (contoh: 250)
        tahun $intType,               -- Tahun produksi (contoh: 2020)
        harga_idr $realType,          -- Harga dalam Rupiah
        kilometer $intType,           -- Jarak tempuh (contoh: 5000 km)
        kondisi $textType,            -- 'baru' atau 'bekas'
        deskripsi $textType,          -- Deskripsi lengkap motor
        lokasi $textType,             -- Lokasi (contoh: "Jakarta Selatan")
        latitude $realTypeNull,       -- GPS latitude (untuk LBS)
        longitude $realTypeNull,      -- GPS longitude (untuk LBS)
        foto_path_1 $textTypeNull,    -- Path foto 1 (local storage)
        foto_path_2 $textTypeNull,    -- Path foto 2
        foto_path_3 $textTypeNull,    -- Path foto 3
        foto_path_4 $textTypeNull,    -- Path foto 4
        foto_path_5 $textTypeNull,    -- Path foto 5
        instagram_link $textType,     -- Link Instagram seller
        kontak_opsional $textTypeNull, -- Kontak tambahan (WhatsApp, dll)
        user_id $intTypeNull          -- Foreign key: pemilik motor (relasi ke users)
      )
    ''');

    // ========== TABEL #3: BENGKEL ==========
    /// Data bengkel untuk booking service motor
    /// PRESENTASI: Digunakan untuk LBS (Location-Based Service)
    await db.execute('''
      CREATE TABLE bengkel (
        id $idType,
        nama $textType,
        latitude $realType,           -- GPS latitude bengkel
        longitude $realType           -- GPS longitude bengkel
      )
    ''');

    // ========== TABEL #4: FAVORITES (WISHLIST) ==========
    /// Menyimpan motor favorit per user
    /// PRESENTASI: Relasi Many-to-Many (user ↔ motor)
    await db.execute('''
      CREATE TABLE favorites (
        id $idType,
        user_id $intType,             -- Foreign key ke users
        motor_id $intType,            -- Foreign key ke motor_listing
        created_at $textType,         -- Timestamp
        UNIQUE(user_id, motor_id)     -- Prevent duplicate favorite
      )
    ''');

    // ========== TABEL #5: VOUCHERS ==========
    /// Voucher diskon untuk booking service
    /// FITUR: Shake detector, bengkel reward, expiry date
    await db.execute('''
      CREATE TABLE vouchers (
        id $idType,
        code $textType UNIQUE,        -- Voucher code (contoh: "SKE-12345")
        title $textType,              -- Judul voucher
        description $textType,        -- Deskripsi
        discountPercent $intType,     -- Persentase diskon (contoh: 15)
        type $textType,               -- 'shake' atau 'bengkel'
        dateObtained $textType,       -- Tanggal dapat voucher
        expiryDate $textType,         -- Tanggal kadaluarsa
        dateUsed $textTypeNull,       -- Tanggal pakai voucher (null jika belum)
        isUsed $intType DEFAULT 0,    -- 0 = belum pakai, 1 = sudah pakai
        bengkelName $textTypeNull,    -- Nama bengkel (jika voucher dari bengkel)
        bengkelDistance $realTypeNull, -- Jarak ke bengkel (untuk tracking)
        booking_id $intTypeNull,      -- Foreign key ke bookings (jika sudah dipakai)
        user_id $intTypeNull          -- Foreign key ke users (pemilik voucher)
      )
    ''');

    // ========== TABEL #6: BOOKINGS ==========
    /// Sistem booking service bengkel
    /// FITUR KOMPLEKS: Queue management, voucher discount, QR code
    await db.execute('''
      CREATE TABLE bookings (
        id $idType,
        user_id $intType,             -- Foreign key: siapa yang booking
        bengkel_id $intType,          -- Foreign key: bengkel mana
        motor_merk $textType,         -- Merk motor yang di-service
        motor_tipe $textType,         -- Tipe motor
        motor_tahun $intType,         -- Tahun motor
        motor_plat $textType,         -- Plat nomor motor
        service_type $textType,       -- 'ringan', 'sedang', 'besar'
        booking_date $textType,       -- Tanggal booking (YYYY-MM-DD)
        booking_time_slot $textType,  -- Jam booking (08:00, 09:00, dst)
        queue_number $textType,       -- Nomor antrian (contoh: 3)
        notes $textTypeNull,          -- Catatan tambahan
        original_price $realType,     -- Harga asli (sebelum diskon)
        discount_amount $realType DEFAULT 0, -- Jumlah diskon (dari voucher)
        final_price $realType,        -- Harga akhir (setelah diskon)
        voucher_id $intTypeNull,      -- Foreign key ke vouchers
        voucher_code $textTypeNull,   -- Kode voucher yang dipakai
        status $textType DEFAULT 'confirmed', -- 'confirmed', 'completed', 'cancelled'
        booking_code $textType UNIQUE, -- Booking code unik (BK20241203001)
        qr_code_data $textTypeNull,   -- Data untuk generate QR code
        created_at $textType,         -- Timestamp create
        updated_at $textTypeNull      -- Timestamp update
      )
    ''');

    // ========== TABEL #7: BOOKING SLOTS ==========
    /// Manajemen slot waktu booking (prevent double booking)
    /// PRESENTASI: Ini memastikan 1 jam hanya bisa 1 booking
    await db.execute('''
      CREATE TABLE booking_slots (
        id $idType,
        bengkel_id $intType,
        booking_date $textType,
        time_slot $textType,
        is_available $intType DEFAULT 1,
        max_capacity $intType DEFAULT 1,
        current_bookings $intType DEFAULT 0,
        UNIQUE(bengkel_id, booking_date, time_slot)
      )
    ''');

    // User shake status table
    await db.execute('''
      CREATE TABLE user_shake_status (
        user_id $intType PRIMARY KEY,
        has_shaken $intType DEFAULT 0,
        shake_date $textTypeNull
      )
    ''');

    // Insert default bengkel
    await db.insert('bengkel', {
      'nama': 'Bengkel Motor Rumah',
      'latitude': -7.7482380,
      'longitude': 110.4084390,
    });
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns to motor_listing
      await db.execute('ALTER TABLE motor_listing ADD COLUMN latitude REAL');
      await db.execute('ALTER TABLE motor_listing ADD COLUMN longitude REAL');
      await db.execute('ALTER TABLE motor_listing ADD COLUMN user_id INTEGER');
      
      // Create favorites table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS favorites (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          motor_id INTEGER NOT NULL,
          created_at TEXT NOT NULL,
          UNIQUE(user_id, motor_id)
        )
      ''');
    }
    
    if (oldVersion < 3) {
      // Create vouchers table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS vouchers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          code TEXT NOT NULL UNIQUE,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          discountPercent INTEGER NOT NULL,
          type TEXT NOT NULL,
          dateObtained TEXT NOT NULL,
          expiryDate TEXT NOT NULL,
          dateUsed TEXT,
          isUsed INTEGER DEFAULT 0,
          bengkelName TEXT,
          bengkelDistance REAL,
          booking_id INTEGER
        )
      ''');
      
      // Create bookings table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS bookings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          bengkel_id INTEGER NOT NULL,
          motor_merk TEXT NOT NULL,
          motor_tipe TEXT NOT NULL,
          motor_tahun INTEGER NOT NULL,
          motor_plat TEXT NOT NULL,
          service_type TEXT NOT NULL,
          booking_date TEXT NOT NULL,
          booking_time_slot TEXT NOT NULL,
          queue_number TEXT NOT NULL,
          notes TEXT,
          original_price REAL NOT NULL,
          discount_amount REAL DEFAULT 0,
          final_price REAL NOT NULL,
          voucher_id INTEGER,
          voucher_code TEXT,
          status TEXT DEFAULT 'confirmed',
          booking_code TEXT UNIQUE NOT NULL,
          qr_code_data TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT
        )
      ''');
      
      // Create booking_slots table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS booking_slots (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          bengkel_id INTEGER NOT NULL,
          booking_date TEXT NOT NULL,
          time_slot TEXT NOT NULL,
          is_available INTEGER DEFAULT 1,
          max_capacity INTEGER DEFAULT 1,
          current_bookings INTEGER DEFAULT 0,
          UNIQUE(bengkel_id, booking_date, time_slot)
        )
      ''');
      
      // Create user_shake_status table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_shake_status (
          user_id INTEGER PRIMARY KEY,
          has_shaken INTEGER DEFAULT 0,
          shake_date TEXT
        )
      ''');
    }
    
    if (oldVersion < 4) {
      // Add user_id column to vouchers table if not exists
      try {
        // Check if column already exists
        final result = await db.rawQuery('PRAGMA table_info(vouchers)');
        final hasUserIdColumn = result.any((column) => column['name'] == 'user_id');
        
        if (!hasUserIdColumn) {
          await db.execute('ALTER TABLE vouchers ADD COLUMN user_id INTEGER');
        }
      } catch (e) {
        // Column might already exist, ignore error
        print('Note: user_id column might already exist: $e');
      }
    }
  }

  // User CRUD operations
  Future<User> createUser(User user) async {
    final db = await instance.database;
    final id = await db.insert('users', user.toMap());
    return user.copyWith(id: id);
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Delete user account and all associated data
  Future<void> deleteUserAccount(int userId) async {
    final db = await instance.database;
    
    // Delete in order to respect foreign key constraints
    // Delete user's motor listings
    await db.delete(
      'motor_listing',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    
    // Delete user's favorites
    await db.delete(
      'favorites',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    
    // Delete user's vouchers
    await db.delete(
      'vouchers',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    
    // Delete user's bookings
    await db.delete(
      'bookings',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    
    // Delete shake history (user_shake_status table)
    await db.delete(
      'user_shake_status',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    
    // Finally delete the user
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Motor Listing CRUD operations
  Future<MotorListing> createMotorListing(MotorListing motor) async {
    final db = await instance.database;
    final id = await db.insert('motor_listing', motor.toMap());
    return motor.copyWith(id: id);
  }

  Future<List<MotorListing>> getAllMotorListings() async {
    final db = await instance.database;
    final result = await db.query('motor_listing', orderBy: 'id DESC');
    return result.map((map) => MotorListing.fromMap(map)).toList();
  }

  Future<MotorListing?> getMotorListingById(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'motor_listing',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return MotorListing.fromMap(maps.first);
    }
    return null;
  }

  Future<List<MotorListing>> searchMotorListings(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'motor_listing',
      where: 'nama LIKE ? OR brand LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'id DESC',
    );
    return result.map((map) => MotorListing.fromMap(map)).toList();
  }

  Future<List<MotorListing>> filterMotorListings({
    int? cc,
    String? brand,
    int? tahun,
    String? kondisi,
  }) async {
    final db = await instance.database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (cc != null) {
      whereClause += 'cc = ?';
      whereArgs.add(cc);
    }
    if (brand != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'brand = ?';
      whereArgs.add(brand);
    }
    if (tahun != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'tahun = ?';
      whereArgs.add(tahun);
    }
    if (kondisi != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'kondisi = ?';
      whereArgs.add(kondisi);
    }

    final result = await db.query(
      'motor_listing',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'id DESC',
    );
    return result.map((map) => MotorListing.fromMap(map)).toList();
  }

  Future<List<MotorListing>> sortMotorListingsByPrice(bool ascending) async {
    final db = await instance.database;
    final result = await db.query(
      'motor_listing',
      orderBy: 'harga_idr ${ascending ? 'ASC' : 'DESC'}',
    );
    return result.map((map) => MotorListing.fromMap(map)).toList();
  }

  Future<int> updateMotorListing(MotorListing motor) async {
    final db = await instance.database;
    return db.update(
      'motor_listing',
      motor.toMap(),
      where: 'id = ?',
      whereArgs: [motor.id],
    );
  }

  Future<int> deleteMotorListing(int id) async {
    final db = await instance.database;
    return await db.delete(
      'motor_listing',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Bengkel operations
  Future<Bengkel?> getBengkel() async {
    final db = await instance.database;
    final maps = await db.query('bengkel', limit: 1);

    if (maps.isNotEmpty) {
      return Bengkel.fromMap(maps.first);
    }
    return null;
  }

  // Favorites operations
  Future<void> addFavorite(int userId, int motorId) async {
    final db = await instance.database;
    await db.insert(
      'favorites',
      {
        'user_id': userId,
        'motor_id': motorId,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFavorite(int userId, int motorId) async {
    final db = await instance.database;
    await db.delete(
      'favorites',
      where: 'user_id = ? AND motor_id = ?',
      whereArgs: [userId, motorId],
    );
  }

  Future<bool> isFavorite(int userId, int motorId) async {
    final db = await instance.database;
    final result = await db.query(
      'favorites',
      where: 'user_id = ? AND motor_id = ?',
      whereArgs: [userId, motorId],
    );
    return result.isNotEmpty;
  }

  Future<List<MotorListing>> getFavoriteMotors(int userId) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT m.* FROM motor_listing m
      INNER JOIN favorites f ON m.id = f.motor_id
      WHERE f.user_id = ?
      ORDER BY f.created_at DESC
    ''', [userId]);
    return result.map((map) => MotorListing.fromMap(map)).toList();
  }

  // Voucher CRUD operations
  Future<int> insertVoucher(Voucher voucher) async {
    final db = await instance.database;
    return await db.insert('vouchers', voucher.toMap());
  }

  Future<List<Voucher>> getAllVouchers({int? userId}) async {
    final db = await instance.database;
    final result = await db.query(
      'vouchers',
      where: userId != null ? 'user_id = ?' : null,
      whereArgs: userId != null ? [userId] : null,
      orderBy: 'dateObtained DESC',
    );
    return result.map((map) => Voucher.fromMap(map)).toList();
  }

  Future<List<Voucher>> getUnusedVouchers({int? userId}) async {
    final db = await instance.database;
    final now = DateTime.now().toIso8601String();
    
    String where = 'isUsed = ? AND expiryDate > ?';
    List<dynamic> whereArgs = [0, now];
    
    if (userId != null) {
      where += ' AND user_id = ?';
      whereArgs.add(userId);
    }
    
    final result = await db.query(
      'vouchers',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'dateObtained DESC',
    );
    return result.map((map) => Voucher.fromMap(map)).toList();
  }

  Future<void> useVoucher(int voucherId, int bookingId) async {
    final db = await instance.database;
    await db.update(
      'vouchers',
      {
        'isUsed': 1,
        'dateUsed': DateTime.now().toIso8601String(),
        'booking_id': bookingId,
      },
      where: 'id = ?',
      whereArgs: [voucherId],
    );
  }

  // Booking CRUD operations
  Future<int> insertBooking(Map<String, dynamic> booking) async {
    final db = await instance.database;
    return await db.insert('bookings', booking);
  }

  Future<List<Map<String, dynamic>>> getAllBookings(int userId) async {
    final db = await instance.database;
    return await db.query(
      'bookings',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  Future<Map<String, dynamic>?> getBookingById(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'bookings',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> updateBookingStatus(int bookingId, String status) async {
    final db = await instance.database;
    await db.update(
      'bookings',
      {'status': status, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [bookingId],
    );
  }

  Future<String> generateBookingCode() async {
    final now = DateTime.now();
    final dateCode = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM bookings WHERE booking_date = ?',
      [now.toIso8601String().split('T')[0]],
    );
    final count = result.first['count'] as int;
    final sequence = (count + 1).toString().padLeft(3, '0');
    
    return 'BOOK-$dateCode-$sequence';
  }

  Future<String> generateQueueNumber(String bookingDate) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM bookings WHERE booking_date = ?',
      [bookingDate],
    );
    final count = result.first['count'] as int;
    final sequence = (count + 1).toString().padLeft(3, '0');
    
    return 'A$sequence';
  }

  // Booking Slot operations
  Future<void> initializeSlots(int bengkelId, String date) async {
    final db = await instance.database;
    final slots = [
      '08:00-09:00', '09:00-10:00', '10:00-11:00', '11:00-12:00',
      '13:00-14:00', '14:00-15:00', '15:00-16:00', '16:00-17:00',
    ];
    
    for (var slot in slots) {
      await db.insert(
        'booking_slots',
        {
          'bengkel_id': bengkelId,
          'booking_date': date,
          'time_slot': slot,
          'is_available': 1,
          'max_capacity': 1,
          'current_bookings': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<List<Map<String, dynamic>>> getAvailableSlots(int bengkelId, String date) async {
    final db = await instance.database;
    await initializeSlots(bengkelId, date);
    
    return await db.query(
      'booking_slots',
      where: 'bengkel_id = ? AND booking_date = ? AND is_available = 1',
      whereArgs: [bengkelId, date],
      orderBy: 'time_slot ASC',
    );
  }

  Future<void> bookSlot(int bengkelId, String date, String timeSlot) async {
    final db = await instance.database;
    await db.update(
      'booking_slots',
      {'current_bookings': 1, 'is_available': 0},
      where: 'bengkel_id = ? AND booking_date = ? AND time_slot = ?',
      whereArgs: [bengkelId, date, timeSlot],
    );
  }

  Future<void> releaseSlot(int bengkelId, String date, String timeSlot) async {
    final db = await instance.database;
    await db.update(
      'booking_slots',
      {'current_bookings': 0, 'is_available': 1},
      where: 'bengkel_id = ? AND booking_date = ? AND time_slot = ?',
      whereArgs: [bengkelId, date, timeSlot],
    );
  }

  // User shake status operations
  Future<bool> hasUserShaken(int userId) async {
    final db = await instance.database;
    final result = await db.query(
      'user_shake_status',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    
    if (result.isEmpty) return false;
    return result.first['has_shaken'] == 1;
  }

  Future<void> markUserShaken(int userId) async {
    final db = await instance.database;
    await db.insert(
      'user_shake_status',
      {
        'user_id': userId,
        'has_shaken': 1,
        'shake_date': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}

// Extension for User
extension UserExtension on User {
  User copyWith({
    int? id,
    String? username,
    String? passwordHash,
    String? salt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      salt: salt ?? this.salt,
    );
  }
}

// Extension for MotorListing
extension MotorListingExtension on MotorListing {
  MotorListing copyWith({
    int? id,
    String? nama,
    String? brand,
    int? cc,
    int? tahun,
    double? hargaIdr,
    int? kilometer,
    String? kondisi,
    String? deskripsi,
    String? lokasi,
    double? latitude,
    double? longitude,
    String? fotoPath1,
    String? fotoPath2,
    String? fotoPath3,
    String? fotoPath4,
    String? fotoPath5,
    String? instagramLink,
    String? kontakOpsional,
    int? userId,
  }) {
    return MotorListing(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      brand: brand ?? this.brand,
      cc: cc ?? this.cc,
      tahun: tahun ?? this.tahun,
      hargaIdr: hargaIdr ?? this.hargaIdr,
      kilometer: kilometer ?? this.kilometer,
      kondisi: kondisi ?? this.kondisi,
      deskripsi: deskripsi ?? this.deskripsi,
      lokasi: lokasi ?? this.lokasi,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      fotoPath1: fotoPath1 ?? this.fotoPath1,
      fotoPath2: fotoPath2 ?? this.fotoPath2,
      fotoPath3: fotoPath3 ?? this.fotoPath3,
      fotoPath4: fotoPath4 ?? this.fotoPath4,
      fotoPath5: fotoPath5 ?? this.fotoPath5,
      instagramLink: instagramLink ?? this.instagramLink,
      kontakOpsional: kontakOpsional ?? this.kontakOpsional,
      userId: userId ?? this.userId,
    );
  }
}
