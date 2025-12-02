class Aksesoris {
  final String id;
  final String name;
  final String brand;
  final double price;
  final List<String> imageUrl;
  final String category;
  final List<String> compatibility;
  final int stock;
  final String description;
  final String linkUrl;

  Aksesoris({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.compatibility,
    required this.stock,
    required this.description,
    required this.linkUrl,
  });

  factory Aksesoris.fromJson(Map<String, dynamic> json) {
    return Aksesoris(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: (json['imageUrl'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      category: json['category'] as String? ?? '',
      compatibility: (json['compatibility'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      description: json['description'] as String? ?? '',
      linkUrl: json['linkUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'compatibility': compatibility,
      'stock': stock,
      'description': description,
      'linkUrl': linkUrl,
    };
  }
}
