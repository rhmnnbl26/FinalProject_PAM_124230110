# 🚀 Quick Start Guide - Children's Toys App

## Prerequisites
- Flutter SDK installed
- Android Studio or VS Code with Flutter extension
- Android device/emulator or iOS simulator

## Installation Steps

### 1. Install Dependencies
```bash
cd "c:\Users\ASUS\Downloads\pam\Tugas akhir\mainan_anak"
flutter pub get
```

### 2. Run the App
```bash
flutter run
```

## First Time Usage

### 1. Register Account
- Open the app
- Click "Daftar" button
- Enter username (min 3 characters)
- Enter password (min 6 characters)
- Confirm password
- Click "Daftar"
- You'll be auto-logged in

### 2. Add Your First Motor
- Navigate to "Tambah Motor" tab
- Fill in all required fields marked with *:
  - Nama motor
  - Brand/merk
  - Deskripsi
  - CC mesin
  - Tahun
  - Harga (IDR)
  - Kilometer
  - Kondisi (baru/bekas)
  - Lokasi (default: Yogyakarta)
  - Link Instagram
- Add 3-5 photos by clicking "Tambah Foto"
- Optional: Add contact number
- Click "Tambah Motor"
- You'll receive a local notification

### 3. Browse Motors
- View all motors on Home screen
- Use search bar to find specific motors
- Click filter icon to filter by Brand, CC, or Kondisi
- Click sort icon to sort by price
- Tap any motor card to view details

### 4. Check New Motor Prices
- Navigate to "Harga Baru" tab
- View motorcycle prices from API
- Click currency selector to change: IDR → USD → EUR → JPY
- Pull down to refresh data

### 5. Access Profile Features
- Navigate to "Profil" tab
- Click "Konversi Waktu" to see multi-timezone clock
- Click "Lokasi Bengkel" to calculate distance to workshop
  - Allow location permission when prompted
  - View distance in kilometers/meters

## 🔧 Troubleshooting

### Location Permission Issues
If location doesn't work:
1. Go to phone Settings → Apps → mainan_anak
2. Enable Location permission
3. Return to app and try again

### Photo Upload Issues
If photos don't appear:
1. Ensure storage permission is granted
2. Try selecting photos from Gallery
3. Photos are saved in app's internal storage

### API Not Loading
If motor prices don't load:
1. Check internet connection
2. Pull down to refresh
3. API endpoint: `https://69063273ee3d0d14c13529b5.mockapi.io/motor`

### Notifications Not Showing
If notifications don't appear:
1. Go to Settings → Apps → mainan_anak → Notifications
2. Enable all notification permissions
3. Try adding a motor again

## 📱 Testing Checklist

- [ ] Register new account
- [ ] Login with credentials
- [ ] Add motor with photos
- [ ] Receive notification after adding motor
- [ ] View motor in home list
- [ ] Search for motor
- [ ] Filter motors by brand/CC/kondisi
- [ ] Sort motors by price
- [ ] View motor details
- [ ] Click "Beli via Instagram" button
- [ ] View motor prices from API
- [ ] Convert currency (IDR/USD/EUR/JPY)
- [ ] Check timezone conversions
- [ ] Calculate distance to bengkel (requires location permission)
- [ ] View profile and logout
- [ ] Auto-login on next app launch

## 🎯 Key Features to Test

### Authentication
- Password is hashed (not stored as plaintext)
- Session persists after app restart
- Logout clears session

### Motor Listing
- Photos saved locally in app documents
- Search by name/brand
- Filter by multiple criteria
- Sort ascending/descending

### API Integration
- MockAPI for new motorcycle prices
- Frankfurter API for real-time exchange rates
- Automatic currency conversion

### Location Services
- GPS distance calculation
- Permission handling
- Formatted distance display (m/km)

### Time Zones
- Real-time updates (every second)
- 24-hour format
- WIB, WITA, WIT, London

### Local Notifications
- Triggered on motor add
- Rich notification content
- No internet required

## 📊 Sample Data

### Test User
- Username: `testuser`
- Password: `test123`

### Sample Motor Entry
- Nama: Kawasaki Ninja ZX-6R
- Brand: Kawasaki
- CC: 636
- Tahun: 2020
- Harga: 150000000
- Kilometer: 5000
- Kondisi: bekas
- Lokasi: Yogyakarta
- Instagram: https://instagram.com/yourshop
- Kontak: 08123456789

## 💡 Tips

1. **Add at least 3-5 motors** to test search and filter properly
2. **Use different brands** (Honda, Yamaha, Kawasaki, Suzuki, BMW) for filter testing
3. **Vary CC values** (600, 650, 750, 1000) for filter testing
4. **Test both kondisi** (baru and bekas)
5. **Add Instagram links** like: `https://instagram.com/p/xxxxx`
6. **Take new photos** with camera or select from gallery

## 🐛 Known Limitations

1. No server upload - all photos stored locally
2. No payment gateway - transactions via Instagram
3. No chat feature - contact via Instagram or phone
4. Location fixed to Yogyakarta area
5. Single bengkel location (no multiple workshops)
6. No radius-based search for motors
7. Session never expires (manual logout only)

## 📞 Support

For issues or questions, refer to:
- `APP_README.md` for detailed documentation
- `plan.md` for original requirements
- Check console logs for debugging

---

**Ready to test!** 🎉

Start by registering, add some motors, and explore all the features!
