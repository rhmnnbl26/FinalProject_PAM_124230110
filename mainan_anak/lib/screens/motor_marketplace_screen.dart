import 'package:flutter/material.dart';
import 'dart:io';
import '../models/motor_listing.dart';
import '../services/database_helper.dart';
import '../services/lbs_service.dart';
import 'detail_motor_screen.dart';

class MotorMarketplaceScreen extends StatefulWidget {
  const MotorMarketplaceScreen({super.key});

  @override
  State<MotorMarketplaceScreen> createState() => _MotorMarketplaceScreenState();
}

class _MotorMarketplaceScreenState extends State<MotorMarketplaceScreen> with SingleTickerProviderStateMixin {
  List<MotorListing> _motors = [];
  List<MotorListing> _filteredMotors = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();
  String? _selectedBrand;
  int? _selectedCC;
  String? _selectedKondisi;
  double? _selectedMaxDistance;
  String _sortBy = 'newest'; // newest, price_low, price_high, distance
  final LbsService _lbsService = LbsService();
  Map<int, double?> _motorDistances = {};
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadMotors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadMotors() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final motors = await DatabaseHelper.instance.getAllMotorListings();
      
      // Calculate distances
      final distances = <int, double?>{};
      for (final motor in motors) {
        if (motor.id != null && motor.latitude != null && motor.longitude != null) {
          final distance = await _lbsService.calculateDistanceToMotor(
            motor.latitude,
            motor.longitude,
          );
          distances[motor.id!] = distance;
        }
      }
      
      if (!mounted) return;
      setState(() {
        _motors = motors;
        _motorDistances = distances;
        _applyFiltersAndSort();
        _isLoading = false;
      });
      
      _animationController.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _searchMotors(String query) {
    if (!mounted) return;
    setState(() {
      _applyFiltersAndSort(searchQuery: query);
    });
  }

  void _applyFiltersAndSort({String? searchQuery}) {
    var filtered = List<MotorListing>.from(_motors);
    
    // Search filter
    final query = searchQuery ?? _searchController.text;
    if (query.isNotEmpty) {
      filtered = filtered.where((motor) =>
        motor.nama.toLowerCase().contains(query.toLowerCase()) ||
        motor.brand.toLowerCase().contains(query.toLowerCase())).toList();
    }
    
    // Brand filter
    if (_selectedBrand != null) {
      filtered = filtered.where((m) => m.brand == _selectedBrand).toList();
    }
    
    // CC filter
    if (_selectedCC != null) {
      filtered = filtered.where((m) => m.cc == _selectedCC).toList();
    }
    
    // Kondisi filter
    if (_selectedKondisi != null) {
      filtered = filtered.where((m) => m.kondisi == _selectedKondisi).toList();
    }
    
    // Distance filter
    if (_selectedMaxDistance != null) {
      filtered = filtered.where((motor) {
        if (motor.id == null) return false;
        final distance = _motorDistances[motor.id];
        return distance != null && distance <= _selectedMaxDistance!;
      }).toList();
    }
    
    // Sorting
    switch (_sortBy) {
      case 'price_low':
        filtered.sort((a, b) => a.hargaIdr.compareTo(b.hargaIdr));
        break;
      case 'price_high':
        filtered.sort((a, b) => b.hargaIdr.compareTo(a.hargaIdr));
        break;
      case 'distance':
        filtered.sort((a, b) {
          final distA = _motorDistances[a.id] ?? double.infinity;
          final distB = _motorDistances[b.id] ?? double.infinity;
          return distA.compareTo(distB);
        });
        break;
      case 'newest':
      default:
        break;
    }
    
    setState(() {
      _filteredMotors = filtered;
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) => _FilterBottomSheet(
        selectedBrand: _selectedBrand,
        selectedCC: _selectedCC,
        selectedKondisi: _selectedKondisi,
        selectedMaxDistance: _selectedMaxDistance,
        allMotors: _motors,
        onApply: (brand, cc, kondisi, distance) {
          setState(() {
            _selectedBrand = brand;
            _selectedCC = cc;
            _selectedKondisi = kondisi;
            _selectedMaxDistance = distance;
            _applyFiltersAndSort();
          });
          Navigator.pop(context);
        },
        onReset: () {
          setState(() {
            _selectedBrand = null;
            _selectedCC = null;
            _selectedKondisi = null;
            _selectedMaxDistance = null;
            _applyFiltersAndSort();
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          _buildHeroSection(),
          _buildQuickFilters(),
          _buildMotorGrid(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 0,
      backgroundColor: const Color(0xFF121212),
      title: const Text(
        'Motor Marketplace',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Find Your Dream',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Big Bike',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 20),
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _searchMotors,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Search motorcycles...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF2196F3)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.tune, color: Color(0xFF2196F3)),
                    onPressed: _showFilterSheet,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.motorcycle, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${_filteredMotors.length} motorcycles available',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFilters() {
    return SliverToBoxAdapter(
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildSortChip('Newest', _sortBy == 'newest', () => setState(() {
              _sortBy = 'newest';
              _applyFiltersAndSort();
            })),
            _buildSortChip('Price: Low', _sortBy == 'price_low', () => setState(() {
              _sortBy = 'price_low';
              _applyFiltersAndSort();
            })),
            _buildSortChip('Price: High', _sortBy == 'price_high', () => setState(() {
              _sortBy = 'price_high';
              _applyFiltersAndSort();
            })),
            _buildSortChip('Nearest', _sortBy == 'distance', () => setState(() {
              _sortBy = 'distance';
              _applyFiltersAndSort();
            })),
          ],
        ),
      ),
    );
  }

  Widget _buildSortChip(String label, bool selected, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        backgroundColor: const Color(0xFF1E1E1E),
        selectedColor: const Color(0xFF2196F3),
        labelStyle: TextStyle(
          color: selected ? Colors.white : Colors.grey[400],
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: selected ? const Color(0xFF2196F3) : Colors.white.withValues(alpha: 0.1),
        ),
      ),
    );
  }

  Widget _buildMotorGrid() {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF2196F3)),
        ),
      );
    }

    if (_filteredMotors.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.motorcycle_outlined, size: 80, color: Colors.grey[700]),
              const SizedBox(height: 16),
              Text(
                'No motorcycles found',
                style: TextStyle(fontSize: 18, color: Colors.grey[400], fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedBrand = null;
                    _selectedCC = null;
                    _selectedKondisi = null;
                    _selectedMaxDistance = null;
                    _searchController.clear();
                    _applyFiltersAndSort();
                  });
                },
                child: const Text('Clear filters'),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final motor = _filteredMotors[index];
            return _buildMotorCard(motor, index);
          },
          childCount: _filteredMotors.length,
        ),
      ),
    );
  }

  Widget _buildMotorCard(MotorListing motor, int index) {
    final distance = motor.id != null ? _motorDistances[motor.id] : null;
    
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2196F3).withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailMotorScreen(motorId: motor.id!)),
              );
              _loadMotors();
            },
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section with badges
                Stack(
                  children: [
                    Hero(
                      tag: 'motor_${motor.id}',
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: motor.fotoPath1 != null
                            ? Image.file(
                                File(motor.fotoPath1!),
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                              )
                            : _buildPlaceholderImage(),
                      ),
                    ),
                    // Gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Brand badge
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2196F3).withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          motor.brand,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    // Distance badge
                    if (distance != null)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on, size: 14, color: Color(0xFF2196F3)),
                              const SizedBox(width: 4),
                              Text(
                                _lbsService.formatDistance(distance),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Condition badge
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: motor.kondisi == 'baru' 
                              ? const Color(0xFF4CAF50).withOpacity(0.9)
                              : const Color(0xFFFF9800).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          motor.kondisi == 'baru' ? 'NEW' : 'USED',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Info section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        motor.nama,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      // Specs row
                      Row(
                        children: [
                          _buildSpecBadge(Icons.speed, '${motor.cc}cc'),
                          const SizedBox(width: 12),
                          _buildSpecBadge(Icons.calendar_today, '${motor.tahun}'),
                          const SizedBox(width: 12),
                          _buildSpecBadge(Icons.settings, motor.kondisi == 'baru' ? 'Brand New' : 'Pre-owned'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Price and action
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Price',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rp ${_formatPrice(motor.hargaIdr)}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2196F3),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2196F3).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[400]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[300],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Icon(Icons.motorcycle, size: 80, color: Colors.grey[700]),
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}

// Filter Bottom Sheet Widget
class _FilterBottomSheet extends StatefulWidget {
  final String? selectedBrand;
  final int? selectedCC;
  final String? selectedKondisi;
  final double? selectedMaxDistance;
  final List<MotorListing> allMotors;
  final Function(String?, int?, String?, double?) onApply;
  final VoidCallback onReset;

  const _FilterBottomSheet({
    required this.selectedBrand,
    required this.selectedCC,
    required this.selectedKondisi,
    required this.selectedMaxDistance,
    required this.allMotors,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late String? _brand;
  late int? _cc;
  late String? _kondisi;
  late double? _maxDistance;

  @override
  void initState() {
    super.initState();
    _brand = widget.selectedBrand;
    _cc = widget.selectedCC;
    _kondisi = widget.selectedKondisi;
    _maxDistance = widget.selectedMaxDistance;
  }

  List<String> get _uniqueBrands {
    return widget.allMotors.map((m) => m.brand).toSet().toList()..sort();
  }

  List<int> get _uniqueCC {
    return widget.allMotors.map((m) => m.cc).toSet().toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              TextButton(
                onPressed: widget.onReset,
                child: const Text('Reset All'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Brand', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _uniqueBrands.map((brand) {
              final selected = _brand == brand;
              return FilterChip(
                label: Text(brand),
                selected: selected,
                onSelected: (value) => setState(() => _brand = value ? brand : null),
                backgroundColor: const Color(0xFF121212),
                selectedColor: const Color(0xFF2196F3),
                labelStyle: TextStyle(color: selected ? Colors.white : Colors.grey[400]),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text('Engine CC', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _uniqueCC.map((cc) {
              final selected = _cc == cc;
              return FilterChip(
                label: Text('${cc}cc'),
                selected: selected,
                onSelected: (value) => setState(() => _cc = value ? cc : null),
                backgroundColor: const Color(0xFF121212),
                selectedColor: const Color(0xFF2196F3),
                labelStyle: TextStyle(color: selected ? Colors.white : Colors.grey[400]),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text('Condition', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FilterChip(
                  label: const Text('New'),
                  selected: _kondisi == 'baru',
                  onSelected: (value) => setState(() => _kondisi = value ? 'baru' : null),
                  backgroundColor: const Color(0xFF121212),
                  selectedColor: const Color(0xFF2196F3),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilterChip(
                  label: const Text('Used'),
                  selected: _kondisi == 'bekas',
                  onSelected: (value) => setState(() => _kondisi = value ? 'bekas' : null),
                  backgroundColor: const Color(0xFF121212),
                  selectedColor: const Color(0xFF2196F3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Max Distance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [5.0, 10.0, 25.0, 50.0].map((distance) {
              final selected = _maxDistance == distance;
              return FilterChip(
                label: Text('${distance.toInt()}km'),
                selected: selected,
                onSelected: (value) => setState(() => _maxDistance = value ? distance : null),
                backgroundColor: const Color(0xFF121212),
                selectedColor: const Color(0xFF2196F3),
                labelStyle: TextStyle(color: selected ? Colors.white : Colors.grey[400]),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => widget.onApply(_brand, _cc, _kondisi, _maxDistance),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('Apply Filters'),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
