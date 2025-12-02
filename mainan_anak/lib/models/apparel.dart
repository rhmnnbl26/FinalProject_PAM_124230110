class Apparel {
  final String id;
  final String name;
  final String brand;
  final List<String> size;
  final double price;
  final List<String> imageUrl;
  final String category;
  final String gender;
  final int stock;
  final String description;
  final String linkUrl;

  Apparel({
    required this.id,
    required this.name,
    required this.brand,
    required this.size,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.gender,
    required this.stock,
    required this.description,
    required this.linkUrl,
  });

  factory Apparel.fromJson(Map<String, dynamic> json) {
    return Apparel(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      size: (json['size'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: (json['imageUrl'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      category: json['category'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
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
      'size': size,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'gender': gender,
      'stock': stock,
      'description': description,
      'linkUrl': linkUrl,
    };
  }
}
