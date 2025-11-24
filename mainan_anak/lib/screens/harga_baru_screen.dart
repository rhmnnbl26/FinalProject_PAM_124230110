import 'package:flutter/material.dart';
import 'motor_list_screen.dart';

class HargaBaruScreen extends StatelessWidget {
  const HargaBaruScreen({super.key});

  static const Map<String, String> brandAssets = {
    'Ducati': 'images/ducati.PNG',
    'BMW Motorrad': 'images/bmw.jpg',
    'Honda': 'images/honda.jpg',
    'Yamaha': 'images/yamaha.jpg',
    'Kawasaki': 'images/kawasaki.jpg',
    'KTM': 'images/ktm.png',
    'Suzuki': 'images/suzuki.png',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harga Motor Baru'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Brand Motor',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap brand untuk melihat daftar motor',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 3.5,
                ),
                itemCount: brandAssets.length,
                itemBuilder: (context, index) {
                  final brand = brandAssets.keys.elementAt(index);
                  final asset = brandAssets[brand]!;
                  return _buildBrandCard(context, brand, asset);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandCard(BuildContext context, String brand, String asset) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MotorListScreen(brand: brand),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(
                asset,
                width: 80,
                height: 80,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  print('ERROR loading $asset: $error');
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.motorcycle, 
                        size: 40, 
                        color: Theme.of(context).primaryColor,
                      ),
                      Text(
                        brand,
                        style: const TextStyle(fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                child: Text(
                  brand,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
