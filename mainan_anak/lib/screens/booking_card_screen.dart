import 'package:flutter/material.dart';
// ignore: uri_does_not_exist
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';

class BookingCardScreen extends StatelessWidget {
  final Booking booking;

  const BookingCardScreen({super.key, required this.booking});

  Future<void> _cancelBooking(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF252525),
        title: const Text('Batalkan Booking?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan booking ini?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('TIDAK'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('YA, BATALKAN'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await BookingService.instance.cancelBooking(booking.id!);
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking berhasil dibatalkan'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
    final formattedDate = dateFormat.format(DateTime.parse(booking.bookingDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kartu Booking'),
        actions: [
          if (booking.status == 'confirmed')
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () => _cancelBooking(context),
              tooltip: 'Batalkan Booking',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: const Row(
                      children: [
                        Icon(Icons.confirmation_number, color: Colors.white, size: 32),
                        SizedBox(width: 12),
                        Text(
                          'KARTU BOOKING SERVIS',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Bengkel Motor Rumah', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('📍 Jl. Contoh No. 123, Yogyakarta', style: TextStyle(color: Colors.black54)),
                        const Divider(height: 32),
                        Text('🏍️  Motor: ${booking.motorMerk} ${booking.motorTipe}'),
                        const SizedBox(height: 8),
                        Text('📝  Plat: ${booking.motorPlat}'),
                        const SizedBox(height: 8),
                        Text('🔧  Servis: ${booking.serviceTypeName}'),
                        const Divider(height: 32),
                        Text('📅  Tanggal: $formattedDate'),
                        const SizedBox(height: 8),
                        Text('⏰  Waktu: ${booking.bookingTimeSlot} WIB'),
                        const SizedBox(height: 8),
                        Text('🎟️  No. Antrian: ${booking.queueNumber}', 
                          style: const TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold)),
                        const Divider(height: 32),
                        Text('💰  Total Bayar: ${BookingService.instance.formatCurrency(booking.finalPrice)}',
                          style: const TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold)),
                        if (booking.discountAmount > 0)
                          Text('Hemat ${BookingService.instance.formatCurrency(booking.discountAmount)}',
                            style: const TextStyle(color: Colors.green, fontSize: 12)),
                        if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                          const Divider(height: 32),
                          const Text('📌  Catatan:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(booking.notes!, style: const TextStyle(color: Colors.black54)),
                        ],
                        const Divider(height: 32),
                        Center(
                          child: Column(
                            children: [
                              QrImageView(
                                data: booking.qrCodeData ?? booking.bookingCode,
                                size: 200,
                              ),
                              const SizedBox(height: 12),
                              const Text('Scan saat datang ke bengkel',
                                style: TextStyle(color: Colors.black45, fontSize: 12, fontStyle: FontStyle.italic)),
                              const SizedBox(height: 24),
                              const Text('Kode Booking', style: TextStyle(color: Colors.black54, fontSize: 12)),
                              Text(booking.bookingCode,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (booking.status == 'confirmed')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _cancelBooking(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.cancel),
                  label: const Text('BATALKAN BOOKING'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

