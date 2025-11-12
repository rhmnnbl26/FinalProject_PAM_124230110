import 'package:hive/hive.dart';

part 'cart_model.g.dart';

@HiveType(typeId: 2)
class CartModel extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String brand;

  @HiveField(2)
  final int price;

  @HiveField(3)
  final String image;

  @HiveField(4)
  int quantity;

  CartModel({
    required this.name,
    required this.brand,
    required this.price,
    required this.image,
    this.quantity = 1,
  });
}
