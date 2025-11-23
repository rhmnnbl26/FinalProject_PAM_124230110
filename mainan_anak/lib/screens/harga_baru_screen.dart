import 'package:flutter/material.dart';
import '../models/motor_baru.dart';
import '../models/exchange_rate.dart';
import '../services/api_service.dart';
import '../utils/currency_helper.dart';

class HargaBaruScreen extends StatefulWidget {
  const HargaBaruScreen({super.key});

  @override
  State<HargaBaruScreen> createState() => _HargaBaruScreenState();
}

class _HargaBaruScreenState extends State<HargaBaruScreen> {
  final ApiService _apiService = ApiService();
  List<MotorBaru> _motors = [];
  ExchangeRate? _exchangeRate;
  bool _isLoading = true;
  String _selectedCurrency = 'IDR';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final motors = await _apiService.getMotorBaru();
      final rates = await _apiService.getExchangeRates();
      
      setState(() {
        _motors = motors;
        _exchangeRate = rates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  double _convertPrice(double idrPrice) {
    if (_exchangeRate == null || _selectedCurrency == 'IDR') {
      return idrPrice;
    }
    return _exchangeRate!.convertFromIdr(idrPrice, _selectedCurrency);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harga Motor Baru'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedCurrency,
            onSelected: (value) {
              setState(() => _selectedCurrency = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'IDR', child: Text('IDR (Rupiah)')),
              const PopupMenuItem(value: 'USD', child: Text('USD (Dollar)')),
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
              ? const Center(child: Text('Tidak ada data motor'))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _motors.length,
                    itemBuilder: (context, index) {
                      final motor = _motors[index];
                      return _buildMotorCard(motor);
                    },
                  ),
                ),
    );
  }

  Widget _buildMotorCard(MotorBaru motor) {
    final convertedPrice = _convertPrice(motor.hargaIdr);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (motor.gambar.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                motor.gambar,
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
                Text(
                  motor.nama,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  motor.merk,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
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
                    motor.kategori,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  motor.deskripsi,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Harga:',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      CurrencyHelper.formatCurrency(
                        convertedPrice,
                        _selectedCurrency,
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
