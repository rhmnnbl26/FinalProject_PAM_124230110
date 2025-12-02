import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bengkel.dart';
import '../models/voucher.dart';
import '../services/auth_service.dart';
import '../services/local_notification_service.dart';
import '../services/shake_service.dart';
import '../services/voucher_service.dart';
import '../widgets/shake_detector_widget.dart';

class ShakeVoucherScreen extends StatefulWidget {
  final Bengkel bengkel;
  final double distance;

  const ShakeVoucherScreen({
    super.key,
    required this.bengkel,
    required this.distance,
  });

  @override
  State<ShakeVoucherScreen> createState() => _ShakeVoucherScreenState();
}

class _ShakeVoucherScreenState extends State<ShakeVoucherScreen> {
  final VoucherService _voucherService = VoucherService();
  final ShakeService _shakeService = ShakeService.instance;
  bool _hasShaken = false;
  bool _canShake = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkShakeStatus();
  }

  Future<void> _checkShakeStatus() async {
    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      final userId = await authService.getCurrentUserId() ?? 1;
      _hasShaken = await _shakeService.hasUserShaken(userId);
      _canShake = !_hasShaken && widget.distance <= 5.0;

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _handleShake(bool detected) async {
    if (!detected || !_canShake) return;

    try {
      // Get current user ID first
      final authService = AuthService();
      final userId = await authService.getCurrentUserId() ?? 1;
      
      // Generate voucher with userId
      final voucher = _voucherService.generateVoucher(
        bengkelName: widget.bengkel.nama,
        bengkelDistance: widget.distance,
        userId: userId,
      );

      // Save voucher
      final savedVoucher = await _voucherService.saveVoucher(voucher);

      // Mark user as shaken
      await _shakeService.markUserShaken(userId);

      // Show notification
      await LocalNotificationService.instance.showVoucherNotification(
        title: 'Voucher Baru!',
        voucherTitle: savedVoucher.title,
        discountPercent: savedVoucher.discountPercent,
        expiryDate: DateFormat('d MMM yyyy', 'id_ID').format(savedVoucher.expiryDate),
      );

      // Show success dialog
      if (mounted) {
        await _showVoucherSuccessDialog(savedVoucher);
        // Return to previous screen with success
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _showVoucherSuccessDialog(Voucher voucher) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF252525),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Color(0xFF2196F3), size: 32),
            SizedBox(width: 12),
            Text('SELAMAT!', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Anda mendapatkan:',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    voucher.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Diskon ${voucher.discountPercent}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Berlaku hingga: ${DateFormat('d MMM yyyy', 'id_ID').format(voucher.expiryDate)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFF2196F3))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A1A), Color(0xFF2A0A0A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Dapatkan Voucher',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2196F3),
                        ),
                      )
                    : _hasShaken
                        ? _buildAlreadyShaken()
                        : _canShake
                            ? _buildShakeDetector()
                            : _buildTooFar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShakeDetector() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Bengkel Info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF252525),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2196F3).withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.store,
                  size: 64,
                  color: Color(0xFF2196F3),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.bengkel.nama,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF2196F3), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.distance.toStringAsFixed(2)} km dari Anda',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Instructions
          const Text(
            'Kocok perangkat Anda untuk\nmendapatkan voucher diskon!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Shake Detector Widget
          ShakeDetectorWidget(
            onShakeDetected: _handleShake,
            isEnabled: true,
          ),
          const SizedBox(height: 24),

          // Hint
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2196F3).withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF2196F3), size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Voucher hanya dapat diklaim satu kali',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlreadyShaken() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF252525),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.orange.withValues(alpha: 0.5), width: 2),
              ),
              child: const Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Voucher Sudah Diklaim',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Anda sudah mendapatkan voucher dari bengkel ini.\nCek tab Voucher untuk melihat voucher Anda.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTooFar() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF252525),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red.withValues(alpha: 0.5), width: 2),
              ),
              child: const Icon(
                Icons.location_off,
                size: 80,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Terlalu Jauh',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Anda berada ${widget.distance.toStringAsFixed(2)} km dari bengkel.\nVoucher hanya dapat diklaim dalam radius 5 km.',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

