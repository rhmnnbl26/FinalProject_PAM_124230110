import 'package:flutter/material.dart';
import '../models/voucher.dart';
import 'package:intl/intl.dart';

class VoucherCardWidget extends StatelessWidget {
  final Voucher voucher;
  final VoidCallback? onTap;
  final bool isSelected;

  const VoucherCardWidget({
    super.key,
    required this.voucher,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final daysUntilExpiry = voucher.expiryDate.difference(DateTime.now()).inDays;
    final isExpiringSoon = daysUntilExpiry <= 7 && daysUntilExpiry > 0;
    
    return GestureDetector(
      onTap: voucher.isValid ? onTap : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: voucher.isExpired
              ? const LinearGradient(
                  colors: [Color(0xFF424242), Color(0xFF303030)],
                )
              : LinearGradient(
                  colors: voucher.discountPercent >= 20
                      ? [const Color(0xFF2196F3), const Color(0xFF1565C0)]
                      : [const Color(0xFF1E88E5), const Color(0xFF1565C0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${voucher.discountPercent}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (voucher.isUsed)
                        _buildBadge('TERPAKAI', Colors.white.withValues(alpha: 0.3))
                      else if (voucher.isExpired)
                        _buildBadge('KADALUARSA', Colors.white.withValues(alpha: 0.3))
                      else if (isExpiringSoon)
                        _buildBadge('$daysUntilExpiry HARI LAGI', Colors.orange.withValues(alpha: 0.8)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    voucher.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    voucher.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          Icons.confirmation_number,
                          voucher.code,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.access_time,
                          'Berlaku hingga: ${DateFormat('d MMM yyyy', 'id_ID').format(voucher.expiryDate)}',
                        ),
                        if (voucher.bengkelName != null) ...[
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            Icons.location_on,
                            voucher.bengkelName!,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF2196F3),
                    size: 24,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

