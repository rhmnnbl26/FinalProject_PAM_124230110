import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/bengkel.dart';
import '../models/booking.dart';
import '../models/voucher.dart';
import '../services/auth_service.dart';
import '../services/booking_service.dart';
import '../services/database_helper.dart';
import '../services/lbs_service.dart';
import '../services/shake_service.dart';
import '../services/voucher_service.dart';
import '../widgets/booking_card_widget.dart';
import '../widgets/voucher_card_widget.dart';
import 'booking_card_screen.dart';
import 'booking_form_screen.dart';
import 'shake_voucher_screen.dart';

class BengkelVoucherScreen extends StatefulWidget {
  const BengkelVoucherScreen({super.key});

  @override
  State<BengkelVoucherScreen> createState() => _BengkelVoucherScreenState();
}

class _BengkelVoucherScreenState extends State<BengkelVoucherScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LbsService _lbsService = LbsService();
  final VoucherService _voucherService = VoucherService();
  final ShakeService _shakeService = ShakeService.instance;
  final BookingService _bookingService = BookingService.instance;

  GoogleMapController? _mapController;
  Bengkel? _bengkel;
  double? _distance;
  LatLng? _currentPositionLatLng;
  final Set<Marker> _markers = {};
  bool _isLoading = true;
  bool _hasShaken = false;
  bool _canShake = false;
  List<Voucher> _vouchers = [];
  List<Booking> _bookings = [];

  static const LatLng _defaultBengkelLocation = LatLng(-7.7482380, 110.4084390);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Get current user ID
      final authService = AuthService();
      final userId = await authService.getCurrentUserId() ?? 1;
      
      // Get bengkel
      _bengkel = await DatabaseHelper.instance.getBengkel();

      // Calculate distance
      if (_bengkel != null) {
        _distance = await _lbsService.calculateDistanceToBengkel();
        final position = await _lbsService.getCurrentPosition();
        if (position != null) {
          _currentPositionLatLng = LatLng(position.latitude, position.longitude);
        }
      }

      // Check shake status
      _hasShaken = await _shakeService.hasUserShaken(userId);
      _canShake = !_hasShaken && (_distance != null && _distance! <= 5.0);

      // Load vouchers for current user only
      _vouchers = await _voucherService.getUserVouchers(userId: userId);

      // Load bookings
      _bookings = await _bookingService.getUserBookings(userId);

      // Setup map markers
      _setupMarkers();

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

  void _setupMarkers() {
    _markers.clear();

    if (_bengkel != null) {
      _markers.add(Marker(
        markerId: const MarkerId('bengkel'),
        position: LatLng(_bengkel!.latitude, _bengkel!.longitude),
        infoWindow: InfoWindow(title: _bengkel!.nama),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    }

    if (_currentPositionLatLng != null) {
      _markers.add(Marker(
        markerId: const MarkerId('user'),
        position: _currentPositionLatLng!,
        infoWindow: const InfoWindow(title: 'Lokasi Anda'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
    }
  }

  Future<void> _handleShake(bool detected) async {
    // Navigate to shake voucher screen
    if (_bengkel == null || _distance == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ShakeVoucherScreen(
          bengkel: _bengkel!,
          distance: _distance!,
        ),
      ),
    );

    // Reload data if voucher was claimed
    if (result == true && mounted) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Motor Care'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF2196F3),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.location_on), text: 'Bengkel'),
            Tab(icon: Icon(Icons.card_giftcard), text: 'Voucher'),
            Tab(icon: Icon(Icons.history), text: 'Riwayat'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2196F3)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBengkelTab(),
                _buildVoucherTab(),
                _buildHistoryTab(),
              ],
            ),
    );
  }

  Widget _buildBengkelTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map
          Container(
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            clipBehavior: Clip.antiAlias,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _bengkel != null
                    ? LatLng(_bengkel!.latitude, _bengkel!.longitude)
                    : _defaultBengkelLocation,
                zoom: 14,
              ),
              markers: _markers,
              onMapCreated: (controller) => _mapController = controller,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
          const SizedBox(height: 20),

          // Bengkel Info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF252525),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _bengkel?.nama ?? 'Bengkel Motor',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF2196F3), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _distance != null
                          ? '${_distance!.toStringAsFixed(2)} km dari lokasi Anda'
                          : 'Jarak tidak tersedia',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, color: Color(0xFF2196F3), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Senin-Sabtu, 08:00-17:00',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Shake Button or Info - Updated Design
          if (_hasShaken)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.shade800,
                    Colors.grey.shade900,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle, color: Colors.white70, size: 32),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Promo Telah Digunakan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Kembali lagi besok untuk promo menarik!',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else if (!_canShake)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.shade700.withValues(alpha: 0.3),
                    Colors.orange.shade900.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.warning_amber, color: Colors.orange, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Promo Belum Tersedia',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _distance != null && _distance! > 5.0
                              ? 'Datang ke bengkel kami (max 5km) untuk dapatkan promo!'
                              : 'Aktifkan lokasi Anda untuk mendapatkan promo',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2196F3).withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _handleShake(true),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.card_giftcard,
                            size: 56,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          '🎉 Dapatkan Promo dan Voucher Menarik!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Kocok HP Anda untuk kesempatan memenangkan diskon hingga 50%!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.vibration, color: Color(0xFF2196F3)),
                              SizedBox(width: 8),
                              Text(
                                'Kocok Sekarang!',
                                style: TextStyle(
                                  color: Color(0xFF2196F3),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),

          // Booking Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingFormScreen(bengkel: _bengkel!),
                  ),
                );
                if (result == true) {
                  _loadData();
                  _tabController.animateTo(2); // Pindah ke tab Riwayat
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.calendar_today),
              label: const Text(
                'BOOKING SERVIS SEKARANG',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherTab() {
    final validVouchers = _vouchers.where((v) => v.isValid).toList();

    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFF2196F3),
      child: validVouchers.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.card_giftcard, size: 64, color: Colors.white24),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada voucher',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Kocok HP di tab Bengkel untuk mendapatkan voucher!',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: validVouchers.length,
              itemBuilder: (context, index) {
                return VoucherCardWidget(voucher: validVouchers[index]);
              },
            ),
    );
  }

  Widget _buildHistoryTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFF2196F3),
      child: _bookings.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.white24),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat booking',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _bookings.length,
              itemBuilder: (context, index) {
                return BookingCardWidget(
                  booking: _bookings[index],
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BookingCardScreen(booking: _bookings[index]),
                      ),
                    );
                    _loadData();
                  },
                );
              },
            ),
    );
  }
}

