import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/motor_listing.dart';
import '../models/bengkel.dart';
import '../models/voucher.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mainan_anak.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';
    const textTypeNull = 'TEXT';
    const realTypeNull = 'REAL';
    const intTypeNull = 'INTEGER';

    await db.execute('''
      CREATE TABLE users (
        id $idType,
        username $textType UNIQUE,
        password_hash $textType,
        salt $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE motor_listing (
        id $idType,
        nama $textType,
        brand $textType,
        cc $intType,
        tahun $intType,
        harga_idr $realType,
        kilometer $intType,
        kondisi $textType,
        deskripsi $textType,
        lokasi $textType,
        latitude $realTypeNull,
        longitude $realTypeNull,
        foto_path_1 $textTypeNull,
        foto_path_2 $textTypeNull,
        foto_path_3 $textTypeNull,
        foto_path_4 $textTypeNull,
        foto_path_5 $textTypeNull,
        instagram_link $textType,
        kontak_opsional $textTypeNull,
        user_id $intTypeNull
      )
    ''');

    await db.execute('''
      CREATE TABLE bengkel (
        id $idType,
        nama $textType,
        latitude $realType,
        longitude $realType
      )
    ''');

    await db.execute('''
      CREATE TABLE favorites (
        id $idType,
        user_id $intType,
        motor_id $intType,
        created_at $textType,
        UNIQUE(user_id, motor_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE vouchers (
        id $idType,
        code $textType UNIQUE,
        title $textType,
        description $textType,
        discountPercent $intType,
        type $textType,
        dateObtained $textType,
        expiryDate $textType,
        dateUsed $textTypeNull,
        isUsed $intType DEFAULT 0,
        bengkelName $textTypeNull,
        bengkelDistance $realTypeNull,
        booking_id $intTypeNull,
        user_id $intTypeNull
      )
    ''');

    await db.execute('''
      CREATE TABLE bookings (
        id $idType,
        user_id $intType,
        bengkel_id $intType,
        motor_merk $textType,
        motor_tipe $textType,
        motor_tahun $intType,
        motor_plat $textType,
        service_type $textType,
        booking_date $textType,
        booking_time_slot $textType,
        queue_number $textType,
        notes $textTypeNull,
        original_price $realType,
        discount_amount $realType DEFAULT 0,
        final_price $realType,
        voucher_id $intTypeNull,
        voucher_code $textTypeNull,
        status $textType DEFAULT 'confirmed',
        booking_code $textType UNIQUE,
        qr_code_data $textTypeNull,
        created_at $textType,
        updated_at $textTypeNull
      )
    ''');

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
      await db.execute('ALTER TABLE motor_listing ADD COLUMN latitude REAL');
      await db.execute('ALTER TABLE motor_listing ADD COLUMN longitude REAL');
      await db.execute('ALTER TABLE motor_listing ADD COLUMN user_id INTEGER');

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

      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_shake_status (
          user_id INTEGER PRIMARY KEY,
          has_shaken INTEGER DEFAULT 0,
          shake_date TEXT
        )
      ''');
    }

    if (oldVersion < 4) {
      try {
        final result = await db.rawQuery('PRAGMA table_info(vouchers)');
        final hasUserIdColumn = result.any(
          (column) => column['name'] == 'user_id',
        );

        if (!hasUserIdColumn) {
          await db.execute('ALTER TABLE vouchers ADD COLUMN user_id INTEGER');
        }
      } catch (e) {
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

  Future<void> deleteUserAccount(int userId) async {
    final db = await instance.database;

    await db.delete('motor_listing', where: 'user_id = ?', whereArgs: [userId]);

    await db.delete('favorites', where: 'user_id = ?', whereArgs: [userId]);

    await db.delete('vouchers', where: 'user_id = ?', whereArgs: [userId]);

    await db.delete('bookings', where: 'user_id = ?', whereArgs: [userId]);

    await db.delete(
      'user_shake_status',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    await db.delete('users', where: 'id = ?', whereArgs: [userId]);
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
    return await db.delete('motor_listing', where: 'id = ?', whereArgs: [id]);
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
    await db.insert('favorites', {
      'user_id': userId,
      'motor_id': motorId,
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
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
    final result = await db.rawQuery(
      '''
      SELECT m.* FROM motor_listing m
      INNER JOIN favorites f ON m.id = f.motor_id
      WHERE f.user_id = ?
      ORDER BY f.created_at DESC
    ''',
      [userId],
    );
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
    final result = await db.query('bookings', where: 'id = ?', whereArgs: [id]);
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
    final dateCode =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final targetDate = now.toIso8601String().split('T')[0];

    final db = await instance.database;

    // Use transaction to prevent race condition
    return await db.transaction((txn) async {
      // Query with LIKE to match date format stored in database
      final result = await txn.rawQuery(
        'SELECT COUNT(*) as count FROM bookings WHERE booking_date LIKE ?',
        ['$targetDate%'],
      );
      final count = result.first['count'] as int;

      // Keep generating until we find a unique code
      String bookingCode;
      int sequence = count + 1;
      bool isUnique = false;

      while (!isUnique) {
        bookingCode = 'BOOK-$dateCode-${sequence.toString().padLeft(3, '0')}';

        // Check if this code already exists
        final existingResult = await txn.rawQuery(
          'SELECT COUNT(*) as count FROM bookings WHERE booking_code = ?',
          [bookingCode],
        );
        final existingCount = existingResult.first['count'] as int;

        if (existingCount == 0) {
          isUnique = true;
          return bookingCode;
        }

        sequence++; // Try next sequence number
      }

      return 'BOOK-$dateCode-${sequence.toString().padLeft(3, '0')}';
    });
  }

  Future<String> generateQueueNumber(String bookingDate) async {
    final db = await instance.database;

    // Use transaction to prevent race condition
    return await db.transaction((txn) async {
      // Query with LIKE to match date format stored in database
      final result = await txn.rawQuery(
        'SELECT COUNT(*) as count FROM bookings WHERE booking_date LIKE ?',
        ['$bookingDate%'],
      );
      final count = result.first['count'] as int;

      // Keep generating until we find a unique queue number for this date
      String queueNumber;
      int sequence = count + 1;
      bool isUnique = false;

      while (!isUnique) {
        queueNumber = 'A${sequence.toString().padLeft(3, '0')}';

        // Check if this queue number already exists for this date
        final existingResult = await txn.rawQuery(
          'SELECT COUNT(*) as count FROM bookings WHERE booking_date LIKE ? AND queue_number = ?',
          ['$bookingDate%', queueNumber],
        );
        final existingCount = existingResult.first['count'] as int;

        if (existingCount == 0) {
          isUnique = true;
          return queueNumber;
        }

        sequence++; // Try next sequence number
      }

      return 'A${sequence.toString().padLeft(3, '0')}';
    });
  }

  // Booking Slot operations
  Future<void> initializeSlots(int bengkelId, String date) async {
    final db = await instance.database;
    final slots = [
      '08:00-09:00',
      '09:00-10:00',
      '10:00-11:00',
      '11:00-12:00',
      '13:00-14:00',
      '14:00-15:00',
      '15:00-16:00',
      '16:00-17:00',
    ];

    for (var slot in slots) {
      await db.insert('booking_slots', {
        'bengkel_id': bengkelId,
        'booking_date': date,
        'time_slot': slot,
        'is_available': 1,
        'max_capacity': 1,
        'current_bookings': 0,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<List<Map<String, dynamic>>> getAvailableSlots(
    int bengkelId,
    String date,
  ) async {
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
    await db.insert('user_shake_status', {
      'user_id': userId,
      'has_shaken': 1,
      'shake_date': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
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
