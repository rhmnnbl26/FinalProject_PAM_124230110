// lib/pages/detail_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/motor_model.dart';

class DetailPage extends StatelessWidget {
  final MotorModel motor;
  const DetailPage({super.key, required this.motor});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(motor.nama),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: motor.id,
              child: Image.network(
                motor.gambar,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(motor.nama, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(motor.merk, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(formatter.format(motor.hargaIdr),
                      style: const TextStyle(fontSize: 20, color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text(motor.deskripsi, style: const TextStyle(fontSize: 16, height: 1.4)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Motor ditambahkan ke keranjang!")));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Tambah ke Keranjang", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
