// lib/widgets/motor_card.dart
import 'package:flutter/material.dart';
import '../models/motor_model.dart';
import 'package:intl/intl.dart';
import '../pages/detail_page.dart'; // pastikan path benar

class MotorCard extends StatelessWidget {
  final MotorModel motor;
  const MotorCard({super.key, required this.motor});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.network(
            motor.gambar,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
          ),
        ),
        title: Text(
          motor.nama,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("${motor.merk} • ${formatCurrency.format(motor.hargaIdr)}"),
        trailing: const Icon(Icons.favorite_border, color: Colors.purpleAccent),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailPage(motor: motor)),
          );
        },
      ),
    );
  }
}
