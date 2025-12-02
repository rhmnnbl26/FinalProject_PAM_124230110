# 📱 PANDUAN PRESENTASI FINAL PROJECT
## Aplikasi Marketplace Motor Bekas

---

## 📋 INFORMASI PROJECT

**Nama Aplikasi:** Children's Toys (Marketplace Motor Bekas)  
**Repository:** FinalProject_PAM_124230110  
**Owner:** rhmnnbl26  
**Platform:** Flutter (Android/iOS)  
**Tanggal:** Desember 2024

---

## 🎯 RINGKASAN APLIKASI

Aplikasi **marketplace motor bekas** yang dilengkapi dengan sistem **booking servis bengkel**. Aplikasi ini menggabungkan fitur jual-beli motor bekas dengan layanan perawatan motor yang lengkap.

### Fitur Utama:
- ✅ Marketplace motor bekas (jual & beli)
- ✅ Sistem autentikasi user yang aman
- ✅ Booking servis bengkel dengan voucher diskon
- ✅ Location-Based Service (LBS) untuk mencari bengkel terdekat
- ✅ Shake detector untuk mendapat voucher
- ✅ Multi-currency converter (IDR, USD, EUR, JPY)
- ✅ Push notifications
- ✅ QR Code untuk verifikasi booking
- ✅ Wishlist/favorite motors
- ✅ Marketplace apparel & aksesoris motor

---

## 📚 PENJELASAN MATERI WAJIB

### 1️⃣ API INTEGRATION ⭐ WAJIB

#### **API Yang Digunakan:**

| No | Nama API | URL | Fungsi | CRUD |
|---|---|---|---|---|
| 1 | **MockAPI - Motor** | `https://69063273ee3d0d14c13529b5.mockapi.io` | Data katalog motor baru dari berbagai brand | **READ** |
| 2 | **Frankfurter API** | `https://api.frankfurter.app/latest` | Real-time currency exchange rates | **READ** |
| 3 | **MockAPI - Apparel** | `https://692f397f91e00bafccd6f9b3.mockapi.io/apparel` | Katalog pakaian & jaket motor | **READ** |
| 4 | **MockAPI - Aksesoris** | `https://692f397f91e00bafccd6f9b3.mockapi.io/aksesoris` | Katalog aksesoris (helm, sarung tangan, dll) | **READ** |

#### **Lokasi Implementasi:**
📁 **File:** `lib/services/api_service.dart` (sudah diberi komentar lengkap)

#### **Cara Kerja & Flow Data:**

**1. API Motor Baru (MockAPI):**
```dart
Future<List<MotorBaru>> getMotorBaru() async {
  // HTTP GET request ke MockAPI
  final response = await http.get(Uri.parse('$mockApiBaseUrl/motor'));
  
  // Parse JSON response menjadi List objects
  final List<dynamic> jsonData = json.decode(response.body);
  return jsonData.map((json) => MotorBaru.fromJson(json)).toList();
}
```

**Flow Lengkap:**
```
User membuka screen "Harga Motor Baru"
    ↓
ApiService.getMotorBaru() dipanggil
    ↓
HTTP GET Request ke MockAPI server
    ↓
Server mengirim Response (JSON array)
    ↓
json.decode() mengubah JSON string → List<dynamic>
    ↓
.map() + fromJson() mengubah List<dynamic> → List<MotorBaru>
    ↓
setState() update state variable
    ↓
UI di-rebuild dengan data baru
    ↓
ListView menampilkan data motor
```

**2. API Currency Converter (Frankfurter):**
```dart
Future<ExchangeRate> getExchangeRates() async {
  // Request dengan query parameter
  final response = await http.get(
    Uri.parse('$exchangeRateApiUrl?from=IDR&to=USD,EUR,JPY')
  );
  
  // Parse response ke object ExchangeRate
  return ExchangeRate.fromJson(json.decode(response.body));
}
```

**Penggunaan:**
- Convert harga motor dari IDR ke mata uang lain
- Real-time rates (selalu update)
- Fallback ke default rates jika API error (robust!)

**Error Handling:**
- ✅ Timeout 10 detik (prevent hanging)
- ✅ Status code validation (200 = success)
- ✅ Try-catch untuk network errors
- ✅ Fallback values jika API tidak tersedia

---

### 2️⃣ SHARED PREFERENCES ⭐ WAJIB

#### **Implementasi Session Management:**

**Lokasi:** `lib/services/auth_service.dart` (sudah diberi komentar lengkap)

#### **Data yang Disimpan:**

| Key | Tipe Data | Fungsi | Contoh Value |
|---|---|---|---|
| `user_session` | boolean | Status login user | `true` / `false` |
| `username` | String | Username user yang login | `"john_doe"` |
| `user_id` | int | ID user untuk relasi database | `123` |

#### **Implementasi Kode:**

**1. Save Session (Saat Login Berhasil):**
```dart
Future<void> saveSession(String username) async {
  // Get SharedPreferences instance
  final prefs = await SharedPreferences.getInstance();
  
  // Get user dari database
  final user = await DatabaseHelper.instance.getUserByUsername(username);
  
  // SAVE data ke local storage (persistent!)
  await prefs.setBool('user_session', true);      // Status login
  await prefs.setString('username', username);     // Username
  await prefs.setInt('user_id', user!.id!);       // User ID
}
```

**2. Check Session (Saat App Dibuka):**
```dart
Future<bool> isLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  // Get value, default false jika belum ada
  return prefs.getBool('user_session') ?? false;
}
```

**3. Get Current User Data:**
```dart
Future<String?> getCurrentUsername() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('username');
}

Future<int?> getCurrentUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('user_id');
}
```

**4. Logout (Clear Session):**
```dart
Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('user_session');
  await prefs.remove('username');
  await prefs.remove('user_id');
  // atau: await prefs.clear(); // Hapus semua
}
```

#### **Flow Authentication Lengkap:**
```
App Start
    ↓
SplashScreen (3 detik)
    ↓
Check SharedPreferences.getBool('user_session')
    ↓
├─ true?  → Navigate ke MainNavigation (sudah login)
└─ false? → Navigate ke LoginScreen (belum login)
    ↓
User input username & password
    ↓
AuthService.login() → Verify credentials
    ↓
Valid? → saveSession() ke SharedPreferences
    ↓
Navigate ke MainNavigation
```

**Kenapa Pakai SharedPreferences?**
- ✅ Persistent storage (data tetap ada setelah app ditutup)
- ✅ Cepat untuk data kecil (key-value storage)
- ✅ Mudah digunakan (simple API)
- ✅ Perfect untuk session management

---

### 3️⃣ LOCAL DATABASE (SQLite) ⭐ WAJIB

#### **Database Configuration:**

**Lokasi:** `lib/services/database_helper.dart` (sudah diberi komentar lengkap)

**Database Name:** `mainan_anak.db`  
**Database Version:** 4  
**Jumlah Tabel:** 8 tabel

#### **Struktur Database:**

**TABEL #1: `users`** - Data Akun User
```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,  -- SHA-256 encrypted
  salt TEXT NOT NULL            -- Unique per user
)
```
- **Fungsi:** Menyimpan akun user untuk login/register
- **CRUD:** CREATE (register), READ (login, get user)
- **Security:** Password di-hash dengan SHA-256 + salt

---

**TABEL #2: `motor_listing`** - Iklan Motor Bekas (⭐ CRUD UTAMA)
```sql
CREATE TABLE motor_listing (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nama TEXT NOT NULL,
  brand TEXT NOT NULL,
  cc INTEGER NOT NULL,
  tahun INTEGER NOT NULL,
  harga_idr REAL NOT NULL,
  kilometer INTEGER NOT NULL,
  kondisi TEXT NOT NULL,         -- 'baru' atau 'bekas'
  deskripsi TEXT NOT NULL,
  lokasi TEXT NOT NULL,
  latitude REAL,                 -- GPS coordinate
  longitude REAL,                -- GPS coordinate
  foto_path_1 TEXT,              -- Support 5 foto
  foto_path_2 TEXT,
  foto_path_3 TEXT,
  foto_path_4 TEXT,
  foto_path_5 TEXT,
  instagram_link TEXT NOT NULL,
  kontak_opsional TEXT,
  user_id INTEGER                -- Foreign key ke users
)
```

**CRUD OPERATIONS (FULL CRUD!):**

| Operation | Method | Screen | Fungsi |
|---|---|---|---|
| **CREATE** | `insertMotorListing()` | TambahMotorScreen | Upload motor baru |
| **READ** | `getAllMotorListings()` | HomeScreen | List semua motor |
| **READ** | `getMotorListingById()` | DetailMotorScreen | Detail 1 motor |
| **UPDATE** | `updateMotorListing()` | EditMotorScreen | Edit data motor |
| **DELETE** | `deleteMotorListing()` | DetailMotorScreen | Hapus motor |

**Flow CRUD Create (Upload Motor):**
```
User mengisi form di TambahMotorScreen
    ↓
Upload foto (ImagePicker) → max 5 foto
    ↓
Compress foto (hemat storage)
    ↓
Save foto ke local storage → dapat path
    ↓
Create object MotorListing dengan semua data
    ↓
DatabaseHelper.insertMotorListing(motor)
    ↓
SQLite INSERT INTO motor_listing VALUES (...)
    ↓
Dapat ID motor yang baru di-insert
    ↓
Show notification "Motor berhasil dipublikasi"
    ↓
Navigate back & refresh list
    ↓
Motor baru muncul di HomeScreen
```

---

**TABEL #3: `favorites`** - Wishlist Motor
```sql
CREATE TABLE favorites (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  motor_id INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  UNIQUE(user_id, motor_id)      -- Prevent duplicate
)
```
- **Fungsi:** Simpan motor favorit per user
- **CRUD:** CREATE (add), READ (get list), DELETE (remove)
- **Relasi:** Many-to-Many (user ↔ motor)

---

**TABEL #4: `bengkel`** - Data Bengkel
```sql
CREATE TABLE bengkel (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nama TEXT NOT NULL,
  latitude REAL NOT NULL,        -- GPS untuk LBS
  longitude REAL NOT NULL
)
```
- **Fungsi:** Data bengkel untuk booking service
- **Fitur:** Geolocation untuk hitung jarak

---

**TABEL #5: `vouchers`** - Voucher Diskon
```sql
CREATE TABLE vouchers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  discount_percent INTEGER NOT NULL,
  expiry_date TEXT NOT NULL,
  is_used INTEGER DEFAULT 0,     -- 0=belum, 1=sudah
  source TEXT NOT NULL,          -- 'shake' atau 'bengkel'
  user_id INTEGER NOT NULL
)
```
- **Fungsi:** Voucher diskon untuk booking service
- **Source:** Dari shake detector atau reward bengkel
- **CRUD:** CREATE (dapat voucher), READ (list), UPDATE (mark used)

---

**TABEL #6: `bookings`** - Booking Servis
```sql
CREATE TABLE bookings (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  bengkel_id INTEGER NOT NULL,
  motor_merk TEXT NOT NULL,
  service_type TEXT NOT NULL,    -- ringan/sedang/besar
  booking_date TEXT NOT NULL,
  booking_time_slot TEXT NOT NULL,
  queue_number TEXT NOT NULL,
  original_price REAL NOT NULL,
  discount_amount REAL NOT NULL,
  final_price REAL NOT NULL,
  voucher_id INTEGER,
  booking_code TEXT NOT NULL UNIQUE,
  qr_code_data TEXT NOT NULL,
  status TEXT DEFAULT 'confirmed'
)
```
- **Fungsi:** Sistem booking servis bengkel
- **Fitur:** Queue number, discount, QR code
- **CRUD:** CREATE (booking), READ (history), UPDATE (status)

---

**TABEL #7: `booking_slots`** - Jadwal Booking
```sql
CREATE TABLE booking_slots (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  bengkel_id INTEGER NOT NULL,
  date TEXT NOT NULL,
  time_slot TEXT NOT NULL,       -- '08:00', '09:00', dll
  is_booked INTEGER DEFAULT 0,   -- 0=available, 1=booked
  UNIQUE(bengkel_id, date, time_slot)
)
```
- **Fungsi:** Prevent double booking (1 slot = 1 booking)

---

**TABEL #8: `shake_history`** - Riwayat Shake
```sql
CREATE TABLE shake_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL UNIQUE,
  shake_count INTEGER DEFAULT 0
)
```
- **Fungsi:** Track user yang sudah shake (1x per user)

---

### 4️⃣ NAVIGATION & LAYOUT ⭐ WAJIB

#### **Arsitektur Navigasi:**

**Main Navigation (Bottom Navigation Bar):**

📁 **File:** `lib/screens/main_navigation.dart`

```
┌────────────────────────────────┐
│   Bottom Navigation (4 Tab)    │
├────────────────────────────────┤
│ 🏠 Home         (Tab 0)        │ → HomeNewScreen
│ ➕ Jual Motor   (Tab 1)        │ → TambahMotorScreen
│ 🔧 Motor Care   (Tab 2)        │ → BengkelVoucherScreen
│ 👤 Profile      (Tab 3)        │ → ProfileScreen
└────────────────────────────────┘
```

#### **Navigation Flow:**

```
App Start (main.dart)
    ↓
SplashScreen (3 detik loading)
    ↓
Check Login (SharedPreferences)
    ↓
├─ Sudah Login? → MainNavigation
│                     ↓
│                 ┌─────────────────┐
│                 │  4 Tab Screens  │
│                 ├─────────────────┤
│                 │ • HomeNewScreen │
│                 │ • TambahMotor   │
│                 │ • BengkelVoucher│
│                 │ • ProfileScreen │
│                 └─────────────────┘
│
└─ Belum Login? → LoginScreen
                      ↓
                  LoginForm
                      ↓
                  ┌──────────┐
                  │ Register │ atau Login
                  └──────────┘
                      ↓
                  MainNavigation
```

#### **List Semua Screens (23 screens):**

| Screen | Route | Fungsi |
|---|---|---|
| `SplashScreen` | Entry point | Logo + loading animation |
| `LoginScreen` | `/login` | Form login |
| `RegisterScreen` | `/register` | Form register |
| `MainNavigation` | `/main` | Bottom nav 4 tab |
| `HomeNewScreen` | Tab 0 | Marketplace motor bekas |
| `DetailMotorScreen` | `/detail/:id` | Detail motor + gallery |
| `EditMotorScreen` | `/edit/:id` | Edit motor listing |
| `TambahMotorScreen` | Tab 1 | Form upload motor |
| `FavoritesScreen` | `/favorites` | Wishlist motor |
| `BengkelVoucherScreen` | Tab 2 | Bengkel info + vouchers |
| `BookingFormScreen` | `/booking` | Form booking servis |
| `BookingCardScreen` | `/booking/card` | QR code booking |
| `ShakeVoucherScreen` | `/shake` | Shake untuk voucher |
| `LbsScreen` | `/lbs` | Google Maps bengkel |
| `ProfileScreen` | Tab 3 | User profile + logout |
| `HargaBaruScreen` | `/harga-baru` | Katalog motor baru (API) |
| `AksesorisListScreen` | `/aksesoris` | Katalog aksesoris (API) |
| `MotorMarketplaceScreen` | `/marketplace` | Browse motor bekas |
| `WaktuScreen` | `/waktu` | Pilih waktu booking |
| + 4 screens lainnya | - | - |

#### **Perpindahan Data Antar Screen:**

**Metode 1: Navigator.push dengan parameter**
```dart
// Pass data ke screen baru
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DetailMotorScreen(motor: motorObject)
  ),
);

// Di DetailMotorScreen, terima data via constructor
class DetailMotorScreen extends StatelessWidget {
  final MotorListing motor;
  DetailMotorScreen({required this.motor});
}
```

**Metode 2: Navigator.pop dengan result**
```dart
// Screen A: Tunggu result dari Screen B
final result = await Navigator.push(...);
if (result != null) {
  // Gunakan result
}

// Screen B: Return data saat pop
Navigator.pop(context, dataToReturn);
```

---

### 5️⃣ UI/UX DESIGN ⭐ WAJIB

#### **Design System:**

**Lokasi:** `lib/main.dart` → `_buildPremiumDarkTheme()` (sudah diberi komentar)

**Color Palette:**
```dart
Primary Color:    #2196F3  (Modern Blue)
Accent Color:     #1565C0  (Dark Blue)
Background:       #121212  (Pure Dark)
Card Background:  #1E1E1E  (Slightly Lighter)
Text Primary:     #FFFFFF  (White)
Text Secondary:   #B0B0B0  (Grey)
Error Color:      #FF5252  (Red)
```

**Material Design 3:**
- ✅ Modern flat design (elevation 0)
- ✅ Rounded corners (12-16px)
- ✅ Border glow effect (white transparent)
- ✅ Smooth animations & transitions
- ✅ Dark mode optimized

**Key UI Components:**

**1. Cards:**
```dart
Card(
  color: Color(0xFF1E1E1E),
  elevation: 0,  // Flat modern design
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: BorderSide(color: Colors.white.withOpacity(0.1)),
  ),
)
```

**2. Buttons:**
- Height: 56px (touch-friendly)
- Rounded: 12px
- Primary: Blue background + white text

**3. Bottom Navigation:**
- 4 fixed items
- Selected: Primary blue
- Unselected: Grey

---

## 🎁 FITUR BONUS (Nilai Tambah)

### 1. 📷 Image Picker & Compression (+3 poin)

**Package:** `image_picker: ^1.0.4`, `flutter_image_compress: ^2.1.0`

**Fitur:**
- Upload dari gallery atau camera
- Support multiple images (max 5 foto)
- Auto compression untuk hemat storage
- Image quality: 85%

**Implementasi:**
```dart
final picker = ImagePicker();
final pickedFile = await picker.pickImage(
  source: ImageSource.gallery,
  maxWidth: 1920,
  maxHeight: 1080,
  imageQuality: 85,
);
```

---

### 2. 📍 Location-Based Service (LBS) (+4 poin)

**Package:** `geolocator: ^10.1.0`, `google_maps_flutter: ^2.5.0`

**Fitur:**
- Deteksi lokasi user real-time (GPS)
- Hitung jarak ke bengkel (dalam km)
- Google Maps untuk navigasi
- Permission handling

**Flow:**
```
Request Location Permission
    ↓
Get Current Position (GPS)
    ↓
Get Bengkel Coordinates (dari database)
    ↓
Calculate Distance (Geolocator.distanceBetween)
    ↓
Display Distance (km) & Show on Map
```

---

### 3. 📳 Shake Detector (Sensor) (+3 poin)

**Package:** `sensors_plus: ^6.0.1`

**Fitur:**
- Deteksi gerakan shake HP
- Accelerometer sensor (X, Y, Z axis)
- Reward: Voucher diskon 15%
- Limit: 1x per user (lifetime)

**Cara Kerja:**
```dart
accelerometerEventStream().listen((event) {
  final acceleration = event.x.abs() + event.y.abs() + event.z.abs();
  
  if (acceleration > 25.0) {  // Threshold
    // SHAKE DETECTED!
    // → Generate voucher
    // → Save to database
    // → Send notification
  }
});
```

---

### 4. 🔔 Push Notifications (+3 poin)

**Package:** `flutter_local_notifications: ^17.2.3`

**3 Notification Channels:**
1. **Voucher Channel** - Notif dapat voucher
2. **Booking Channel** - Notif booking berhasil
3. **Motor Channel** - Notif motor baru

**Trigger:**
- Berhasil booking → Notif confirmation
- Dapat voucher → Notif reward
- Upload motor → Notif published

---

### 5. 🔐 Secure Authentication (+2 poin)

**Package:** `crypto: ^3.0.3`

**Security Layers:**
1. **Password Validation:** Min 6 char, huruf + angka
2. **Unique Salt:** 32 byte random per user
3. **SHA-256 Hashing:** Irreversible encryption

**Why Secure?**
- ✅ Password tidak pernah disimpan plaintext
- ✅ Prevent rainbow table attack
- ✅ Same password → different hash (karena beda salt)

---

### 6. 📊 QR Code Generator (+2 poin)

**Package:** `qr_flutter: ^4.1.0`

**Data QR:**
```
Format: "BOOKING_CODE|QUEUE_NUMBER|DATE|TIME"
Example: "BK20241203001|3|2024-12-10|09:00"
```

**Fungsi:** Scan di bengkel untuk check-in

---

### 7. 💱 Multi-Currency Converter (+1 poin)

**Real-time Exchange Rates dari Frankfurter API**

**Currencies:** IDR ↔ USD, EUR, JPY

**Penggunaan:** Tampilkan harga motor dalam 4 mata uang

---

### 8. 🔗 URL Launcher (+1 poin)

**Package:** `url_launcher: ^6.2.1`

**Fungsi:** Buka Instagram seller dari motor listing

---

## 🎬 SCENARIO DEMO LENGKAP

### Scenario 1: User Jual Motor (CRUD Create)

```
Step 1: Login ke aplikasi
Step 2: Tap tab "Jual Motor"
Step 3: Isi form lengkap:
        - Nama motor: "Honda CBR 250RR"
        - Brand: Honda
        - CC: 250
        - Tahun: 2020
        - Harga: 45.000.000
        - Kilometer: 5000
        - Kondisi: Bekas
        - Deskripsi
        - Lokasi (GPS auto-detect)
Step 4: Upload 3 foto (ImagePicker)
Step 5: Input Instagram link
Step 6: Klik "Publikasikan"
Step 7: ✅ Motor tersimpan ke database
Step 8: ✅ Notification muncul
Step 9: ✅ Motor tampil di home
```

**Perpindahan Data:**
```
Form Input
    ↓
MotorListing Object Created
    ↓
DatabaseHelper.insertMotorListing()
    ↓
SQLite INSERT query
    ↓
Return ID motor baru
    ↓
LocalNotification.show()
    ↓
Navigator.pop() → HomeScreen
    ↓
Reload data from database
    ↓
Motor muncul di ListView
```

---

### Scenario 2: Booking Servis dengan Voucher

```
Step 1: Tab "Motor Care"
Step 2: Lihat jarak ke bengkel (LBS)
Step 3: Tap "Booking Servis"
Step 4: Isi form:
        - Merk motor
        - Tipe motor
        - Tahun & plat nomor
        - Service type: Sedang (Rp 1.000.000)
        - Pilih tanggal
        - Pilih jam (08:00)
Step 5: Pilih voucher "SHAKE15" (diskon 15%)
Step 6: Lihat harga:
        - Original: Rp 1.000.000
        - Diskon: Rp 150.000
        - Final: Rp 850.000
Step 7: Klik "Konfirmasi Booking"
Step 8: ✅ Booking tersimpan
Step 9: ✅ Voucher di-mark as used
Step 10: ✅ Generate booking code & QR
Step 11: ✅ Notification muncul
Step 12: ✅ Tampil booking card dengan QR
```

---

### Scenario 3: Shake untuk Voucher

```
Step 1: Tab "Motor Care"
Step 2: Tap "Shake Voucher"
Step 3: Shake HP (goyang-goyang)
Step 4: Accelerometer detect gerakan
Step 5: Check database: sudah pernah shake?
        - Belum → Lanjut
        - Sudah → Show "Kamu sudah dapat voucher"
Step 6: ✅ Generate voucher:
        - Code: SKE-12345
        - Discount: 15%
        - Expiry: 30 hari
Step 7: ✅ Save ke database
Step 8: ✅ Mark user "sudah shake"
Step 9: ✅ Send notification
Step 10: ✅ Show success animation
```

---

## 📊 STRUKTUR PROJECT

```
lib/
├── main.dart                    # Entry point + theme
├── models/                      # Data models (10 models)
│   ├── user.dart
│   ├── motor_listing.dart      # Model motor bekas
│   ├── motor_baru.dart         # Model motor baru (API)
│   ├── booking.dart
│   ├── voucher.dart
│   ├── bengkel.dart
│   ├── exchange_rate.dart
│   ├── apparel.dart
│   ├── aksesoris.dart
│   └── booking_slot.dart
├── screens/                     # UI Screens (23 screens)
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── main_navigation.dart    # Bottom nav (4 tab)
│   ├── home_new_screen.dart
│   ├── detail_motor_screen.dart
│   ├── edit_motor_screen.dart
│   ├── tambah_motor_screen.dart
│   ├── favorites_screen.dart
│   ├── bengkel_voucher_screen.dart
│   ├── booking_form_screen.dart
│   ├── booking_card_screen.dart
│   ├── shake_voucher_screen.dart
│   ├── lbs_screen.dart
│   ├── profile_screen.dart
│   ├── harga_baru_screen.dart
│   └── ... (8 screens lainnya)
├── services/                    # Business logic (8 services)
│   ├── api_service.dart        # ⭐ API calls (sudah diberi komentar)
│   ├── auth_service.dart       # ⭐ Auth + SharedPreferences (sudah diberi komentar)
│   ├── database_helper.dart    # ⭐ SQLite CRUD (sudah diberi komentar)
│   ├── booking_service.dart
│   ├── lbs_service.dart
│   ├── shake_service.dart
│   ├── voucher_service.dart
│   └── local_notification_service.dart
├── utils/                       # Helper functions
│   ├── currency_helper.dart
│   └── timezone_helper.dart
└── widgets/                     # Reusable widgets
```

---

## ⚡ TEKNOLOGI & DEPENDENCIES

### Core Dependencies:

```yaml
dependencies:
  # Framework
  flutter: sdk
  
  # Database & Storage (MATERI WAJIB!)
  sqflite: ^2.3.0                    # SQLite database
  shared_preferences: ^2.2.2         # Local key-value storage
  path_provider: ^2.1.1              # File paths
  
  # Networking (MATERI WAJIB!)
  http: ^1.1.0                       # HTTP client untuk API
  
  # Location & Maps (FITUR BONUS!)
  geolocator: ^10.1.0                # GPS location
  permission_handler: ^11.0.1        # Runtime permissions
  google_maps_flutter: ^2.5.0        # Google Maps
  
  # Image Handling (FITUR BONUS!)
  image_picker: ^1.0.4               # Camera & gallery
  flutter_image_compress: ^2.1.0     # Image compression
  
  # Notifications (FITUR BONUS!)
  flutter_local_notifications: ^17.2.3  # Push notifications
  
  # Sensors (FITUR BONUS!)
  sensors_plus: ^6.0.1               # Accelerometer (shake)
  
  # QR Code (FITUR BONUS!)
  qr_flutter: ^4.1.0                 # QR generator
  
  # Security (FITUR BONUS!)
  crypto: ^3.0.3                     # SHA-256 hashing
  
  # Utilities
  intl: ^0.19.0                      # Date formatting
  timezone: ^0.9.2                   # Timezone
  url_launcher: ^6.2.1               # Open URLs
```

---

## ✅ KELEBIHAN APLIKASI

1. ✅ **Fitur Lengkap & Kompleks:** Marketplace + booking + voucher + LBS
2. ✅ **Full CRUD Implementation:** Create, Read, Update, Delete di motor listing
3. ✅ **Security Terjamin:** SHA-256 + salt untuk password
4. ✅ **Modern UI/UX:** Dark theme Material Design 3
5. ✅ **Real-time Data:** Currency API dengan rates terkini
6. ✅ **Gamification:** Shake detector untuk engagement
7. ✅ **Arsitektur Baik:** Separation of concerns (models, services, screens)
8. ✅ **Multiple APIs:** 4 API berbeda (memenuhi ketentuan)
9. ✅ **Location Features:** LBS + Google Maps integration
10. ✅ **Push Notifications:** User engagement tinggi
11. ✅ **Multi-platform Ready:** Android & iOS
12. ✅ **Image Management:** Multiple photos + compression
13. ✅ **Booking System:** Queue management + slot scheduling
14. ✅ **Voucher System:** Discount codes + expiry date
15. ✅ **QR Verification:** Modern booking verification

---

## ⚠️ KEKURANGAN / LIMITASI

1. ❌ **No Backend Server:** Data hanya lokal (SQLite), tidak ada cloud sync
2. ❌ **No Payment Gateway:** Booking belum terintegrasi payment
3. ❌ **Local Photo Storage:** Foto bisa penuh, belum ada cloud storage
4. ❌ **No Chat Feature:** Komunikasi buyer-seller via Instagram/kontak
5. ❌ **Single Bengkel:** Hanya support 1 bengkel, belum multi-bengkel
6. ❌ **No Search History:** Search tidak tersimpan
7. ❌ **No Rating/Review:** User tidak bisa kasih rating
8. ❌ **Shake Limited:** Hanya 1x per user selamanya
9. ❌ **Local Notifications Only:** Tidak ada push dari server
10. ❌ **No Social Login:** Hanya username/password

---

## 🎤 POIN-POIN PRESENTASI (10-15 menit)

### **PEMBUKAAN (1 menit)**
```
"Assalamualaikum, selamat pagi/siang.

Kami dari kelompok [NAMA KELOMPOK] akan mempresentasikan 
aplikasi Marketplace Motor Bekas dengan fitur booking servis bengkel.

Aplikasi ini menggunakan:
- 4 API berbeda (MockAPI + Frankfurter)
- SQLite database dengan 8 tabel
- SharedPreferences untuk session management
- Dan berbagai fitur bonus seperti LBS, shake detector, QR code.

Mari kami demo aplikasinya."
```

---

### **DEMO APLIKASI (7-8 menit)**

**1. Authentication & SharedPreferences (1 menit)**
- Buka app → SplashScreen
- Register akun baru
- Login
- **JELASKAN:** "Data session disimpan di SharedPreferences, 
  jadi user tetap login meskipun app ditutup."

**2. CRUD - Create Motor (2 menit)**
- Tap tab "Jual Motor"
- Isi form lengkap
- Upload 2-3 foto
- **JELASKAN:** "Foto di-compress otomatis, lalu path disimpan ke SQLite."
- Klik Publikasikan
- **JELASKAN:** "Ini adalah CREATE operation dalam CRUD."

**3. API Integration (1.5 menit)**
- Klik "Harga Motor Baru"
- **JELASKAN:** "Data ini dari MockAPI real-time."
- Pilih 1 motor
- **JELASKAN:** "Currency converter menggunakan Frankfurter API. 
  Harga dikonversi ke USD, EUR, JPY secara real-time."

**4. Shake Detector (1 menit)**
- Tab "Motor Care" → "Shake Voucher"
- Shake HP
- **JELASKAN:** "Accelerometer sensor mendeteksi gerakan. 
  User dapat voucher diskon 15%, hanya 1x seumur hidup."

**5. Booking dengan Voucher (1.5 menit)**
- Klik "Booking Servis"
- Isi form booking
- Pilih voucher
- **JELASKAN:** "Harga original dikurangi diskon voucher. 
  System generate booking code dan QR code otomatis."
- Konfirmasi
- **TUNJUKKAN:** QR code + notification

**6. LBS (Location-Based Service) (0.5 menit)**
- Klik "Lihat di Maps"
- **JELASKAN:** "GPS mendeteksi lokasi user dan hitung 
  jarak ke bengkel dalam kilometer."

**7. CRUD - Update & Delete (0.5 menit)**
- Edit motor yang tadi dibuat (UPDATE)
- Hapus motor (DELETE)
- **JELASKAN:** "Ini adalah UPDATE dan DELETE operation dalam CRUD."

---

### **PENJELASAN TEKNIS (2-3 menit)**

**1. API Integration:**
```
"Kami menggunakan 4 API berbeda:
- MockAPI untuk data motor baru, apparel, dan aksesoris
- Frankfurter API untuk real-time currency exchange

Semua API menggunakan HTTP GET, dengan error handling 
seperti timeout dan fallback values."
```

**2. Database (SQLite):**
```
"Database kami memiliki 8 tabel:
- users untuk autentikasi
- motor_listing untuk CRUD utama (Create, Read, Update, Delete)
- favorites untuk wishlist
- bookings untuk booking service
- dan 4 tabel lainnya untuk vouchers, slots, bengkel, shake history.

Semua operasi CRUD sudah terimplementasi lengkap."
```

**3. SharedPreferences:**
```
"SharedPreferences digunakan untuk session management.
Menyimpan 3 data: user_session (status login), username, dan user_id.
Data ini persistent, jadi user tetap login setelah app ditutup."
```

**4. Fitur Bonus:**
```
"Kami implementasi beberapa fitur bonus:
- LBS dengan Google Maps dan GPS
- Shake detector menggunakan accelerometer sensor
- Push notifications untuk engagement
- QR code untuk verifikasi booking
- Multi-currency converter real-time
- Secure authentication dengan SHA-256 hashing
- Image picker dengan compression"
```

---

### **KELEBIHAN & KEKURANGAN (1.5 menit)**

**Kelebihan:**
```
"Kelebihan aplikasi kami:
1. Fitur sangat lengkap - marketplace + booking + voucher
2. Full CRUD implementation di motor listing
3. Security bagus dengan password hashing SHA-256
4. UI modern dengan dark theme Material Design 3
5. Real-time data dari API eksternal
6. Banyak fitur bonus yang menambah nilai"
```

**Kekurangan:**
```
"Untuk kekurangan:
1. Data masih lokal (SQLite), belum ada cloud sync
2. Belum ada payment gateway untuk booking
3. Foto disimpan lokal, bisa penuh storage
4. Chat feature belum ada, komunikasi via Instagram

Untuk improvement selanjutnya, kami bisa 
tambahkan backend server dan cloud storage."
```

---

### **PEMBAGIAN TUGAS (1 menit)**

```
"Pembagian tugas kelompok kami:

Anggota 1 ([NAMA]):
- UI/UX design dan semua screens
- Navigation system
- Image picker implementation
- Testing UI flow

Anggota 2 ([NAMA]):
- API integration (4 APIs)
- Database design dan CRUD operations
- Authentication system
- Services logic (booking, voucher, LBS, shake)
- Testing business logic

Kolaborasi bersama:
- Project setup
- Integration testing
- Bug fixing
- Documentation"
```

---

### **PENUTUP (0.5 menit)**

```
"Demikian presentasi kami. 
Aplikasi ini sudah memenuhi semua ketentuan wajib:
- API Integration ✅
- SharedPreferences ✅
- Local Database ✅
- CRUD Operations ✅
- Navigation & UI ✅

Plus berbagai fitur bonus yang menambah nilai.

Terima kasih atas perhatiannya. 
Kami siap untuk sesi tanya jawab."
```

---

## 🔍 PERTANYAAN YANG MUNGKIN DITANYA

### Q1: "Jelaskan API yang kalian gunakan dan mengapa pilih API tersebut?"

**Jawaban:**
```
"Kami menggunakan 4 API:

1. MockAPI untuk data motor baru - karena gratis, mudah setup, 
   dan responsenya cepat. Perfect untuk demo project.

2. Frankfurter API untuk currency exchange - karena gratis, 
   real-time rates, dan reliable. Tidak perlu API key.

3. MockAPI untuk apparel dan aksesoris - konsistensi dengan 
   motor API, dan mudah di-manage.

Alasan pilih MockAPI: free, CRUD support jika diperlukan, 
dan response time cepat. Untuk production nanti bisa 
diganti dengan backend custom."
```

---

### Q2: "Apa bedanya SharedPreferences dan SQLite?"

**Jawaban:**
```
"SharedPreferences adalah key-value storage untuk data 
kecil dan sederhana seperti:
- Session login (boolean)
- Username (string)
- User preferences

SQLite adalah relational database untuk data kompleks 
dan terstruktur seperti:
- Motor listings (dengan banyak field)
- Bookings (dengan relasi ke users dan bengkel)
- Supports query, JOIN, foreign keys

Di aplikasi kami:
- SharedPreferences untuk session management
- SQLite untuk semua data bisnis (users, motors, bookings, dll)"
```

---

### Q3: "Jelaskan alur data saat user upload motor!"

**Jawaban:**
```
"Flow upload motor:

1. User isi form di TambahMotorScreen
2. Upload foto menggunakan ImagePicker (max 5 foto)
3. Foto di-compress untuk hemat storage
4. Foto disimpan ke local storage, kita dapat path-nya
5. Semua data (nama, brand, cc, harga, foto paths, dll) 
   dikumpulkan jadi object MotorListing
6. Call DatabaseHelper.insertMotorListing()
7. SQLite execute INSERT query
8. Dapat ID motor yang baru di-insert
9. Show notification 'Motor berhasil dipublikasi'
10. Navigate back ke HomeScreen
11. HomeScreen reload data dari database
12. Motor baru muncul di list

Perpindahan data: 
UI Form → MotorListing Object → DatabaseHelper → SQLite"
```

---

### Q4: "Bagaimana cara kalian handle security password?"

**Jawaban:**
```
"Kami pakai 3 layer security:

1. Password Validation:
   - Minimal 6 karakter
   - Harus ada huruf dan angka
   
2. Unique Salt:
   - Setiap user dapat salt random 32 byte yang berbeda
   - Prevent rainbow table attack
   
3. SHA-256 Hashing:
   - Password + salt di-hash dengan SHA-256
   - Hasil hash (64 karakter hex) yang disimpan di database
   - Password asli tidak pernah disimpan

Saat login:
- Password input di-hash dengan salt user tersebut
- Hash dibandingkan dengan hash di database
- Match → login berhasil

Ini secure karena:
- Password tidak bisa di-decrypt (irreversible)
- Same password, different user → different hash (karena beda salt)"
```

---

### Q5: "Kenapa CRUD hanya di motor listing, tidak di API?"

**Jawaban:**
```
"Sesuai ketentuan project, CRUD tidak wajib di API. 
Kami fokus CRUD di local database (SQLite) karena:

1. API yang kami pakai (MockAPI) hanya untuk katalog 
   motor baru yang read-only
   
2. CRUD utama ada di motor listing untuk iklan motor bekas 
   yang dibuat oleh user
   
3. User bisa:
   - CREATE: Upload motor baru
   - READ: Lihat list dan detail motor
   - UPDATE: Edit data motor mereka
   - DELETE: Hapus motor listing
   
Untuk production, bisa ditambahkan backend custom dengan 
API CRUD lengkap dan cloud storage."
```

---

### Q6: "Jelaskan cara kerja shake detector!"

**Jawaban:**
```
"Shake detector menggunakan accelerometer sensor:

1. Listen ke accelerometer stream (X, Y, Z axis)
2. Hitung total acceleration: |x| + |y| + |z|
3. Jika total > threshold (25.0) → shake detected
4. Ada cooldown 1000ms untuk prevent spam detection
5. Check database: user sudah pernah shake?
6. Jika belum:
   - Generate voucher dengan code random (SKE-XXXXX)
   - Diskon 15%, expiry 30 hari
   - Save ke database (table vouchers)
   - Mark user sebagai 'sudah shake' (table shake_history)
   - Send local notification
7. Jika sudah → show message 'Kamu sudah dapat voucher'

Ini prevent abuse karena 1 user hanya bisa shake 1x seumur hidup.
Data tersimpan di SQLite, jadi meskipun reinstall app, 
user tidak bisa shake lagi (kecuali buat akun baru)."
```

---

### Q7: "Bagaimana cara mencegah double booking?"

**Jawaban:**
```
"Kami punya table booking_slots dengan UNIQUE constraint:

CREATE TABLE booking_slots (
  ...
  UNIQUE(bengkel_id, date, time_slot)
)

Flow booking:
1. User pilih tanggal dan jam
2. Check slot di database: is_booked = 0? (available)
3. Jika available:
   - Create booking
   - Update slot: set is_booked = 1
   - Generate queue number
4. Jika sudah booked → show error 'Slot sudah penuh'

Jadi 1 slot (bengkel + tanggal + jam) hanya bisa untuk 1 booking.
Plus ada queue number untuk urutan service di hari yang sama."
```

---

### Q8: "Apa tantangan terbesar saat develop?"

**Jawaban:**
```
"Tantangan utama:

1. Database Design:
   - Design schema 8 tabel dengan relasi yang benar
   - Foreign keys dan UNIQUE constraints
   - Migration saat struktur berubah

2. Image Handling:
   - Manage multiple photos (5 foto)
   - Compression untuk hemat storage
   - Handle permissions (camera & storage)

3. State Management:
   - Sync data antar screen setelah CRUD
   - Refresh UI setelah database update
   - Handle async operations

4. LBS Integration:
   - Request permissions runtime
   - Handle GPS unavailable
   - Calculate distance accuracy

5. Testing:
   - Edge cases (API timeout, no internet, GPS off)
   - Error handling di semua service

Solusi: Research documentation, trial-error, 
code refactoring, dan testing berulang kali."
```

---

## 📂 FILE PENTING YANG SUDAH DIBERI KOMENTAR

Semua file berikut sudah saya tambahkan komentar lengkap untuk memudahkan presentasi:

1. ⭐ `lib/services/api_service.dart` - API integration
2. ⭐ `lib/services/auth_service.dart` - Authentication & SharedPreferences
3. ⭐ `lib/services/database_helper.dart` - SQLite database operations
4. ⭐ `lib/main.dart` - Entry point & theme

**Baca komentar di file-file tersebut untuk memahami detail implementasi!**

---

## 📝 TEMPLATE PEMBAGIAN TUGAS

### **Anggota 1: [NAMA] - [NIM]**

**Tanggung Jawab:**
- [ ] UI/UX Design (Theme, Colors, Layouts)
- [ ] Semua UI Screens (23 screens)
- [ ] Navigation system & routing
- [ ] Image picker implementation
- [ ] QR code display
- [ ] Animations & transitions
- [ ] UI testing & debugging

**File yang Dikerjakan:**
- `lib/screens/*` (semua screen files)
- `lib/main.dart` (theme configuration)
- `lib/widgets/*` (reusable components)

---

### **Anggota 2: [NAMA] - [NIM]**

**Tanggung Jawab:**
- [ ] API Integration (4 APIs)
- [ ] Database design & implementation (8 tables)
- [ ] CRUD operations (SQLite)
- [ ] Authentication system (SHA-256 + salt)
- [ ] Booking logic & voucher system
- [ ] LBS implementation
- [ ] Shake detector (sensor)
- [ ] Push notifications
- [ ] Business logic testing

**File yang Dikerjakan:**
- `lib/services/*` (semua service files)
- `lib/models/*` (data models)
- `lib/utils/*` (helper functions)

---

### **Kolaborasi Bersama:**
- [ ] Project setup & dependencies
- [ ] Database schema planning
- [ ] Navigation flow design
- [ ] Integration testing
- [ ] Bug fixing & optimization
- [ ] Documentation
- [ ] GitHub repository management
- [ ] Presentation preparation

---

## ✅ CHECKLIST SEBELUM PRESENTASI

**Persiapan Teknis:**
- [ ] Laptop fully charged
- [ ] HP Android/iOS atau emulator siap
- [ ] App sudah di-install & tested
- [ ] Internet connection stable (untuk API)
- [ ] Backup data untuk demo (motor, user, dll)
- [ ] Backup video demo (jika live demo error)

**Persiapan Materi:**
- [ ] Slide presentasi (jika ada)
- [ ] GitHub repo link siap
- [ ] Pembagian tugas jelas
- [ ] Sudah latihan demo minimal 3x
- [ ] Hafal poin-poin penting
- [ ] Siap jawab pertanyaan

**Persiapan Mental:**
- [ ] Timer 10-15 menit siap
- [ ] Pembagian waktu bicara sudah diatur
- [ ] Backup plan jika ada error
- [ ] Confident & ready!

---

## 💡 TIPS PRESENTASI

### **DO's (Yang Harus Dilakukan):**
✅ **Practice Demo:** Latihan minimal 3x, pastikan lancar  
✅ **Explain Flow:** Jelaskan alur data, tidak hanya show UI  
✅ **Show Code:** Tunjukkan kode penting (API, database, dll)  
✅ **Be Honest:** Jujur tentang kekurangan + kasih solusi  
✅ **Time Management:** Pakai timer, max 15 menit  
✅ **Eye Contact:** Tatap penguji/kamera  
✅ **Speak Clear:** Bicara jelas, tidak terburu-buru  
✅ **Backup Plan:** Siapkan video demo jika live error  

### **DON'Ts (Yang Harus Dihindari):**
❌ **Jangan Baca Teks:** Presentasi bukan membaca  
❌ **Jangan Bertele-tele:** Langsung to the point  
❌ **Jangan Bohong:** Jika tidak tahu, akui saja  
❌ **Jangan Panik:** Tetap tenang jika ada error  
❌ **Jangan Monopoli:** Bagi waktu dengan anggota tim  

---

## 📊 SUMMARY KETENTUAN PROJECT

### **Materi Wajib (Core Features):**
- ✅ **API Integration** → 4 APIs (MockAPI + Frankfurter)
- ✅ **SharedPreferences** → Session management
- ✅ **Local Database** → SQLite 8 tables
- ✅ **CRUD** → Full CRUD di motor_listing
- ✅ **Navigation** → 23 screens + bottom nav
- ✅ **UI** → Modern dark theme Material Design 3

### **Materi Sunnah (Bonus Features):**
- ✅ **LBS** → GPS + Google Maps (+4 poin)
- ✅ **Image Picker** → Camera + Gallery (+3 poin)
- ✅ **Shake Detector** → Accelerometer sensor (+3 poin)
- ✅ **Push Notifications** → Engagement (+3 poin)
- ✅ **Secure Auth** → SHA-256 hashing (+2 poin)
- ✅ **QR Code** → Booking verification (+2 poin)
- ✅ **Multi-Currency** → Real-time converter (+1 poin)
- ✅ **URL Launcher** → Instagram links (+1 poin)

**Total Bonus:** ~19 poin (maksimal 15 poin)

---

## 🎓 KESIMPULAN

Aplikasi ini **MEMENUHI SEMUA** ketentuan project:
- ✅ API Integration (4 APIs berbeda)
- ✅ SharedPreferences (session login)
- ✅ SQLite Database (8 tables)
- ✅ Full CRUD (motor listing)
- ✅ Navigation & Layout (23 screens)
- ✅ UI menarik & interaktif

**Plus 8 fitur bonus** yang menambah nilai signifikan!

Aplikasi ini menunjukkan pemahaman yang baik tentang:
- Mobile app development dengan Flutter
- API integration & JSON parsing
- Database design & SQL operations
- State management & navigation
- Security (encryption & authentication)
- Modern UI/UX design
- Sensor integration & permissions

---

## 📞 RESOURCES

- **GitHub Repo:** FinalProject_PAM_124230110
- **Owner:** rhmnnbl26
- **Files dengan Komentar Lengkap:**
  - `lib/services/api_service.dart`
  - `lib/services/auth_service.dart`
  - `lib/services/database_helper.dart`
  - `lib/main.dart`

**Additional Files:**
- `CODE_CHEATSHEET.md` - Kode-kode penting
- `QUICK_REFERENCE.md` - Ringkasan cepat
- `PRESENTATION_GUIDE.md` - File ini

---

**GOOD LUCK dengan presentasi! 🚀🎉**

*Semoga sukses dan mendapat nilai terbaik!*

---

*Dokumen ini dibuat untuk membantu presentasi final project praktikum PAM.*  
*Last updated: 3 Desember 2024*
