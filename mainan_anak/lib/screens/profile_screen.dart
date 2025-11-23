import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'waktu_screen.dart';
import 'lbs_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final username = await _authService.getCurrentUsername();
    setState(() {
      _username = username ?? 'User';
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),
            CircleAvatar(
              radius: 60,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(
                Icons.person,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _username,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            
            // Menu items
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Konversi Waktu'),
              subtitle: const Text('WIB, WITA, WIT, London'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WaktuScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Lokasi Bengkel'),
              subtitle: const Text('Cek jarak ke bengkel terdekat'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LbsScreen()),
                );
              },
            ),
            const Divider(),
            
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.school, color: Theme.of(context).primaryColor),
                          const SizedBox(width: 8),
                          const Text(
                            'Saran & Kesan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Mata Kuliah: Pemrograman Aplikasi Mobile',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Kesan:\n'
                        'Mata kuliah PAM sangat menarik dan memberikan pengalaman '
                        'praktis dalam pengembangan aplikasi mobile menggunakan Flutter. '
                        'Materi yang diajarkan sangat relevan dengan kebutuhan industri saat ini.',
                        style: TextStyle(fontSize: 14, height: 1.5),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Saran:\n'
                        'Lebih banyak studi kasus dan project-based learning akan '
                        'sangat membantu dalam memahami konsep-konsep yang lebih kompleks. '
                        'Penambahan materi tentang state management dan testing juga akan sangat bermanfaat.',
                        style: TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
