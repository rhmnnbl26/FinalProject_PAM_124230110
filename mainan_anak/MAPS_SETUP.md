# Setup Google Maps API

## Langkah-langkah mendapatkan API Key:

1. **Buka Google Cloud Console**
   - Kunjungi: https://console.cloud.google.com/
   - Login dengan akun Google Anda

2. **Buat Project Baru (atau gunakan yang sudah ada)**
   - Klik dropdown project di header
   - Klik "New Project"
   - Beri nama: "Mainan Anak Motor App"
   - Klik "Create"

3. **Enable Maps SDK for Android**
   - Di menu sebelah kiri, pilih "APIs & Services" > "Library"
   - Cari "Maps SDK for Android"
   - Klik dan tekan "ENABLE"

4. **Buat API Key**
   - Pilih "APIs & Services" > "Credentials"
   - Klik "+ CREATE CREDENTIALS" > "API Key"
   - API Key akan muncul (salin key ini)

5. **Restrict API Key (Opsional tapi disarankan)**
   - Klik API Key yang baru dibuat
   - Di bagian "Application restrictions":
     - Pilih "Android apps"
     - Klik "Add an item"
     - Package name: `com.example.mainan_anak` (sesuai applicationId di build.gradle.kts)
     - SHA-1: Dapatkan dengan command:
       ```bash
       cd android
       ./gradlew signingReport
       ```
       Copy SHA-1 dari variant "debug"
   - Di bagian "API restrictions":
     - Pilih "Restrict key"
     - Centang "Maps SDK for Android"
   - Klik "SAVE"

6. **Tambahkan API Key ke AndroidManifest.xml**
   - Buka: `android/app/src/main/AndroidManifest.xml`
   - Ganti `YOUR_API_KEY_HERE` dengan API Key Anda:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="AIzaSy..." />
   ```

7. **Rebuild aplikasi**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## Fitur LBS dengan Maps:

Aplikasi sekarang menampilkan:
- **Google Maps** dengan 2 marker:
  - 🔴 Marker Merah: Lokasi Bengkel di Yogyakarta (Koordinat: -7.7956, 110.3695)
  - 🔵 Marker Biru: Lokasi Anda saat ini
- **Perhitungan jarak** real-time antara lokasi Anda dengan bengkel
- **Auto-zoom** untuk menampilkan kedua marker
- **My Location button** untuk kembali ke posisi Anda
- **Zoom controls** untuk zoom in/out

## Koordinat Bengkel:

Aplikasi menggunakan koordinat default:
- **Latitude**: -7.7956
- **Longitude**: 110.3695
- **Lokasi**: Pusat Kota Yogyakarta (dekat Malioboro)

Koordinat ini diset di `database_helper.dart` saat inisialisasi database pertama kali.

## Troubleshooting:

Jika maps tidak muncul:
1. Pastikan API Key valid dan sudah di-enable
2. Pastikan Maps SDK for Android sudah enabled di Google Cloud Console
3. Cek logcat untuk error messages
4. Pastikan permission lokasi sudah diberikan
5. Pastikan internet tersambung

## Catatan Penting:

⚠️ Jangan commit API Key ke Git! Tambahkan ke `.gitignore` atau gunakan environment variables untuk production.
