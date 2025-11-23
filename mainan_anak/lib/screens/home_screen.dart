import 'package:flutter/material.dart';
import '../models/motor_listing.dart';
import '../services/database_helper.dart';
import 'detail_motor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MotorListing> _motors = [];
  List<MotorListing> _filteredMotors = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();
  String? _selectedBrand;
  int? _selectedCC;
  String? _selectedKondisi;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _loadMotors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMotors() async {
    setState(() => _isLoading = true);
    try {
      final motors = await DatabaseHelper.instance.getAllMotorListings();
      setState(() {
        _motors = motors;
        _filteredMotors = motors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading motors: $e')),
        );
      }
    }
  }

  void _searchMotors(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMotors = _motors;
      } else {
        _filteredMotors = _motors
            .where((motor) =>
                motor.nama.toLowerCase().contains(query.toLowerCase()) ||
                motor.brand.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredMotors = _motors.where((motor) {
        if (_selectedBrand != null && motor.brand != _selectedBrand) {
          return false;
        }
        if (_selectedCC != null && motor.cc != _selectedCC) {
          return false;
        }
        if (_selectedKondisi != null && motor.kondisi != _selectedKondisi) {
          return false;
        }
        return true;
      }).toList();
    });
  }

  void _sortByPrice() {
    setState(() {
      _sortAscending = !_sortAscending;
      _filteredMotors.sort((a, b) {
        return _sortAscending
            ? a.hargaIdr.compareTo(b.hargaIdr)
            : b.hargaIdr.compareTo(a.hargaIdr);
      });
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Motor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedBrand,
                decoration: const InputDecoration(labelText: 'Brand'),
                items: _getUniqueBrands()
                    .map((brand) => DropdownMenuItem(
                          value: brand,
                          child: Text(brand),
                        ))
                    .toList(),
                onChanged: (value) => _selectedBrand = value,
              ),
              DropdownButtonFormField<int>(
                value: _selectedCC,
                decoration: const InputDecoration(labelText: 'CC'),
                items: _getUniqueCC()
                    .map((cc) => DropdownMenuItem(
                          value: cc,
                          child: Text('$cc cc'),
                        ))
                    .toList(),
                onChanged: (value) => _selectedCC = value,
              ),
              DropdownButtonFormField<String>(
                value: _selectedKondisi,
                decoration: const InputDecoration(labelText: 'Kondisi'),
                items: const [
                  DropdownMenuItem(value: 'baru', child: Text('Baru')),
                  DropdownMenuItem(value: 'bekas', child: Text('Bekas')),
                ],
                onChanged: (value) => _selectedKondisi = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedBrand = null;
                _selectedCC = null;
                _selectedKondisi = null;
                _filteredMotors = _motors;
              });
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
          ElevatedButton(
            onPressed: () {
              _applyFilters();
              Navigator.pop(context);
            },
            child: const Text('Terapkan'),
          ),
        ],
      ),
    );
  }

  List<String> _getUniqueBrands() {
    return _motors.map((m) => m.brand).toSet().toList()..sort();
  }

  List<int> _getUniqueCC() {
    return _motors.map((m) => m.cc).toSet().toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Children\'s Toys'),
        actions: [
          IconButton(
            icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: _sortByPrice,
            tooltip: 'Sort by price',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari motor...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: _searchMotors,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredMotors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.motorcycle_outlined,
                                size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada motor tersedia',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadMotors,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredMotors.length,
                          itemBuilder: (context, index) {
                            final motor = _filteredMotors[index];
                            return _buildMotorCard(motor);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotorCard(MotorListing motor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailMotorScreen(motorId: motor.id!),
            ),
          );
          _loadMotors(); // Refresh after returning
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: motor.fotoPath1 != null
                    ? Image.asset(
                        motor.fotoPath1!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[300],
                            child: const Icon(Icons.motorcycle, size: 50),
                          );
                        },
                      )
                    : Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: const Icon(Icons.motorcycle, size: 50),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      motor.nama,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      motor.brand,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.speed, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('${motor.cc} cc', style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 12),
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('${motor.tahun}', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rp ${motor.hargaIdr.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
