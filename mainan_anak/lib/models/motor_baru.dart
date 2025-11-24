class MotorBaru {
  final String id;
  final String model;
  final String brand;
  final int cc;
  final int year;
  final double priceUsd;
  final String type;
  final String description;
  final List<String> images;

  MotorBaru({
    required this.id,
    required this.model,
    required this.brand,
    required this.cc,
    required this.year,
    required this.priceUsd,
    required this.type,
    required this.description,
    required this.images,
  });

  factory MotorBaru.fromJson(Map<String, dynamic> json) {
    // Handle both 'image' and 'im ge' typo in API
    List<String> imageList = [];
    if (json['image'] != null) {
      imageList = (json['image'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    } else if (json['im ge'] != null) {
      imageList = (json['im ge'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    }
    
    return MotorBaru(
      id: json['id'].toString(),
      model: json['model'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      cc: (json['CC'] as num?)?.toInt() ?? 0,
      year: (json['year'] as num?)?.toInt() ?? 0,
      priceUsd: (json['price'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] as String? ?? '',
      description: json['description'] as String? ?? '',
      images: imageList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'model': model,
      'brand': brand,
      'CC': cc,
      'year': year,
      'price': priceUsd,
      'type': type,
      'description': description,
      'image': images,
    };
  }
}
