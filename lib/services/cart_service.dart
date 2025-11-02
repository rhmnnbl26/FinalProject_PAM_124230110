import 'package:hive/hive.dart';
import '../models/cart_model.dart';

class CartService {
  static const _boxName = 'cartBox';

  static Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      Hive.registerAdapter(CartModelAdapter());
      await Hive.openBox<CartModel>(_boxName);
    }
  }

  static Box<CartModel> get _box => Hive.box<CartModel>(_boxName);

  static List<CartModel> getItems() => _box.values.toList();

  static void addItem(CartModel item) {
    _box.add(item);
  }

  static void clearCart() {
    _box.clear();
  }
}
