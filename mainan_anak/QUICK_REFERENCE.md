# 🚀 QUICK REFERENCE - Ringkasan Cepat Presentasi

## 📌 POIN UTAMA (Wajib Hapal!)

### 1. API Integration (4 APIs)
```
✅ MockAPI Motor Baru    → Data katalog motor
✅ Frankfurter Currency  → Real-time exchange rates  
✅ MockAPI Apparel       → Katalog pakaian motor
✅ MockAPI Aksesoris     → Katalog aksesoris motor
```
📁 **File:** `lib/services/api_service.dart`

### 2. SharedPreferences (Session Storage)
```
✅ user_session  → bool   (login status)
✅ username      → String (current user)
✅ user_id       → int    (relasi database)
```
📁 **File:** `lib/services/auth_service.dart`

### 3. SQLite Database (8 Tabel)
```
✅ users            → Akun user
✅ motor_listing    → Iklan motor (CRUD UTAMA!)
✅ favorites        → Wishlist
✅ bengkel          → Data bengkel
✅ vouchers         → Diskon
✅ bookings         → Booking servis
✅ booking_slots    → Jadwal
✅ shake_history    → Track shake
```
📁 **File:** `lib/services/database_helper.dart`

### 4. CRUD Operations (Motor Listing)
```
CREATE  → Tambah motor (TambahMotorScreen)
READ    → List motor (HomeScreen)
UPDATE  → Edit motor (EditMotorScreen)
DELETE  → Hapus motor (DetailMotorScreen)
```

---

## 🎯 DEMO FLOW (10 menit)

### Demo #1: Register & Login (1 menit)
1. Buka app → SplashScreen
2. Register akun baru
3. Login dengan akun tersebut
4. **Tunjukkan:** SharedPreferences menyimpan session

### Demo #2: Jual Motor - CRUD Create (2 menit)
1. Tab "Jual Motor"
2. Isi form lengkap
3. Upload 2-3 foto (ImagePicker)
4. Publikasikan
5. **Tunjukkan:** Motor muncul di home

### Demo #3: API Integration (2 menit)
1. Klik "Harga Motor Baru"
2. **Tunjukkan:** Data dari MockAPI
3. Pilih 1 motor
4. **Tunjukkan:** Currency converter (4 mata uang)

### Demo #4: Shake Voucher (1 menit)
1. Tab "Motor Care" → "Shake Voucher"
2. Shake HP
3. **Tunjukkan:** Dapat voucher + notifikasi

### Demo #5: Booking dengan Voucher (2 menit)
1. Klik "Booking Servis"
2. Isi data motor
3. Pilih voucher yang tadi didapat
4. **Tunjukkan:** Harga original vs final (discount)
5. Booking
6. **Tunjukkan:** QR Code

### Demo #6: LBS & Maps (1 menit)
1. Klik "Lihat di Maps"
2. **Tunjukkan:** Jarak ke bengkel (GPS)

### Demo #7: CRUD Update & Delete (1 menit)
1. Edit motor yang tadi dibuat
2. Hapus motor
3. **Tunjukkan:** Refresh → motor hilang

---

## 💡 JAWABAN PERTANYAAN UMUM

### "Jelaskan API yang digunakan?"
> "Kami pakai 4 API: MockAPI untuk katalog motor/apparel/aksesoris, dan Frankfurter API untuk real-time currency exchange. Semua API menggunakan HTTP GET dengan parsing JSON."

### "Bedanya SharedPreferences vs SQLite?"
> "SharedPreferences untuk data simpel (session login), SQLite untuk data kompleks (motor, bookings, dll) dengan relasi tabel."

### "Apa CRUD yang kalian implementasikan?"
> "Full CRUD di motor listing: Create (upload motor), Read (list & detail), Update (edit motor), Delete (hapus motor). Semua operasi di SQLite lokal."

### "Bagaimana cara kerja shake detector?"
> "Pakai sensors_plus untuk listen accelerometer. Jika total acceleration > threshold, shake terdeteksi. User hanya bisa shake 1x (disimpan di database)."

### "Bagaimana prevent double booking?"
> "Ada tabel booking_slots dengan UNIQUE constraint (bengkel_id, date, time_slot). Satu slot hanya bisa 1 booking."

---

## 🔥 FITUR BONUS (Nilai Tambah)

```
📷 Image Picker         → Upload foto motor
📍 LBS & Google Maps    → Lokasi bengkel
📳 Shake Detector       → Gamification voucher
🔔 Push Notifications   → Engagement
🔐 SHA-256 Hashing      → Security
📊 QR Code             → Modern verification
💱 Multi-Currency       → International ready
```

---

## ⚙️ TEKNOLOGI STACK

```
Framework:   Flutter 3.9.2
Language:    Dart
Database:    SQLite (sqflite ^2.3.0)
Storage:     SharedPreferences ^2.2.2
Networking:  HTTP ^1.1.0
Location:    Geolocator ^10.1.0
Sensors:     Sensors Plus ^6.0.1
Crypto:      SHA-256 (crypto ^3.0.3)
```

---

## 📊 STATISTIK PROJECT

```
Total Screens:   23
Total Services:  8
Total Models:    10
Database Tables: 8
APIs:            4
Packages:        15+
```

---

## ✅ CHECKLIST PRESENTASI

- [ ] Laptop fully charged
- [ ] HP Android/emulator siap
- [ ] App sudah di-install & siap demo
- [ ] Backup video demo (jika live demo error)
- [ ] Slide presentasi (opsional)
- [ ] Internet connection (untuk API)
- [ ] GitHub repo link siap dibagikan
- [ ] Pembagian tugas sudah jelas
- [ ] Timer 10-15 menit
- [ ] Sudah latihan demo 3x

---

## 🎤 OPENING & CLOSING

**Opening:**
> "Assalamualaikum, kami dari kelompok [X] akan mempresentasikan aplikasi marketplace motor bekas dengan fitur booking servis bengkel. Aplikasi ini menggunakan 4 API berbeda, SQLite database dengan 8 tabel, dan fitur-fitur modern seperti LBS, shake detector, dan QR code."

**Closing:**
> "Demikian presentasi kami. Aplikasi ini sudah memenuhi semua ketentuan wajib plus beberapa fitur bonus. Terima kasih atas perhatiannya. Kami siap untuk sesi tanya jawab."

---

**GOOD LUCK! 🚀**
