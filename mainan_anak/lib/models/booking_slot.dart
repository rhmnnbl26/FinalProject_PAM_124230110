class BookingSlot {
  final int? id;
  final int bengkelId;
  final String bookingDate;
  final String timeSlot;
  final bool isAvailable;
  final int maxCapacity;
  final int currentBookings;

  BookingSlot({
    this.id,
    required this.bengkelId,
    required this.bookingDate,
    required this.timeSlot,
    this.isAvailable = true,
    this.maxCapacity = 1,
    this.currentBookings = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bengkel_id': bengkelId,
      'booking_date': bookingDate,
      'time_slot': timeSlot,
      'is_available': isAvailable ? 1 : 0,
      'max_capacity': maxCapacity,
      'current_bookings': currentBookings,
    };
  }

  factory BookingSlot.fromMap(Map<String, dynamic> map) {
    return BookingSlot(
      id: map['id'],
      bengkelId: map['bengkel_id'],
      bookingDate: map['booking_date'],
      timeSlot: map['time_slot'],
      isAvailable: map['is_available'] == 1,
      maxCapacity: map['max_capacity'] ?? 1,
      currentBookings: map['current_bookings'] ?? 0,
    );
  }

  bool get isFull => currentBookings >= maxCapacity;

  String get displayTime {
    final parts = timeSlot.split('-');
    if (parts.length == 2) {
      return '${parts[0]} - ${parts[1]}';
    }
    return timeSlot;
  }

  BookingSlot copyWith({
    int? id,
    int? bengkelId,
    String? bookingDate,
    String? timeSlot,
    bool? isAvailable,
    int? maxCapacity,
    int? currentBookings,
  }) {
    return BookingSlot(
      id: id ?? this.id,
      bengkelId: bengkelId ?? this.bengkelId,
      bookingDate: bookingDate ?? this.bookingDate,
      timeSlot: timeSlot ?? this.timeSlot,
      isAvailable: isAvailable ?? this.isAvailable,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      currentBookings: currentBookings ?? this.currentBookings,
    );
  }
}
