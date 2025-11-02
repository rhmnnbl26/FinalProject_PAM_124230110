import 'package:flutter/material.dart';
import '../models/motor_model.dart';
import '../services/motor_service.dart';
import 'detail_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  final String username;
  const HomePage({Key? key, required this.username}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final MotorService _motorService = MotorService();
  late Future<List<MotorModel>> _motorList;
  List<MotorModel> _filteredMotors = [];

  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    _motorList = _motorService.getMotors();
  }

  void _filterMotors(List<MotorModel> allMotors) {
    setState(() {
      _filteredMotors = allMotors.where((motor) {
        final matchSearch =
            motor.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            motor.merk.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchCategory =
            _selectedCategory == 'Semua' ||
            motor.kategori.toLowerCase() == _selectedCategory.toLowerCase();
        return matchSearch && matchCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      Scaffold(
        appBar: AppBar(
          title: const Text('Daftar Motor Besar'),
          backgroundColor: Colors.green.shade700,
        ),
        body: FutureBuilder<List<MotorModel>>(
          future: _motorList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Gagal memuat data: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Data motor kosong.'));
            }

            final allMotors = snapshot.data!;
            _filteredMotors = _filteredMotors.isEmpty && _searchQuery.isEmpty
                ? allMotors
                : _filteredMotors;

            return Column(
              children: [
                // 🔍 Search Bar
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari motor...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      _searchQuery = value;
                      _filterMotors(allMotors);
                    },
                  ),
                ),

                // 🏍️ Dropdown Filter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Filter Kategori',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: ['Semua', 'Sportbike', 'Naked']
                        .map(
                          (kategori) => DropdownMenuItem(
                            value: kategori,
                            child: Text(kategori),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                      _filterMotors(allMotors);
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // 📋 ListView Motor
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredMotors.length,
                    itemBuilder: (context, index) {
                      final motor = _filteredMotors[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPage(
                                name: motor.nama,
                                price: motor.hargaIdr,
                                brand: motor.merk,
                                image: motor.gambar,
                                description: motor.deskripsi,
                              ),
                            ),
                          );
                        },
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                                child: Image.network(
                                  motor.gambar,
                                  width: 120,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image, size: 80),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 6,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        motor.nama,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        motor.merk,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Rp ${motor.hargaIdr}",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      const ProfilPage(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green.shade700,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.motorcycle), label: 'Motor'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
