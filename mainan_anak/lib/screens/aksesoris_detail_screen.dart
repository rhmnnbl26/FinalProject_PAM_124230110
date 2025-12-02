import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/apparel.dart';
import '../models/aksesoris.dart';
import '../services/api_service.dart';
import '../models/exchange_rate.dart';
import '../utils/currency_helper.dart';

class AksesorisDetailScreen extends StatefulWidget {
  final dynamic item;
  final bool isApparel;
  final String heroTag;

  const AksesorisDetailScreen({
    super.key,
    required this.item,
    required this.isApparel,
    required this.heroTag,
  });

  @override
  State<AksesorisDetailScreen> createState() => _AksesorisDetailScreenState();
}

class _AksesorisDetailScreenState extends State<AksesorisDetailScreen> {
  final ApiService _apiService = ApiService();
  int _currentPhotoIndex = 0;
  String _selectedCurrency = 'IDR';
  ExchangeRate? _exchangeRate;
  bool _isLoadingRates = true;

  @override
  void initState() {
    super.initState();
    _loadExchangeRates();
  }

  Future<void> _loadExchangeRates() async {
    try {
      final rates = await _apiService.getExchangeRates();
      if (!mounted) return;
      setState(() {
        _exchangeRate = rates;
        _isLoadingRates = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingRates = false);
    }
  }

  double _convertPrice(double idrPrice) {
    if (_exchangeRate == null || _selectedCurrency == 'IDR') {
      return idrPrice;
    }
    return _exchangeRate!.convertFromIdr(idrPrice, _selectedCurrency);
  }

  Future<void> _openLink(String url) async {
    try {
      String urlString = url.trim();
      if (!urlString.startsWith('http://') && !urlString.startsWith('https://')) {
        urlString = 'https://$urlString';
      }
      final uri = Uri.parse(urlString);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error membuka link: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isApparel = widget.isApparel;
    final name = isApparel ? (widget.item as Apparel).name : (widget.item as Aksesoris).name;
    final brand = isApparel ? (widget.item as Apparel).brand : (widget.item as Aksesoris).brand;
    final price = isApparel ? (widget.item as Apparel).price : (widget.item as Aksesoris).price;
    final images = isApparel ? (widget.item as Apparel).imageUrl : (widget.item as Aksesoris).imageUrl;
    final description = isApparel ? (widget.item as Apparel).description : (widget.item as Aksesoris).description;
    final stock = isApparel ? (widget.item as Apparel).stock : (widget.item as Aksesoris).stock;
    final linkUrl = isApparel ? (widget.item as Apparel).linkUrl : (widget.item as Aksesoris).linkUrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPhotoSection(images),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    brand,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2196F3),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPriceCard(price),
                  const SizedBox(height: 16),
                  _buildStockCard(stock),
                  const SizedBox(height: 16),
                  if (isApparel) _buildApparelSpecs(widget.item as Apparel),
                  if (!isApparel) _buildAksesorisSpecs(widget.item as Aksesoris),
                  const SizedBox(height: 16),
                  _buildDescriptionCard(description),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => _openLink(linkUrl),
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Beli Sekarang'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection(List<String> images) {
    if (images.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.image, size: 100, color: Colors.grey),
        ),
      );
    }

    return Hero(
      tag: widget.heroTag,
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: PageView.builder(
              itemCount: images.length,
              onPageChanged: (index) {
                setState(() => _currentPhotoIndex = index);
              },
              itemBuilder: (context, index) {
                return Image.network(
                  images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 100),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[850],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (images.length > 1)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPhotoIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPhotoIndex == index
                          ? const Color(0xFF2196F3)
                          : Colors.grey[400],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(double price) {
    final convertedPrice = _convertPrice(price);
    
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
            _isLoadingRates
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    CurrencyHelper.formatCurrency(convertedPrice, _selectedCurrency),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockCard(int stock) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              stock > 0 ? Icons.check_circle : Icons.cancel,
              color: stock > 0 ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 12),
            Text(
              stock > 0 ? 'Stok tersedia: $stock unit' : 'Stok habis',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: stock > 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApparelSpecs(Apparel apparel) {
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
            _buildSpecRow('Kategori', apparel.category),
            _buildSpecRow('Gender', apparel.gender),
            const SizedBox(height: 8),
            const Text(
              'Ukuran Tersedia:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: apparel.size.map((size) {
                return Chip(
                  label: Text(size),
                  backgroundColor: const Color(0xFF2196F3).withValues(alpha: 0.2),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAksesorisSpecs(Aksesoris aksesoris) {
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
            _buildSpecRow('Kategori', aksesoris.category),
            const SizedBox(height: 8),
            const Text(
              'Kompatibilitas:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ...aksesoris.compatibility.map((comp) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(child: Text(comp)),
                  ],
                ),
              );
            }),
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

  Widget _buildDescriptionCard(String description) {
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
              description,
              style: const TextStyle(fontSize: 14, height: 1.5),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
