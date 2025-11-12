import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../services/auth_service.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final HiveService hiveService = HiveService();

  void login() {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi semua field terlebih dahulu')),
      );
      return;
    }

    final user = hiveService.getUser(username);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username tidak ditemukan')),
      );
      return;
    }

    final hashedInput = hashPassword(password);
    if (hashedInput == user.password) {
      saveLoginSession(username);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login berhasil!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Berhasil login (HomePage nanti di sini)')),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password salah')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: login,
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()));
              },
              child: const Text('Belum punya akun? Daftar'),
            ),
          ],
        ),
      ),
    );
  }
}
