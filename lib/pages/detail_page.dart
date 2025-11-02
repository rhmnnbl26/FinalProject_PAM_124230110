import 'package:flutter/material.dart';
import '../services/currency_service.dart';
import '../models/cart_model.dart';
import '../services/cart_service.dart';

class DetailPage extends StatefulWidget {
  final String name;
  final int price;
  final String brand;
  final String image;
  final String description;

  const DetailPage({
    super.key,
    required this.name,
    required this.price,
    required this.brand,
    required this.image,
    required this.description,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  String _selectedCurrency = 'IDR';
  Map<String, double> _rates = {'IDR': 1.0, 'USD': 0.000062, 'EUR': 0.000056};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchRates();
  }

  Future<void> _fetchRates() async {
    final result = await CurrencyService.getRates();
    setState(() {
      _rates = result;
      _loading = false;
    });
  }

  double _convertPrice() {
    return widget.price * (_rates[_selectedCurrency] ?? 1.0);
  }

  void _addToCart() {
    final item = CartModel(
      name: widget.name,
      price: widget.price,
      brand: widget.brand,
      image: widget.image,
    );

    CartService.addItem(item);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Motor ditambahkan ke keranjang!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final convertedPrice = _convertPrice();
    final currencySymbol = {
      'IDR': 'Rp ',
      'USD': '\$ ',
      'EUR': '€ ',
    }[_selectedCurrency]!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        backgroundColor: Colors.green.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.network(
                      widget.image,
                      height: 220,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 100),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.brand,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        'Harga: ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      DropdownButton<String>(
                        value: _selectedCurrency,
                        items: const [
                          DropdownMenuItem(value: 'IDR', child: Text('IDR')),
                          DropdownMenuItem(value: 'USD', child: Text('USD')),
                          DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                        ],
                        onChanged: (val) {
                          setState(() => _selectedCurrency = val!);
                        },
                      ),
                    ],
                  ),
                  Text(
                    '$currencySymbol${convertedPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 🛒 Tombol Tambah ke Keranjang
                  ElevatedButton.icon(
                    onPressed: _addToCart,
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Tambah ke Keranjang'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      minimumSize: const Size(double.infinity, 50),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Spesifikasi:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.description,
                    textAlign: TextAlign.justify,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
    );
  }
}
