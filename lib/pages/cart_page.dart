import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../services/cart_service.dart';
import '../utils/notification_helper.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartModel> _items = [];

  @override
  void initState() {
    super.initState();
    _items = CartService.getItems();
  }

  void _checkout() {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang kosong!')),
      );
      return;
    }

    CartService.clearCart();
    NotificationHelper.show(
      'Pembelian Berhasil!',
      'Motor telah dibeli, terima kasih 🎉',
    );

    setState(() => _items = []);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Checkout berhasil!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Saya'),
        backgroundColor: Colors.green.shade700,
      ),
      body: _items.isEmpty
          ? const Center(child: Text('Keranjang kosong.'))
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return ListTile(
                  leading: Image.network(item.image, width: 60, fit: BoxFit.cover),
                  title: Text(item.name),
                  subtitle: Text(item.brand),
                  trailing: Text('Rp ${item.price}'),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _checkout,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('Checkout'),
        ),
      ),
    );
  }
}
