import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/motor_listing.dart';
import '../models/bengkel.dart';

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
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';
    const textTypeNull = 'TEXT';

    // User table
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        username $textType UNIQUE,
        password_hash $textType,
        salt $textType
      )
    ''');

    // Motor Listing table
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
        foto_path_1 $textTypeNull,
        foto_path_2 $textTypeNull,
        foto_path_3 $textTypeNull,
        foto_path_4 $textTypeNull,
        foto_path_5 $textTypeNull,
        instagram_link $textType,
        kontak_opsional $textTypeNull
      )
    ''');

    // Bengkel table
    await db.execute('''
      CREATE TABLE bengkel (
        id $idType,
        nama $textType,
        latitude $realType,
        longitude $realType
      )
    ''');

    // Insert default bengkel (Yogyakarta city center)
    await db.insert('bengkel', {
      'nama': 'Bengkel Motor Yogyakarta',
      'latitude': -7.7956,
      'longitude': 110.3695,
    });
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
    String? fotoPath1,
    String? fotoPath2,
    String? fotoPath3,
    String? fotoPath4,
    String? fotoPath5,
    String? instagramLink,
    String? kontakOpsional,
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
      fotoPath1: fotoPath1 ?? this.fotoPath1,
      fotoPath2: fotoPath2 ?? this.fotoPath2,
      fotoPath3: fotoPath3 ?? this.fotoPath3,
      fotoPath4: fotoPath4 ?? this.fotoPath4,
      fotoPath5: fotoPath5 ?? this.fotoPath5,
      instagramLink: instagramLink ?? this.instagramLink,
      kontakOpsional: kontakOpsional ?? this.kontakOpsional,
    );
  }
}
