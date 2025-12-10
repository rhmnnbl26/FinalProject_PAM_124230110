import 'package:flutter/material.dart';
import '../models/booking.dart';
import 'package:intl/intl.dart';

class BookingCardWidget extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onTap;

  const BookingCardWidget({super.key, required this.booking, this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
    final formattedDate = dateFormat.format(
      DateTime.parse(booking.bookingDate),
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF252525),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(booking.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(booking.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    booking.queueNumber,
                    style: const TextStyle(
                      color: Color(0xFF2196F3),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.motorcycle,
                    color: Color(0xFF2196F3),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${booking.motorMerk} ${booking.motorTipe}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          booking.motorPlat,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.white.withValues(alpha: 0.1)),
              const SizedBox(height: 16),
              _buildInfoRow(Icons.build, booking.serviceTypeName),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.calendar_today, formattedDate),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.access_time, booking.bookingTimeSlot),
              if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoRow(Icons.note, booking.notes!),
              ],
              const SizedBox(height: 16),
              Divider(color: Colors.white.withValues(alpha: 0.1)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Bayar',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatCurrency(booking.finalPrice),
                        style: const TextStyle(
                          color: Color(0xFF2196F3),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (booking.discountAmount > 0)
                        Text(
                          'Hemat ${_formatCurrency(booking.discountAmount)}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Lihat Detail'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'confirmed':
        return 'DIKONFIRMASI';
      case 'completed':
        return 'SELESAI';
      case 'cancelled':
        return 'DIBATALKAN';
      default:
        return status.toUpperCase();
    }
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}
