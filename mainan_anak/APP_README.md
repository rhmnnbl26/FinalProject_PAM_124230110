# Children's Toys - Aplikasi Marketplace Motor Besar

Aplikasi mobile marketplace untuk jual-beli motor besar (600-1000cc) bekas di wilayah Yogyakarta.

## 📱 Fitur Utama

### 1. **Autentikasi**
- Register dan Login dengan SHA-256 password hashing
- Session management menggunakan SharedPreferences
- Splash screen dengan auto-login

### 2. **Jual-Beli Motor**
- Daftar motor yang dijual dengan fitur search, filter, dan sorting
- Detail motor dengan foto carousel
- Tambah motor dengan upload 3-5 foto lokal
- Link ke Instagram penjual untuk transaksi

### 3. **Harga Motor Baru (API)**
- Menampilkan daftar harga motor baru dari MockAPI
- Konversi mata uang real-time (IDR, USD, EUR, JPY)
- Menggunakan Frankfurter API untuk exchange rate

### 4. **Location Based Service**
- Menghitung jarak ke bengkel terdekat
- Menggunakan GPS lokasi pengguna
- Menampilkan informasi bengkel

### 5. **Konversi Waktu**
- Tampilan waktu multi-zona (WIB, WITA, WIT, London)
- Update real-time setiap detik
- Format 24 jam

### 6. **Notifikasi Lokal**
- Notifikasi saat berhasil menambah motor
- Menggunakan flutter_local_notifications

### 7. **Profil**
- Informasi pengguna
- Saran dan kesan mata kuliah PAM
- Logout

## 🛠️ Tech Stack

- **Framework**: Flutter/Dart
- **Database**: SQLite (sqflite)
- **Local Storage**: SharedPreferences, path_provider
- **API**: HTTP, MockAPI, Frankfurter API
- **Location**: Geolocator, Permission Handler
- **Notifications**: Flutter Local Notifications
- **Image Handling**: Image Picker
- **Utilities**: Intl (formatting), Crypto (hashing), URL Launcher

## 📦 Instalasi

1. **Clone repository**
   ```bash
   git clone <repository-url>
   cd mainan_anak
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run aplikasi**
   ```bash
   flutter run
   ```

## 🔧 Konfigurasi

### API Endpoints

1. **MockAPI - Harga Motor Baru**
   - Base URL: `https://69063273ee3d0d14c13529b5.mockapi.io`
   - Endpoint: `/motor`

2. **Exchange Rate API**
   - Base URL: `https://api.frankfurter.app`
   - Endpoint: `/latest?from=IDR&to=USD,EUR,JPY`

### Database Schema

#### Tabel `users`
- id (INTEGER PRIMARY KEY)
- username (TEXT UNIQUE)
- password_hash (TEXT)
- salt (TEXT)

#### Tabel `motor_listing`
- id (INTEGER PRIMARY KEY)
- nama, brand, deskripsi (TEXT)
- cc, tahun, kilometer (INTEGER)
- harga_idr (REAL)
- kondisi, lokasi (TEXT)
- foto_path_1 to foto_path_5 (TEXT nullable)
- instagram_link (TEXT)
- kontak_opsional (TEXT nullable)

#### Tabel `bengkel`
- id (INTEGER PRIMARY KEY)
- nama (TEXT)
- latitude, longitude (REAL)

## 📱 Permissions Required

### Android
- INTERNET
- ACCESS_FINE_LOCATION
- ACCESS_COARSE_LOCATION
- READ_EXTERNAL_STORAGE
- WRITE_EXTERNAL_STORAGE (SDK ≤ 32)
- POST_NOTIFICATIONS

## 📂 Struktur Folder

```
lib/
├── main.dart
├── models/
│   ├── user.dart
│   ├── motor_listing.dart
│   ├── bengkel.dart
│   ├── motor_baru.dart
│   └── exchange_rate.dart
├── services/
│   ├── database_helper.dart
│   ├── auth_service.dart
│   ├── api_service.dart
│   ├── notification_service.dart
│   └── lbs_service.dart
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── main_navigation.dart
│   ├── home_screen.dart
│   ├── detail_motor_screen.dart
│   ├── tambah_motor_screen.dart
│   ├── harga_baru_screen.dart
│   ├── waktu_screen.dart
│   ├── lbs_screen.dart
│   └── profile_screen.dart
└── utils/
    ├── timezone_helper.dart
    └── currency_helper.dart
```

## 🎯 Cara Menggunakan

1. **Register/Login**
   - Buat akun baru atau login dengan akun existing
   - Password otomatis di-hash dengan SHA-256

2. **Melihat Motor**
   - Browse daftar motor di Home
   - Gunakan search untuk cari motor tertentu
   - Filter berdasarkan Brand, CC, Kondisi
   - Sort by price (ascending/descending)

3. **Menambah Motor**
   - Klik tab "Tambah Motor"
   - Isi semua field yang wajib (*)
   - Upload 3-5 foto motor
   - Submit untuk menyimpan
   - Notifikasi akan muncul saat berhasil

4. **Cek Harga Baru**
   - Klik tab "Harga Baru"
   - Lihat daftar motor baru dari API
   - Toggle currency untuk konversi (IDR/USD/EUR/JPY)

5. **Fitur Tambahan**
   - **Konversi Waktu**: Akses dari menu Profile
   - **Lokasi Bengkel**: Akses dari menu Profile
   - Berikan izin lokasi untuk menghitung jarak

## 🔐 Security

- Password di-hash menggunakan SHA-256 + static salt
- Tidak ada plaintext password yang disimpan
- Session management untuk auto-login
- SQLite untuk penyimpanan lokal yang aman

## 📝 Notes

- Aplikasi hanya untuk area Yogyakarta
- Tidak ada radius pencarian LBS
- Foto motor disimpan lokal, tidak di-upload ke server
- Transaksi dilakukan via Instagram (link eksternal)
- Notifikasi hanya lokal, tidak push notification

## 👨‍💻 Developer

Aplikasi ini dibuat sebagai tugas akhir mata kuliah **Pemrograman Aplikasi Mobile**.

## 📄 License

This project is for educational purposes.
