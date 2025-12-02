import 'package:flutter/material.dart';
import 'dart:async';
import 'motor_marketplace_screen.dart';
import 'favorites_screen.dart';
import 'tambah_motor_screen.dart';
import 'bengkel_voucher_screen.dart';
import 'harga_baru_screen.dart';
import 'aksesoris_list_screen.dart';

class HomeNewScreen extends StatefulWidget {
  const HomeNewScreen({super.key});

  @override
  State<HomeNewScreen> createState() => _HomeNewScreenState();
}

class _HomeNewScreenState extends State<HomeNewScreen> {
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'Jual Beli Motor',
      'subtitle': 'Temukan motor impian Anda',
      'gradient': [Color(0xFF2196F3), Color(0xFF1565C0)],
      'icon': Icons.motorcycle,
    },
    {
      'title': 'Servis Terpercaya',
      'subtitle': 'Rawat motor dengan ahlinya',
      'gradient': [Color(0xFF00BCD4), Color(0xFF0097A7)],
      'icon': Icons.build,
    },
    {
      'title': 'Promo Menarik',
      'subtitle': 'Dapatkan diskon hingga 50%',
      'gradient': [Color(0xFF4CAF50), Color(0xFF388E3C)],
      'icon': Icons.local_offer,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startBannerAutoSlide();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _startBannerAutoSlide() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentBannerIndex < _banners.length - 1) {
        _currentBannerIndex++;
      } else {
        _currentBannerIndex = 0;
      }
      if (_bannerController.hasClients) {
        _bannerController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            _buildBannerCarousel(),
            _buildNavigationGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF121212),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Children\'s Toys',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            '"A man never grows old, it just the toys get bigger."',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCarousel() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _bannerController,
              onPageChanged: (index) {
                setState(() => _currentBannerIndex = index);
              },
              itemCount: _banners.length,
              itemBuilder: (context, index) {
                final banner = _banners[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: banner['gradient'] as List<Color>,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (banner['gradient'] as List<Color>)[0].withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        bottom: -20,
                        child: Icon(
                          banner['icon'] as IconData,
                          size: 150,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              banner['title'] as String,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              banner['subtitle'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _banners.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentBannerIndex == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentBannerIndex == index
                      ? const Color(0xFF2196F3)
                      : Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNavigationGrid() {
    final menuItems = [
      {
        'title': 'Beli Motor',
        'subtitle': 'Cari motor impian',
        'icon': Icons.shopping_cart,
        'gradient': [Color(0xFF2196F3), Color(0xFF1976D2)],
        'route': const MotorMarketplaceScreen(),
      },
      {
        'title': 'Jual Motor',
        'subtitle': 'Pasang iklan gratis',
        'icon': Icons.add_circle,
        'gradient': [Color(0xFF00BCD4), Color(0xFF00838F)],
        'route': const TambahMotorScreen(),
      },
      {
        'title': 'Motor Care',
        'subtitle': 'Servis & promo',
        'icon': Icons.build_circle,
        'gradient': [Color(0xFF4CAF50), Color(0xFF2E7D32)],
        'route': const BengkelVoucherScreen(),
      },
      {
        'title': 'Bike Gallery',
        'subtitle': 'Harga motor baru',
        'icon': Icons.style,
        'gradient': [Color(0xFFFF9800), Color(0xFFE65100)],
        'route': const HargaBaruScreen(),
      },
      {
        'title': 'Motor Favorit',
        'subtitle': 'Koleksi pilihan',
        'icon': Icons.favorite,
        'gradient': [Color(0xFFE91E63), Color(0xFFC2185B)],
        'route': const FavoritesScreen(),
      },
      {
        'title': 'Beli Aksesoris',
        'subtitle': 'Apparel & parts',
        'icon': Icons.shopping_bag,
        'gradient': [Color(0xFF9C27B0), Color(0xFF6A1B9A)],
        'route': const AksesorisListScreen(),
      },
    ];

    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = menuItems[index];
            return _buildNavigationCard(
              title: item['title'] as String,
              subtitle: item['subtitle'] as String,
              icon: item['icon'] as IconData,
              gradient: item['gradient'] as List<Color>,
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        item['route'] as Widget,
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 1.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;
                      
                      var tween = Tween(begin: begin, end: end).chain(
                        CurveTween(curve: curve),
                      );
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
            );
          },
          childCount: menuItems.length,
        ),
      ),
    );
  }

  Widget _buildNavigationCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                gradient[0].withValues(alpha: 0.1),
                gradient[1].withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: gradient[0].withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: gradient[0].withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
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
