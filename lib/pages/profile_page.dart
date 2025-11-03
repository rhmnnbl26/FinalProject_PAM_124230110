import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../utils/location_time_helper.dart';
import 'login_page.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String? _username;
  String _currentLocation = 'Tidak diketahui';
  String _currentTime = '';
  String _selectedZone = 'WIB';

  final LocationTimeHelper _locationHelper = LocationTimeHelper();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchLocationAndTime();
  }

  Future<void> _loadUserData() async {
    final loggedUser = HiveService.getLoggedInUser();
    setState(() {
      _username = loggedUser ?? 'Guest';
    });
  }

  Future<void> _fetchLocationAndTime() async {
    try {
      final position = await _locationHelper.getCurrentPosition();
      final place = await _locationHelper.getPlaceFromPosition(
        position.latitude,
        position.longitude,
      );
      final waktu = _locationHelper.getCurrentTimeByZone(_selectedZone);

      if (mounted) {
        setState(() {
          _currentLocation = place;
          _currentTime = waktu;
        });
      }
    } catch (e) {
      setState(() {
        _currentLocation = 'Gagal mengambil lokasi';
        _currentTime = 'Tidak tersedia';
      });
    }
  }

  Future<void> _onZoneChanged(String? newZone) async {
    if (newZone == null) return;
    setState(() => _selectedZone = newZone);
    final waktu = _locationHelper.getCurrentTimeByZone(_selectedZone);
    if (mounted) {
      setState(() => _currentTime = waktu);
    }
  }

  void _logout(BuildContext context) async {
    HiveService.logoutUser();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        backgroundColor: Colors.green.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Foto Profil
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.green.shade700,
              child: const Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),

            // Username
            Text(
              _username ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Lokasi Saat Ini
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    _currentLocation,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dropdown Zona Waktu
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.green),
                      const SizedBox(width: 10),
                      const Text(
                        'Zona Waktu',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: _selectedZone,
                    items: const [
                      DropdownMenuItem(value: 'WIB', child: Text("WIB")),
                      DropdownMenuItem(value: 'WITA', child: Text("WITA")),
                      DropdownMenuItem(value: 'WIT', child: Text("WIT")),
                      DropdownMenuItem(value: 'London', child: Text("London")),
                    ],
                    onChanged: _onZoneChanged,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Waktu saat ini: $_currentTime',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            // Tombol Logout
            ElevatedButton.icon(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Logout', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
