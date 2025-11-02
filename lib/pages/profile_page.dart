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
  String _location = 'Memuat lokasi...';
  String _currentZone = 'WIB';
  String _convertedTime = '';
  final Map<String, int> _zoneOffsets = {
    'WIB': 0,
    'WITA': 1,
    'WIT': 2,
    'London': -7,
  };

  @override
  void initState() {
    super.initState();
    _loadLocation();
    _updateTime();
  }

  Future<void> _loadLocation() async {
    String location = await LocationTimeHelper.getUserLocation();
    setState(() {
      _location = location;
    });
  }

  void _updateTime() {
    int offset = _zoneOffsets[_currentZone] ?? 0;
    setState(() {
      _convertedTime = LocationTimeHelper.getLocalTime(offsetHours: offset);
    });
  }

  @override
  Widget build(BuildContext context) {
    final username = HiveService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.green.shade200,
                child: const Icon(Icons.person, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(username.isNotEmpty ? username : 'Pengguna Tidak Dikenal',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

              const SizedBox(height: 30),
              const Divider(),

              // 📍 Lokasi
              Align(
                alignment: Alignment.centerLeft,
                child: Text("📍 Lokasi: $_location",
                    style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 10),

              // 🕒 Waktu lokal
              Align(
                alignment: Alignment.centerLeft,
                child: Text("🕒 Waktu saat ini ($_currentZone): $_convertedTime",
                    style: const TextStyle(fontSize: 16)),
              ),

              const SizedBox(height: 10),

              // Dropdown konversi waktu
              DropdownButton<String>(
                value: _currentZone,
                items: _zoneOffsets.keys
                    .map((zone) => DropdownMenuItem(
                          value: zone,
                          child: Text(zone),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _currentZone = value!;
                    _updateTime();
                  });
                },
              ),

              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  HiveService.logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  minimumSize: const Size(double.infinity, 45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
