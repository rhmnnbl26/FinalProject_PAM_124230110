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
  String? username;
  String? location;
  String? currentTime;

  final LocationTimeHelper _helper = LocationTimeHelper();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // ✅ Ambil username dari session box
    username = HiveService.getLoggedInUser() ?? 'User';

    // ✅ Ambil lokasi & waktu
    final position = await _helper.getCurrentLocation();
    final place = await _helper.getPlaceFromPosition(position);
    final time = _helper.getCurrentTimeByZone('WIB');

    if (!mounted) return;
    setState(() {
      location = place;
      currentTime = time;
    });
  }

  void _logout() {
    HiveService.logoutUser();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/profile.png'),
            ),
            const SizedBox(height: 20),
            Text(
              username ?? 'User',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(location ?? 'Mengambil lokasi...'),
            const SizedBox(height: 10),
            Text(currentTime ?? 'Memuat waktu...'),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                minimumSize: const Size(double.infinity, 45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
