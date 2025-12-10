import '../models/booking.dart';
import '../models/booking_slot.dart';
import '../services/database_helper.dart';
import '../services/local_notification_service.dart';
import 'package:intl/intl.dart';

class BookingService {
  static final BookingService instance = BookingService._init();

  BookingService._init();

  // Service prices for big motorcycles (≥1000cc)
  static const Map<String, double> servicePrices = {
    'ringan': 500000, // Rp 500.000
    'sedang': 1000000, // Rp 1.000.000
    'besar': 2000000, // Rp 2.000.000
  };

  /// Get service price by type
  double getServicePrice(String serviceType) {
    return servicePrices[serviceType] ?? 0;
  }

  /// Create a new booking
  Future<Booking> createBooking({
    required int userId,
    required int bengkelId,
    required String motorMerk,
    required String motorTipe,
    required int motorTahun,
    required String motorPlat,
    required String serviceType,
    required String bookingDate,
    required String bookingTimeSlot,
    String? notes,
    int? voucherId,
    String? voucherCode,
    int? discountPercent,
  }) async {
    final db = DatabaseHelper.instance;

    // Generate booking code and queue number
    final bookingCode = await db.generateBookingCode();
    final queueNumber = await db.generateQueueNumber(bookingDate);

    // Calculate prices
    final originalPrice = getServicePrice(serviceType);
    final discountAmount = discountPercent != null
        ? (originalPrice * discountPercent / 100)
        : 0.0;
    final finalPrice = originalPrice - discountAmount;

    // Generate QR code data
    final qrCodeData =
        '$bookingCode|$queueNumber|$bookingDate|$bookingTimeSlot';

    // Create booking map
    final bookingMap = {
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
      'status': 'confirmed',
      'booking_code': bookingCode,
      'qr_code_data': qrCodeData,
      'created_at': DateTime.now().toIso8601String(),
    };

    // Insert booking
    final bookingId = await db.insertBooking(bookingMap);

    // Book the slot
    await db.bookSlot(bengkelId, bookingDate, bookingTimeSlot);

    // Create booking object
    final booking = Booking.fromMap({...bookingMap, 'id': bookingId});

    // Send notification
    await _sendBookingNotification(booking);

    return booking;
  }

  /// Get all bookings for a user
  Future<List<Booking>> getUserBookings(int userId) async {
    final db = DatabaseHelper.instance;
    final bookingMaps = await db.getAllBookings(userId);
    return bookingMaps.map((map) => Booking.fromMap(map)).toList();
  }

  /// Get booking by ID
  Future<Booking?> getBookingById(int bookingId) async {
    final db = DatabaseHelper.instance;
    final bookingMap = await db.getBookingById(bookingId);
    if (bookingMap == null) return null;
    return Booking.fromMap(bookingMap);
  }

  /// Cancel a booking
  Future<void> cancelBooking(int bookingId) async {
    final db = DatabaseHelper.instance;
    final booking = await getBookingById(bookingId);

    if (booking != null) {
      // Update booking status
      await db.updateBookingStatus(bookingId, 'cancelled');

      // Release the slot
      await db.releaseSlot(
        booking.bengkelId,
        booking.bookingDate,
        booking.bookingTimeSlot,
      );
    }
  }

  /// Get available slots for a specific date
  Future<List<BookingSlot>> getAvailableSlots(
    int bengkelId,
    String date,
  ) async {
    final db = DatabaseHelper.instance;
    final slotMaps = await db.getAvailableSlots(bengkelId, date);
    return slotMaps.map((map) => BookingSlot.fromMap(map)).toList();
  }

  /// Send booking notification
  Future<void> _sendBookingNotification(Booking booking) async {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
    final formattedDate = dateFormat.format(
      DateTime.parse(booking.bookingDate),
    );

    await LocalNotificationService.instance.showBookingNotification(
      motorName: '${booking.motorMerk} ${booking.motorTipe}',
      serviceType: booking.serviceTypeName,
      bookingDate: formattedDate,
      timeSlot: booking.bookingTimeSlot,
      queueNumber: booking.queueNumber,
    );
  }

  /// Format currency to IDR
  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}
