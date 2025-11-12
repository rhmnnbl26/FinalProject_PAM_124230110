import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../services/cart_services.dart';

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
    _loadCartItems();
  }

  void _loadCartItems() {
    setState(() {
      _items = CartService.getCartItems();
    });
  }

  void _removeItem(int index) async {
    await CartService.removeItem(index);
    _loadCartItems();
  }

  void _clearCart() async {
    await CartService.clearCart();
    _loadCartItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Saya'),
        backgroundColor: Colors.green.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _clearCart,
          ),
        ],
      ),
      body: _items.isEmpty
          ? const Center(child: Text('Keranjang kosong'))
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: Image.network(
                      item.image,
                      width: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image),
                    ),
                    title: Text(item.name),
                    subtitle: Text("${item.brand} - Rp ${item.price}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => _removeItem(index),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.green.shade100,
        child: Text(
          "Total: Rp ${CartService.getTotalPrice().toStringAsFixed(0)}",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.right,
        ),
      ),
    );
  }
}
