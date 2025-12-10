import 'package:flutter/material.dart';
import '../models/motor_baru.dart';
import '../services/api_service.dart';

class MotorListScreen extends StatefulWidget {
  final String brand;

  const MotorListScreen({super.key, required this.brand});

  @override
  State<MotorListScreen> createState() => _MotorListScreenState();
}

class _MotorListScreenState extends State<MotorListScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<MotorBaru> _motors = [];
  bool _isLoading = true;
  String _selectedCurrency = 'USD';
  Map<String, double> _conversionRates = {'USD': 1.0};
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final motors = await _apiService.getMotorByBrand(widget.brand);
      await _loadConversionRates();

      setState(() {
        _motors = motors;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  Future<void> _loadConversionRates() async {
    try {
      final idr = await _apiService.convertFromUsd(1, 'IDR');
      final eur = await _apiService.convertFromUsd(1, 'EUR');
      final jpy = await _apiService.convertFromUsd(1, 'JPY');

      setState(() {
        _conversionRates = {'USD': 1.0, 'IDR': idr, 'EUR': eur, 'JPY': jpy};
      });
    } catch (e) {
      // Error handled silently
    }
  }

  double _convertPrice(double usdPrice) {
    return usdPrice * (_conversionRates[_selectedCurrency] ?? 1.0);
  }

  String _formatCurrency(double amount, String currency) {
    switch (currency) {
      case 'IDR':
        return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
      case 'USD':
        return '\$${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
      case 'EUR':
        return '€${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
      case 'JPY':
        return '¥${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
      default:
        return amount.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Motor ${widget.brand}'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedCurrency,
            onSelected: (value) {
              setState(() => _selectedCurrency = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'USD', child: Text('USD (Dollar)')),
              const PopupMenuItem(value: 'IDR', child: Text('IDR (Rupiah)')),
              const PopupMenuItem(value: 'EUR', child: Text('EUR (Euro)')),
              const PopupMenuItem(value: 'JPY', child: Text('JPY (Yen)')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(_selectedCurrency, style: const TextStyle(fontSize: 16)),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _motors.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.motorcycle, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada motor ${widget.brand}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Colors.orange[50],
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '⚠️ Harga belum termasuk pajak dan biaya administrasi',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.orange[900],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _motors.length,
                      itemBuilder: (context, index) {
                        final motor = _motors[index];
                        return _buildMotorCard(motor, index);
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMotorCard(MotorBaru motor, int index) {
    final convertedPrice = _convertPrice(motor.priceUsd);

    // Staggered animation
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          (index / _motors.length) * 0.5,
          ((index + 1) / _motors.length) * 0.5 + 0.5,
          curve: Curves.easeOut,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - animation.value)),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
      child: Hero(
        tag: 'motor_${motor.id}',
        child: Material(
          type: MaterialType.transparency,
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (motor.images.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.network(
                      motor.images.first,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.motorcycle, size: 80),
                          ),
                        );
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              motor.model,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              motor.type,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${motor.year}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.speed, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${motor.cc} CC',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        motor.description,
                        style: const TextStyle(fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Harga:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _formatCurrency(
                                convertedPrice,
                                _selectedCurrency,
                              ),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2196F3),
                              ),
                            ),
                          ],
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
    );
  }
}
