import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  GoogleMapController? _mapController;
  bool _isLoading = false;
  bool _hasPermission = false;
  Bengkel? _bengkel;
  double? _distance;
  String? _errorMessage;
  LatLng? _currentPosition;
  
  // Koordinat default: Bengkel Motor Rumah
  static const LatLng _defaultBengkelLocation = LatLng(-7.7482380, 110.4084390);
  
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _checkPermissionAndLoad();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _mapController = null;
    super.dispose();
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
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final position = await _lbsService.getCurrentPosition();
      final distance = await _lbsService.calculateDistanceToBengkel();
      
      if (!mounted) return;
      setState(() {
        _distance = distance;
        _isLoading = false;
        _errorMessage = null;
        
        if (position != null) {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _updateMarkers();
          
          // Move camera to show both markers - check if controller is still valid
          if (mounted && _mapController != null && _bengkel != null) {
            try {
              _mapController!.animateCamera(
                CameraUpdate.newLatLngBounds(
                  LatLngBounds(
                    southwest: LatLng(
                      _currentPosition!.latitude < _bengkel!.latitude 
                          ? _currentPosition!.latitude 
                          : _bengkel!.latitude,
                      _currentPosition!.longitude < _bengkel!.longitude 
                          ? _currentPosition!.longitude 
                          : _bengkel!.longitude,
                    ),
                    northeast: LatLng(
                      _currentPosition!.latitude > _bengkel!.latitude 
                          ? _currentPosition!.latitude 
                          : _bengkel!.latitude,
                      _currentPosition!.longitude > _bengkel!.longitude 
                          ? _currentPosition!.longitude 
                          : _bengkel!.longitude,
                    ),
                  ),
                  100, // padding
                ),
              );
            } catch (controllerError) {
              // Ignore controller errors if widget is disposing
              print('Map controller error: $controllerError');
            }
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error menghitung jarak: $e';
        _isLoading = false;
      });
    }
  }

  void _updateMarkers() {
    _markers.clear();
    
    // Marker bengkel
    if (_bengkel != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('bengkel'),
          position: LatLng(_bengkel!.latitude, _bengkel!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: _bengkel!.nama,
            snippet: 'Bengkel Motor',
          ),
        ),
      );
    }
    
    // Marker user location
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('user'),
          position: _currentPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'Lokasi Anda',
            snippet: 'Posisi saat ini',
          ),
        ),
      );
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
              color: Colors.orange[300],
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
          // Map View
          Card(
            elevation: 4,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SizedBox(
              height: 300,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _bengkel != null 
                      ? LatLng(_bengkel!.latitude, _bengkel!.longitude)
                      : _defaultBengkelLocation,
                  zoom: 13,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                mapType: MapType.normal,
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                  _updateMarkers();
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          
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
                    size: 60,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _bengkel?.nama ?? 'Bengkel Motor Rumah',
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
                              '${_bengkel?.latitude.toStringAsFixed(6) ?? _defaultBengkelLocation.latitude.toStringAsFixed(6)}, ${_bengkel?.longitude.toStringAsFixed(6) ?? _defaultBengkelLocation.longitude.toStringAsFixed(6)}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Rumah Anda, Yogyakarta',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
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

