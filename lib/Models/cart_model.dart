import 'package:hive/hive.dart';

part 'cart_model.g.dart'; // <-- ini wajib ada di baris atas

@HiveType(typeId: 1)
class CartModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int price;

  @HiveField(2)
  String brand;

  @HiveField(3)
  String image;

  CartModel({
    required this.name,
    required this.price,
    required this.brand,
    required this.image,
  });
}
