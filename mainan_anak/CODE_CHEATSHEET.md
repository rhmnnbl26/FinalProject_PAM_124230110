# 🎯 CODE CHEAT SHEET - Bagian Kode yang Harus Diingat

## 📁 FILE-FILE PENTING (Sudah Diberi Komentar Lengkap)

### 1. `lib/services/api_service.dart` ⭐⭐⭐
**Fungsi:** Semua API calls  
**Yang harus diingat:**
```dart
// 4 API yang digunakan:
1. MockAPI Motor Baru
2. Frankfurter Currency Exchange  
3. MockAPI Apparel
4. MockAPI Aksesoris

// Flow API Call:
http.get() → JSON response → json.decode() → Model.fromJson() → List<Model>
```

---

### 2. `lib/services/auth_service.dart` ⭐⭐⭐
**Fungsi:** Authentication & SharedPreferences  
**Yang harus diingat:**
```dart
// 3 Keys di SharedPreferences:
- user_session  (bool)   → Status login
- username      (String) → Username user
- user_id       (int)    → ID untuk relasi DB

// Security:
- Password hashing: SHA-256 + unique salt
- Salt: 32 byte random per user

// Flow Login:
Input → Get User → Hash password → Compare → Save to SharedPreferences
```

---

### 3. `lib/services/database_helper.dart` ⭐⭐⭐
**Fungsi:** SQLite database operations  
**Yang harus diingat:**
```dart
// 8 Tabel:
1. users         → Akun user
2. motor_listing → CRUD utama (iklan motor)
3. favorites     → Wishlist
4. bengkel       → Data bengkel
5. vouchers      → Diskon
6. bookings      → Booking service
7. booking_slots → Jadwal booking
8. shake_history → Track shake user

// CRUD Operations (motor_listing):
- CREATE: insertMotorListing()
- READ:   getAllMotorListings(), getMotorListingById()
- UPDATE: updateMotorListing()
- DELETE: deleteMotorListing()
```

---

### 4. `lib/main.dart` ⭐⭐
**Fungsi:** Entry point & theme  
**Yang harus diingat:**
```dart
// Initialization (sebelum app run):
1. initializeDateFormatting() → Format tanggal Indonesia
2. SystemChrome.setSystemUIOverlayStyle() → UI style
3. LocalNotificationService.initialize() → Setup notifications

// Navigation Flow:
main() → MyApp → SplashScreen → LoginScreen/MainNavigation
```

---

### 5. `lib/screens/main_navigation.dart` ⭐⭐
**Fungsi:** Bottom navigation (4 tabs)  
**Yang harus diingat:**
```dart
// 4 Tabs:
0. HomeNewScreen         → Marketplace motor bekas
1. TambahMotorScreen     → Jual motor (CRUD create)
2. BengkelVoucherScreen  → Bengkel + vouchers
3. ProfileScreen         → Profile + logout
```

---

## 🔑 KODE-KODE KUNCI

### API Call (HTTP GET)
```dart
// Template API call
final response = await http.get(
  Uri.parse('https://api.example.com/data'),
  headers: {'Content-Type': 'application/json'},
).timeout(const Duration(seconds: 10));

if (response.statusCode == 200) {
  final jsonData = json.decode(response.body);
  return jsonData.map((json) => Model.fromJson(json)).toList();
}
```

---

### SharedPreferences (Save & Read)
```dart
// SAVE
final prefs = await SharedPreferences.getInstance();
await prefs.setBool('user_session', true);
await prefs.setString('username', 'john_doe');
await prefs.setInt('user_id', 123);

// READ
final isLoggedIn = prefs.getBool('user_session') ?? false;
final username = prefs.getString('username');
final userId = prefs.getInt('user_id');

// DELETE
await prefs.remove('user_session');
// atau
await prefs.clear(); // Hapus semua
```

---

### SQLite CRUD
```dart
// CREATE (INSERT)
final id = await db.insert('motor_listing', motorMap);

// READ (SELECT)
final List<Map<String, dynamic>> maps = await db.query('motor_listing');
final motors = maps.map((map) => MotorListing.fromMap(map)).toList();

// UPDATE
await db.update(
  'motor_listing',
  motorMap,
  where: 'id = ?',
  whereArgs: [motorId],
);

// DELETE
await db.delete(
  'motor_listing',
  where: 'id = ?',
  whereArgs: [motorId],
);
```

---

### Password Hashing (SHA-256)
```dart
// Generate salt
final random = Random.secure();
final saltBytes = List<int>.generate(32, (_) => random.nextInt(256));
final salt = base64Encode(saltBytes);

// Hash password
final saltedPassword = password + salt;
final bytes = utf8.encode(saltedPassword);
final digest = sha256.convert(bytes);
final hash = digest.toString();

// Verify (saat login)
final inputHash = hashPassword(inputPassword, userSalt);
final isValid = inputHash == storedHash;
```

---

### Navigation
```dart
// Push (normal)
Navigator.push(context, MaterialPageRoute(
  builder: (context) => DetailScreen(data: data)
));

// Push Replacement (tidak bisa back)
Navigator.pushReplacement(context, MaterialPageRoute(
  builder: (context) => HomeScreen()
));

// Pop (kembali)
Navigator.pop(context);

// Pop dengan data
Navigator.pop(context, resultData);
```

---

### Image Picker
```dart
// Pick from gallery
final picker = ImagePicker();
final pickedFile = await picker.pickImage(
  source: ImageSource.gallery,
  maxWidth: 1920,
  maxHeight: 1080,
  imageQuality: 85,
);

if (pickedFile != null) {
  final path = pickedFile.path;
  // Save path to database
}
```

---

### Location (LBS)
```dart
// Get current position
Position position = await Geolocator.getCurrentPosition(
  desiredAccuracy: LocationAccuracy.high,
);

final latitude = position.latitude;
final longitude = position.longitude;

// Calculate distance (meters)
double distance = Geolocator.distanceBetween(
  lat1, lng1,  // Point A
  lat2, lng2,  // Point B
);

double distanceKm = distance / 1000; // Convert to km
```

---

### Shake Detector
```dart
// Listen to accelerometer
accelerometerEventStream().listen((event) {
  final acceleration = event.x.abs() + event.y.abs() + event.z.abs();
  
  if (acceleration > 25.0) {
    // SHAKE DETECTED!
    print('User shook the phone!');
  }
});
```

---

### Push Notification
```dart
// Show notification
await flutterLocalNotificationsPlugin.show(
  0, // Notification ID
  'Voucher Berhasil Didapat!',  // Title
  'Diskon 15% untuk service motor', // Body
  NotificationDetails(
    android: AndroidNotificationDetails(
      'channel_id',
      'Channel Name',
      channelDescription: 'Description',
      importance: Importance.high,
      priority: Priority.high,
    ),
  ),
);
```

---

## 🎨 UI COMPONENTS

### Card dengan Border
```dart
Card(
  color: Color(0xFF1E1E1E),
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: BorderSide(
      color: Colors.white.withOpacity(0.1),
      width: 1,
    ),
  ),
  child: ...
)
```

---

### Button (ElevatedButton)
```dart
ElevatedButton(
  onPressed: () { /* action */ },
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF2196F3),
    foregroundColor: Colors.white,
    minimumSize: Size(double.infinity, 56),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  child: Text('Button Text'),
)
```

---

### Bottom Navigation Bar
```dart
BottomNavigationBar(
  currentIndex: _currentIndex,
  onTap: (index) {
    setState(() => _currentIndex = index);
  },
  type: BottomNavigationBarType.fixed,
  selectedItemColor: Theme.of(context).primaryColor,
  unselectedItemColor: Colors.grey,
  items: [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Jual'),
    BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Care'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
  ],
)
```

---

## 📊 MODEL CLASSES (JSON Parsing)

### Model Template
```dart
class MotorBaru {
  final int id;
  final String nama;
  final String brand;
  final int cc;
  final double harga;
  
  MotorBaru({
    required this.id,
    required this.nama,
    required this.brand,
    required this.cc,
    required this.harga,
  });
  
  // FROM JSON (API response → Object)
  factory MotorBaru.fromJson(Map<String, dynamic> json) {
    return MotorBaru(
      id: json['id'],
      nama: json['nama'],
      brand: json['brand'],
      cc: json['cc'],
      harga: json['harga'].toDouble(),
    );
  }
  
  // TO MAP (Object → Database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'brand': brand,
      'cc': cc,
      'harga': harga,
    };
  }
  
  // FROM MAP (Database → Object)
  factory MotorBaru.fromMap(Map<String, dynamic> map) {
    return MotorBaru(
      id: map['id'],
      nama: map['nama'],
      brand: map['brand'],
      cc: map['cc'],
      harga: map['harga'],
    );
  }
}
```

---

## 🔄 ASYNC/AWAIT PATTERN

### Future & Async
```dart
// Function yang return Future
Future<List<Motor>> getMotors() async {
  // await untuk operasi async
  final response = await http.get(Uri.parse(url));
  
  // Processing...
  final data = json.decode(response.body);
  
  // Return
  return data.map((json) => Motor.fromJson(json)).toList();
}

// Memanggil Future function
void loadData() async {
  setState(() => isLoading = true);
  
  try {
    final motors = await getMotors(); // Wait for result
    setState(() {
      _motors = motors;
      isLoading = false;
    });
  } catch (e) {
    print('Error: $e');
    setState(() => isLoading = false);
  }
}
```

---

## 🎯 ERROR HANDLING

### Try-Catch Pattern
```dart
Future<void> someOperation() async {
  try {
    // Operasi yang mungkin error
    final result = await riskyOperation();
    
    // Success handling
    print('Success: $result');
    
  } on TimeoutException {
    // Handle timeout
    print('Operation timeout');
    
  } on SocketException {
    // Handle no internet
    print('No internet connection');
    
  } catch (e) {
    // Handle semua error lain
    print('Error: $e');
    rethrow; // Pass error ke caller
    
  } finally {
    // Always executed (cleanup)
    setState(() => isLoading = false);
  }
}
```

---

## 💡 STATE MANAGEMENT

### setState() Pattern
```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  List<Motor> _motors = [];
  bool _isLoading = false;
  
  void loadMotors() async {
    // Update state → rebuild UI
    setState(() => _isLoading = true);
    
    final motors = await DatabaseHelper.instance.getAllMotors();
    
    // Update state lagi
    setState(() {
      _motors = motors;
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? CircularProgressIndicator()
        : ListView.builder(
            itemCount: _motors.length,
            itemBuilder: (context, index) {
              return MotorCard(motor: _motors[index]);
            },
          );
  }
}
```

---

## 🎬 YANG HARUS BISA DIJELASKAN SAAT PRESENTASI

### 1. Flow Data API
```
User Tap Button
    ↓
Call ApiService.getMotorBaru()
    ↓
HTTP GET ke MockAPI
    ↓
Response JSON
    ↓
json.decode() → List<dynamic>
    ↓
.map(MotorBaru.fromJson) → List<MotorBaru>
    ↓
setState() → Update _motors
    ↓
UI rebuild → ListView.builder()
    ↓
Display data
```

### 2. Flow Authentication
```
User Input (username, password)
    ↓
AuthService.login()
    ↓
DatabaseHelper.getUserByUsername()
    ↓
SQLite query
    ↓
Get User object (with salt)
    ↓
Hash input password + salt
    ↓
Compare hash
    ↓
Match? → Save to SharedPreferences
    ↓
Navigate to MainNavigation
```

### 3. Flow CRUD Create (Upload Motor)
```
User Fill Form + Upload Photos
    ↓
ImagePicker.pickImage()
    ↓
Compress image
    ↓
Save to local storage (get path)
    ↓
Create MotorListing object
    ↓
DatabaseHelper.insertMotorListing()
    ↓
SQLite INSERT
    ↓
Get inserted ID
    ↓
Show notification
    ↓
Navigate back / refresh list
```

---

**INGAT:** Kode di atas sudah ada di file-file project dengan komentar lengkap!  
Baca komentar di:
- `lib/services/api_service.dart`
- `lib/services/auth_service.dart`
- `lib/services/database_helper.dart`
- `lib/main.dart`

**Good luck! 🚀**
