import 'package:flutter/material.dart';
import '../models/apparel.dart';
import '../services/api_service.dart';
import '../utils/currency_helper.dart';
import 'aksesoris_detail_screen.dart';

class AksesorisListScreen extends StatefulWidget {
  const AksesorisListScreen({super.key});

  @override
  State<AksesorisListScreen> createState() => _AksesorisListScreenState();
}

class _AksesorisListScreenState extends State<AksesorisListScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  String? _selectedCategory;
  List<dynamic> _items = [];
  bool _isLoading = true;
  String _selectedCurrency = 'IDR';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCategoryDialog();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _showCategoryDialog() async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shopping_bag, size: 64, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'Pilih Kategori',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Apa yang ingin kamu beli?',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 32),
                _buildCategoryButton(
                  context: context,
                  title: 'Aksesoris Motor',
                  subtitle: 'Knalpot, spion, dll',
                  icon: Icons.motorcycle,
                  gradient: [const Color(0xFFFF9800), const Color(0xFFE65100)],
                  category: 'aksesoris',
                ),
                const SizedBox(height: 16),
                _buildCategoryButton(
                  context: context,
                  title: 'Apparel Berkendara',
                  subtitle: 'Jaket, helm, sarung tangan',
                  icon: Icons.checkroom,
                  gradient: [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
                  category: 'apparel',
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == null) {
      if (mounted) Navigator.pop(context);
    } else {
      setState(() => _selectedCategory = result);
      _loadData();
    }
  }

  Widget _buildCategoryButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required String category,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.pop(context, category),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.black26),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      if (_selectedCategory == 'apparel') {
        final apparelList = await _apiService.getApparel();
        if (!mounted) return;
        setState(() {
          _items = apparelList;
          _isLoading = false;
        });
      } else if (_selectedCategory == 'aksesoris') {
        final aksesorisLst = await _apiService.getAksesoris();
        if (!mounted) return;
        setState(() {
          _items = aksesorisLst;
          _isLoading = false;
        });
      }
      _animationController.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: _isLoading
                ? _buildShimmerLoading()
                : _items.isEmpty
                ? const Center(child: Text('Tidak ada produk'))
                : _buildProductGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Beli Aksesoris',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    initialValue: _selectedCurrency,
                    onSelected: (value) {
                      setState(() => _selectedCurrency = value);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'IDR', child: Text('IDR')),
                      const PopupMenuItem(value: 'USD', child: Text('USD')),
                      const PopupMenuItem(value: 'EUR', child: Text('EUR')),
                      const PopupMenuItem(value: 'JPY', child: Text('JPY')),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _selectedCurrency,
                            style: const TextStyle(color: Colors.white),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _selectedCategory == 'apparel'
                    ? 'Apparel Berkendara'
                    : 'Aksesoris Motor',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_items.length} produk tersedia',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 12,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductGrid() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        return _buildProductCard(index);
      },
    );
  }

  Widget _buildProductCard(int index) {
    final item = _items[index];
    final isApparel = item is Apparel;

    String name, brand, imageUrl;
    double price;
    int stock;

    if (isApparel) {
      final apparelItem = item;
      name = apparelItem.name;
      brand = apparelItem.brand;
      price = apparelItem.price;
      imageUrl = apparelItem.imageUrl.isNotEmpty ? apparelItem.imageUrl[0] : '';
      stock = apparelItem.stock;
    } else {
      final aksesorisItem = item;
      name = aksesorisItem.name;
      brand = aksesorisItem.brand;
      price = aksesorisItem.price;
      imageUrl = aksesorisItem.imageUrl.isNotEmpty
          ? aksesorisItem.imageUrl[0]
          : '';
      stock = aksesorisItem.stock;
    }

    // Staggered animation
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          (index / _items.length) * 0.5,
          ((index + 1) / _items.length) * 0.5 + 0.5,
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
        tag: 'product_${isApparel ? 'apparel' : 'aksesoris'}_$index',
        child: Material(
          type: MaterialType.transparency,
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        AksesorisDetailScreen(
                          item: item,
                          isApparel: isApparel,
                          heroTag:
                              'product_${isApparel ? 'apparel' : 'aksesoris'}_$index',
                        ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;
                          var tween = Tween(
                            begin: begin,
                            end: end,
                          ).chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);
                          return SlideTransition(
                            position: offsetAnimation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: Center(
                              child: Icon(
                                isApparel ? Icons.checkroom : Icons.build,
                                size: 80,
                                color: Colors.grey[600],
                              ),
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
                                name,
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
                                isApparel ? item.category : item.category,
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
                              Icons.business,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              brand,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              stock > 0 ? Icons.check_circle : Icons.cancel,
                              size: 16,
                              color: stock > 0 ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              stock > 0 ? 'Stok: $stock' : 'Habis',
                              style: TextStyle(
                                fontSize: 14,
                                color: stock > 0 ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isApparel ? item.description : item.description,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF2196F3,
                            ).withValues(alpha: 0.1),
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
                                CurrencyHelper.formatCurrency(
                                  price,
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
      ),
    );
  }
}
