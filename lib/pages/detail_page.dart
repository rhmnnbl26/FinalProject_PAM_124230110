import 'package:flutter/material.dart';
import '../services/currency_service.dart';
// ignore: unused_import
import '../models/cart_model.dart'; // ✅ Tambahkan ini
import '../services/cart_services.dart'; // ✅ Tambahkan ini

class DetailPage extends StatefulWidget {
  final String name;
  final String brand;
  final String description;
  final String image;
  final int price;

  const DetailPage({
    super.key,
    required this.name,
    required this.brand,
    required this.description,
    required this.image,
    required this.price,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  String _selectedCurrency = 'IDR';
  Map<String, double> _rates = {'IDR': 1.0, 'USD': 0.000062, 'EUR': 0.000056};

  @override
  void initState() {
    super.initState();
    _fetchRates();
  }

  Future<void> _fetchRates() async {
    final rates = await CurrencyService.getRates();
    setState(() {
      _rates = rates;
    });
  }

  double _convertPrice() {
    return widget.price * (_rates[_selectedCurrency] ?? 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final simbol = _selectedCurrency == 'USD'
        ? '\$'
        : _selectedCurrency == 'EUR'
        ? '€'
        : 'Rp';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        backgroundColor: Colors.green.shade700,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: DropdownButton<String>(
              value: _selectedCurrency,
              dropdownColor: Colors.white,
              items: const [
                DropdownMenuItem(value: 'IDR', child: Text("IDR")),
                DropdownMenuItem(value: 'USD', child: Text("USD")),
                DropdownMenuItem(value: 'EUR', child: Text("EUR")),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCurrency = value!;
                });
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.image,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 80),
            ),
            const SizedBox(height: 16),
            Text(
              widget.brand,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(widget.description),
            const SizedBox(height: 20),

            // ✅ Tombol tambah ke keranjang diperbaiki
            ElevatedButton.icon(
              onPressed: () async {
                final item = CartModel(
                  name: widget.name,
                  brand: widget.brand,
                  price: widget.price,
                  image: widget.image,
                );
                await CartService.addToCart(item);

                if (!mounted) return; // hindari error async context
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Berhasil ditambahkan ke keranjang'),
                  ),
                );
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Tambah ke Keranjang'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 20),
            Text(
              "$simbol ${_convertPrice().toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
