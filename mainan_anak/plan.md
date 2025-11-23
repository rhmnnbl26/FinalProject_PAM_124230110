# Dokumen Desain Aplikasi Mobile

# **Children's Toys**

Aplikasi **Children's Toys** adalah platform mobile berbasis Flutter/Dart yang berfokus pada jual–beli motor besar (600–1000cc) bekas di wilayah Yogyakarta. Aplikasi ini dirancang sebagai marketplace yang sederhana, aman, dan cepat, dengan integrasi API, database lokal, LBS, serta beberapa fitur utilitas pendukung.

Dokumen ini berfungsi sebagai *product description* yang jelas dan siap diberikan ke AI developer assistant untuk membantu proses pembuatan kode.

## 1. **Tujuan Aplikasi**

Aplikasi ini bertujuan untuk mempermudah pengguna dalam:

* Melihat listing motor besar bekas di Yogyakarta.
* Menjual motor mereka melalui form input dan unggah foto (lokal).
* Mengakses harga motor baru melalui MockAPI.
* Menghubungi penjual lewat link Instagram atau kontak tambahan.
* Menggunakan fitur konversi harga otomatis IDR → USD, EUR, JPY.
* Memanfaatkan fitur LBS untuk mengetahui jarak pengguna ke bengkel.
* Melihat waktu dalam berbagai zona (WIB, WITA, WIT, London).

Ruang lingkup dibatasi untuk area Yogyakarta tanpa radius pencarian.

---

## 2. **Nama Aplikasi**

**Children's Toys**

---

## 3. **MockAPI Endpoint**

URL: **[https://69063273ee3d0d14c13529b5.mockapi.io/:endpoint](https://69063273ee3d0d14c13529b5.mockapi.io/:endpoint)**

Digunakan untuk menampilkan **harga motor baru**. Contoh data:

* id
* nama
* merk
* harga_idr
* kategori
* gambar
* deskripsi

---

## 4. **Fitur Utama Aplikasi**

### 4.1. Fitur Jual–Beli Motor

* Pengguna dapat melihat list motor yang dijual.
* Ketika item motor diklik, pengguna masuk ke **Detail Motor**.
* Tombol **Beli** akan mengarahkan ke postingan Instagram penjual.
* Opsional: Menampilkan kontak penjual.

### 4.2. Input Motor untuk Dijual

Field wajib:

1. Nama motor
2. Brand/merk
3. Deskripsi
4. CC mesin
5. Tahun
6. Harga IDR
7. Kilometer
8. Kondisi (baru/bekas)
9. Lokasi (statis)
10. Foto 3–5 file (disimpan lokal, bukan upload server)

Setelah data tersimpan, muncul **notifikasi lokal**.

---

### 4.3. Fitur API Harga Motor Baru

Aplikasi menampilkan list harga motor terbaru berdasarkan data dari MockAPI. Harga IDR dapat dikonversi ke:

* USD
* EUR
* JPY

Menggunakan API publik untuk exchange rate. ( mis. frankfurter.app )

---

### 4.4. Konversi Mata Uang

* Default data dari API MockAPI adalah rupiah.
* Tombol toggle/selector currency akan menampilkan harga dalam kurs lain.
* Exchange rate diambil secara real-time.

---

### 4.5. Fitur LBS – Lokasi Bengkel

* Aplikasi menghitung jarak antara posisi user dan satu titik bengkel statis.
* Digunakan ketika user ingin mengecek kondisi motor untuk proses jual.
* Menggunakan **geolocator.distanceBetween()**.

Tidak ada radius pencarian.

---

### 4.6. Fitur Konversi Waktu

* Menampilkan waktu dalam zona:

  * WIB
  * WITA
  * WIT
  * London (GMT/BST)
* Format 24 jam.
* Mengikuti timezone device user.
* Menyediakan toggle untuk mengganti tampilan zona waktu.

---

### 4.7. Autentikasi (Login / Register)

* Login/Register berbasis **SQLite**.
* Password di-hash menggunakan **SHA-256 + static salt**.
* Session disimpan menggunakan **SharedPreferences**.
* Tidak memerlukan verifikasi email.
* Session expiry sederhana: dihapus manual saat logout.

---

### 4.8. Navigasi & Struktur Menu

Aplikasi menggunakan bottom navigation atau button navigation dengan menu:

1. **Home** – List motor yang dijual.
2. **Tambah Motor** – Form input motor.
3. **Harga Baru** – List harga motor dari MockAPI.
4. **Profil** – Menampilkan:

   * Foto profil
   * Saran & kesan mata kuliah Pemrograman Aplikasi Mobile (hanya display)
   * Logout

---

### 4.9. Fitur Pencarian, Filter & Sorting

* Searching berdasarkan nama motor.
* Filter berdasarkan:

  * CC
  * Brand
  * Tahun
  * Kondisi
* Sorting berdasarkan harga (ascending/descending).

---

### 4.10. Notifikasi Lokal

* Muncul ketika user berhasil menambahkan motor ke listing.
* Tidak menggunakan snackbar.

---

## 5. **Struktur Halaman Aplikasi**

1. Splash Screen
2. Login
3. Register
4. Home – List Motor
5. Detail Motor
6. Tambah Motor
7. Harga Motor Baru (API)
8. Halaman Konversi Waktu & Kurs
9. LBS Bengkel
10. Profil & Saran-Kesan

---

## 6. **Database yang Digunakan**

Aplikasi memakai **SQLite** secara lokal.

### 6.1. Tabel User

* id
* username
* password_hash
* salt

### 6.2. Tabel Motor Listing

* id
* nama
* brand
* cc
* tahun
* hargaIDR
* kilometer
* kondisi
* deskripsi
* lokasi
* foto_path_1 … foto_path_5
* instagram_link
* kontak_opsional

### 6.3. Tabel Bengkel

* id
* nama
* latitude
* longitude

(Satu data bengkel saja.)

---

## 7. **API yang Digunakan**

1. **MockAPI – harga motor baru**
   URL: [https://69063273ee3d0d14c13529b5.mockapi.io/:endpoint](https://69063273ee3d0d14c13529b5.mockapi.io/:endpoint)

2. **API Exchange Rate publik** (misalnya):

   * [https://api.frankfurter.app](https://api.frankfurter.app)

Aplikasi hanya melakukan GET request, tidak melakukan update ke server.

---

## 8. **Foto Motor**

* Disimpan dalam storage lokal perangkat.
* Path foto disimpan di SQLite.
* Tidak ada upload ke server.

---

## 9. **Aturan Teknis Tambahan**

* Tidak ada radius pencarian berdasarkan LBS.
* Tidak ada konfirmasi email.
* Tidak ada sistem chat.
* Tidak ada metode pembayaran.
* Tidak ada multi-user role.
* Notifikasi hanya lokal.
* Data motor di SQLite adalah hasil input pengguna, bukan dari API.

---

## 11. **Tech Stack yang Digunakan**

### 11.1. Bahasa & Framework

* **Flutter/Dart** – framework utama untuk pengembangan aplikasi Android.
* **Dart async/future/stream** – untuk pengambilan data API dan proses I/O.

### 11.2. Penyimpanan & Database

* **SQLite (sqflite package)** – penyimpanan data lokal utama.
* **SharedPreferences** – penyimpanan session dan konfigurasi kecil.
* **Device local storage** – penyimpanan file foto motor.

### 11.3. API & Networking

* **MockAPI** – harga motor baru.
* **HTTP package** – untuk fetch data API.
* **Public Exchange Rate API** – kurs mata uang (Frankfurter API atau setara).

### 11.4. LBS (Location Based Service)

* **geolocator** – mendapatkan lokasi user & menghitung jarak.
* **Permission handler** – untuk izin akses lokasi.

### 11.5. Notifikasi

* **flutter_local_notifications** – untuk notifikasi lokal ketika motor berhasil ditambahkan.


### 11.7. UI/UX

* Material Design default Flutter.
* image_picker – memilih foto dari galeri.
* intl – konversi waktu & formatting angka/mata uang.

---

## 12. **Kebutuhan Teknis Tambahan**

Untuk membangun aplikasi ini secara lengkap, developer membutuhkan:

### 12.1. Dependency Wajib

1. http
2. sqflite
3. path_provider
4. shared_preferences
5. flutter_local_notifications
6. geolocator
7. permission_handler
8. image_picker
9. intl

### 12.4. Kebutuhan Security

* Hash password dengan SHA-256 + static salt.
* Tidak menyimpan plaintext password.
* Session menggunakan SharedPreferences.
* Session expired hanya dihapus ketika logout.

---

Dokumen ini menjadi gambaran lengkap fungsi aplikasi tanpa masuk ke kode dan sudah siap diberikan ke AI untuk implementasi teknis.
