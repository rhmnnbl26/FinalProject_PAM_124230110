import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/hive_service.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final HiveService hiveService = HiveService();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController teleponController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  void register() {
    if (!_formKey.currentState!.validate()) return;

    final username = usernameController.text.trim();

    if (hiveService.checkUserExists(username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username sudah digunakan')),
      );
      return;
    }

    final user = UserModel(
      username: username,
      password: hashPassword(passwordController.text.trim()),
      namaLengkap: namaController.text.trim(),
      alamat: alamatController.text.trim(),
      noTelepon: teleponController.text.trim(),
      email: emailController.text.trim(),
    );

    hiveService.registerUser(user);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registrasi berhasil! Silakan login.')),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) =>
                    value!.isEmpty ? 'Username wajib diisi' : null,
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Password wajib diisi' : null,
              ),
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
              ),
              TextFormField(
                controller: alamatController,
                decoration: const InputDecoration(labelText: 'Alamat'),
              ),
              TextFormField(
                controller: teleponController,
                decoration: const InputDecoration(labelText: 'Nomor Telepon'),
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email (Opsional)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: register,
                child: const Text('Daftar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
