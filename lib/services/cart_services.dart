import 'package:hive_flutter/hive_flutter.dart';
import '../models/cart_model.dart';

class CartService {
  static late Box<CartModel> _cartBox;

  // Inisialisasi Hive untuk Cart
  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(1)) {
      // Ensure the CartModel TypeAdapter is generated and available.
      // If you generated the adapter with build_runner, import or register it where appropriate, for example:
      // Hive.registerAdapter(CartModelAdapter());
      //
      // The line above is commented out here to avoid a compile error when the generated
      // CartModelAdapter class is not present; add the registration back once the adapter
      // class exists (usually in the generated file).
    }
    _cartBox = await Hive.openBox<CartModel>('cartBox');
  }

  // Tambah item ke keranjang
  static Future<void> addToCart(CartModel item) async {
    await _cartBox.add(item);
  }

  // Ambil semua item dari keranjang
  static List<CartModel> getCartItems() {
    return _cartBox.values.toList();
  }

  // Hapus item berdasarkan index
  static Future<void> removeItem(int index) async {
    await _cartBox.deleteAt(index);
  }

  // Hapus semua isi keranjang
  static Future<void> clearCart() async {
    await _cartBox.clear();
  }

  // Hitung total harga
  static double getTotalPrice() {
    return _cartBox.values.fold(0.0, (sum, item) => sum + item.price);
  }
}
