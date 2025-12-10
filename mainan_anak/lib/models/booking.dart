class Booking {
  final int? id;
  final int userId;
  final int bengkelId;
  final String motorMerk;
  final String motorTipe;
  final int motorTahun;
  final String motorPlat;
  final String serviceType; // 'ringan', 'sedang', 'besar'
  final String bookingDate; // '2024-12-05'
  final String bookingTimeSlot; // '09:00-10:00'
  final String queueNumber; // 'A003'
  final String? notes;
  final double originalPrice;
  final double discountAmount;
  final double finalPrice;
  final int? voucherId;
  final String? voucherCode;
  final String status; // 'confirmed', 'completed', 'cancelled'
  final String bookingCode; // 'BOOK-20241202-001'
  final String? qrCodeData;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Booking({
    this.id,
    required this.userId,
    required this.bengkelId,
    required this.motorMerk,
    required this.motorTipe,
    required this.motorTahun,
    required this.motorPlat,
    required this.serviceType,
    required this.bookingDate,
    required this.bookingTimeSlot,
    required this.queueNumber,
    this.notes,
    required this.originalPrice,
    this.discountAmount = 0,
    required this.finalPrice,
    this.voucherId,
    this.voucherCode,
    this.status = 'confirmed',
    required this.bookingCode,
    this.qrCodeData,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'bengkel_id': bengkelId,
      'motor_merk': motorMerk,
      'motor_tipe': motorTipe,
      'motor_tahun': motorTahun,
      'motor_plat': motorPlat,
      'service_type': serviceType,
      'booking_date': bookingDate,
      'booking_time_slot': bookingTimeSlot,
      'queue_number': queueNumber,
      'notes': notes,
      'original_price': originalPrice,
      'discount_amount': discountAmount,
      'final_price': finalPrice,
      'voucher_id': voucherId,
      'voucher_code': voucherCode,
      'status': status,
      'booking_code': bookingCode,
      'qr_code_data': qrCodeData,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      userId: map['user_id'],
      bengkelId: map['bengkel_id'],
      motorMerk: map['motor_merk'],
      motorTipe: map['motor_tipe'],
      motorTahun: map['motor_tahun'],
      motorPlat: map['motor_plat'],
      serviceType: map['service_type'],
      bookingDate: map['booking_date'],
      bookingTimeSlot: map['booking_time_slot'],
      queueNumber: map['queue_number'],
      notes: map['notes'],
      originalPrice: map['original_price'],
      discountAmount: map['discount_amount'] ?? 0,
      finalPrice: map['final_price'],
      voucherId: map['voucher_id'],
      voucherCode: map['voucher_code'],
      status: map['status'] ?? 'confirmed',
      bookingCode: map['booking_code'],
      qrCodeData: map['qr_code_data'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  String get serviceTypeName {
    switch (serviceType) {
      case 'ringan':
        return 'Servis Ringan';
      case 'sedang':
        return 'Servis Sedang';
      case 'besar':
        return 'Servis Besar';
      default:
        return serviceType;
    }
  }

  bool get isUpcoming {
    final bookingDateTime = DateTime.parse(bookingDate);
    return bookingDateTime.isAfter(DateTime.now()) && status == 'confirmed';
  }

  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  Booking copyWith({
    int? id,
    int? userId,
    int? bengkelId,
    String? motorMerk,
    String? motorTipe,
    int? motorTahun,
    String? motorPlat,
    String? serviceType,
    String? bookingDate,
    String? bookingTimeSlot,
    String? queueNumber,
    String? notes,
    double? originalPrice,
    double? discountAmount,
    double? finalPrice,
    int? voucherId,
    String? voucherCode,
    String? status,
    String? bookingCode,
    String? qrCodeData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bengkelId: bengkelId ?? this.bengkelId,
      motorMerk: motorMerk ?? this.motorMerk,
      motorTipe: motorTipe ?? this.motorTipe,
      motorTahun: motorTahun ?? this.motorTahun,
      motorPlat: motorPlat ?? this.motorPlat,
      serviceType: serviceType ?? this.serviceType,
      bookingDate: bookingDate ?? this.bookingDate,
      bookingTimeSlot: bookingTimeSlot ?? this.bookingTimeSlot,
      queueNumber: queueNumber ?? this.queueNumber,
      notes: notes ?? this.notes,
      originalPrice: originalPrice ?? this.originalPrice,
      discountAmount: discountAmount ?? this.discountAmount,
      finalPrice: finalPrice ?? this.finalPrice,
      voucherId: voucherId ?? this.voucherId,
      voucherCode: voucherCode ?? this.voucherCode,
      status: status ?? this.status,
      bookingCode: bookingCode ?? this.bookingCode,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
