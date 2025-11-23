import 'package:flutter/material.dart';
import '../services/lbs_service.dart';
import '../models/bengkel.dart';
import '../services/database_helper.dart';

class LbsScreen extends StatefulWidget {
  const LbsScreen({super.key});

  @override
  State<LbsScreen> createState() => _LbsScreenState();
}

class _LbsScreenState extends State<LbsScreen> {
  final LbsService _lbsService = LbsService();
  bool _isLoading = false;
  bool _hasPermission = false;
  Bengkel? _bengkel;
  double? _distance;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndLoad();
  }

  Future<void> _checkPermissionAndLoad() async {
    setState(() => _isLoading = true);
    
    try {
      // Check permission
      final hasPermission = await _lbsService.isLocationPermissionGranted();
      
      if (!hasPermission) {
        setState(() {
          _hasPermission = false;
          _isLoading = false;
        });
        return;
      }

      setState(() => _hasPermission = true);
      
      // Load bengkel data
      final bengkel = await DatabaseHelper.instance.getBengkel();
      setState(() => _bengkel = bengkel);
      
      // Calculate distance
      await _calculateDistance();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermission() async {
    final granted = await _lbsService.requestLocationPermission();
    
    if (granted) {
      _checkPermissionAndLoad();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin lokasi diperlukan untuk menghitung jarak'),
          ),
        );
      }
    }
  }

  Future<void> _calculateDistance() async {
    setState(() => _isLoading = true);
    
    try {
      final distance = await _lbsService.calculateDistanceToBengkel();
      setState(() {
        _distance = distance;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error menghitung jarak: $e';
        _isLoading = false;
      });
    }
  }

  String _formatDistance(double? distance) {
    if (distance == null) return 'N/A';
    
    if (distance < 1) {
      return '${(distance * 1000).toStringAsFixed(0)} meter';
    } else {
      return '${distance.toStringAsFixed(2)} km';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lokasi Bengkel'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_hasPermission
              ? _buildPermissionRequired()
              : _errorMessage != null
                  ? _buildError()
                  : _buildContent(),
    );
  }

  Widget _buildPermissionRequired() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'Izin Lokasi Diperlukan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Aplikasi memerlukan izin lokasi untuk menghitung jarak Anda ke bengkel.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _requestPermission,
              icon: const Icon(Icons.location_on),
              label: const Text('Berikan Izin Lokasi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 100,
              color: Colors.red[300],
            ),
            const SizedBox(height: 24),
            Text(
              _errorMessage ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _calculateDistance,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Icon(
                    Icons.build,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _bengkel?.nama ?? 'Bengkel Motor Yogyakarta',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Jarak dari lokasi Anda',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatDistance(_distance),
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Bengkel',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Koordinat',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${_bengkel?.latitude.toStringAsFixed(6)}, ${_bengkel?.longitude.toStringAsFixed(6)}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            color: Colors.amber[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber[700]),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Gunakan bengkel ini untuk mengecek kondisi motor sebelum proses jual.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _calculateDistance,
            icon: const Icon(Icons.refresh),
            label: const Text('Hitung Ulang Jarak'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
