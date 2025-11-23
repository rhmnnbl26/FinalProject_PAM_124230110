import 'package:flutter/material.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import '../models/motor_listing.dart';
import '../services/database_helper.dart';

class DetailMotorScreen extends StatefulWidget {
  final int motorId;

  const DetailMotorScreen({super.key, required this.motorId});

  @override
  State<DetailMotorScreen> createState() => _DetailMotorScreenState();
}

class _DetailMotorScreenState extends State<DetailMotorScreen> {
  MotorListing? _motor;
  bool _isLoading = true;
  int _currentPhotoIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadMotorDetail();
  }

  Future<void> _loadMotorDetail() async {
    setState(() => _isLoading = true);
    try {
      final motor = await DatabaseHelper.instance.getMotorListingById(widget.motorId);
      setState(() {
        _motor = motor;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading motor: $e')),
        );
      }
    }
  }

  Future<void> _openInstagram() async {
    if (_motor == null || _motor!.instagramLink.isEmpty) return;

    final url = Uri.parse(_motor!.instagramLink);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka link Instagram')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Motor'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _motor == null
              ? const Center(child: Text('Motor tidak ditemukan'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPhotoSection(),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _motor!.nama,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _motor!.brand,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildPriceCard(),
                            const SizedBox(height: 16),
                            _buildSpecsCard(),
                            const SizedBox(height: 16),
                            _buildDescriptionCard(),
                            const SizedBox(height: 16),
                            _buildLocationCard(),
                            if (_motor!.kontakOpsional != null &&
                                _motor!.kontakOpsional!.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              _buildContactCard(),
                            ],
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: _openInstagram,
                                icon: const Icon(Icons.shopping_cart),
                                label: const Text('Beli via Instagram'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPhotoSection() {
    final photos = _motor!.allPhotos;
    
    if (photos.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.motorcycle, size: 100, color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            itemCount: photos.length,
            onPageChanged: (index) {
              setState(() => _currentPhotoIndex = index);
            },
            itemBuilder: (context, index) {
              return Image.file(
                File(photos[index]),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.motorcycle, size: 100),
                  );
                },
              );
            },
          ),
        ),
        if (photos.length > 1)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                photos.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPhotoIndex == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey[400],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPriceCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Harga',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Rp ${_motor!.hargaIdr.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Spesifikasi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSpecRow('CC Mesin', '${_motor!.cc} cc'),
            _buildSpecRow('Tahun', '${_motor!.tahun}'),
            _buildSpecRow('Kilometer', '${_motor!.kilometer} km'),
            _buildSpecRow('Kondisi', _motor!.kondisi),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Deskripsi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _motor!.deskripsi,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              _motor!.lokasi,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.phone, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              _motor!.kontakOpsional!,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
