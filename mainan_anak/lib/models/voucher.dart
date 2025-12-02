class Voucher {
  final int? id;
  final String code;
  final String title;
  final String description;
  final int discountPercent;
  final String type; // 'service', 'discount'
  final DateTime dateObtained;
  final DateTime expiryDate;
  final DateTime? dateUsed;
  final bool isUsed;
  final String? bengkelName;
  final double? bengkelDistance;
  final int? bookingId;
  final int? userId; // User who owns this voucher

  Voucher({
    this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.discountPercent,
    required this.type,
    required this.dateObtained,
    required this.expiryDate,
    this.dateUsed,
    this.isUsed = false,
    this.bengkelName,
    this.bengkelDistance,
    this.bookingId,
    this.userId,
  });

  bool get isExpired => DateTime.now().isAfter(expiryDate);
  bool get isValid => !isUsed && !isExpired;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'description': description,
      'discountPercent': discountPercent,
      'type': type,
      'dateObtained': dateObtained.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'dateUsed': dateUsed?.toIso8601String(),
      'isUsed': isUsed ? 1 : 0,
      'bengkelName': bengkelName,
      'bengkelDistance': bengkelDistance,
      'booking_id': bookingId, // Use snake_case for database
      'user_id': userId, // User who owns this voucher
    };
  }

  factory Voucher.fromMap(Map<String, dynamic> map) {
    return Voucher(
      id: map['id'],
      code: map['code'],
      title: map['title'],
      description: map['description'],
      discountPercent: map['discountPercent'],
      type: map['type'],
      dateObtained: DateTime.parse(map['dateObtained']),
      expiryDate: DateTime.parse(map['expiryDate']),
      dateUsed: map['dateUsed'] != null ? DateTime.parse(map['dateUsed']) : null,
      isUsed: map['isUsed'] == 1,
      bengkelName: map['bengkelName'],
      bengkelDistance: map['bengkelDistance'],
      bookingId: map['booking_id'], // Read from snake_case database column
      userId: map['user_id'], // Read userId
    );
  }

  Voucher copyWith({
    int? id,
    String? code,
    String? title,
    String? description,
    int? discountPercent,
    String? type,
    DateTime? dateObtained,
    DateTime? expiryDate,
    DateTime? dateUsed,
    bool? isUsed,
    String? bengkelName,
    double? bengkelDistance,
    int? bookingId,
    int? userId,
  }) {
    return Voucher(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      discountPercent: discountPercent ?? this.discountPercent,
      type: type ?? this.type,
      dateObtained: dateObtained ?? this.dateObtained,
      expiryDate: expiryDate ?? this.expiryDate,
      dateUsed: dateUsed ?? this.dateUsed,
      isUsed: isUsed ?? this.isUsed,
      bengkelName: bengkelName ?? this.bengkelName,
      bengkelDistance: bengkelDistance ?? this.bengkelDistance,
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
    );
  }
}
