// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import '../models/motor_model.dart';
import '../services/motor_service.dart';
import '../widgets/motor_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<MotorModel> motors = [];
  List<MotorModel> filteredMotors = [];
  bool isLoading = true;
  bool isError = false;

  String searchQuery = "";
  String selectedCategory = "all";

  @override
  void initState() {
    super.initState();
    loadMotors();
  }

  Future<void> loadMotors() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      motors = await MotorService.fetchMotors();
      filteredMotors = motors;
    } catch (e) {
      isError = true;
    }

    setState(() {
      isLoading = false;
    });
  }

  void applyFilters() {
    List<MotorModel> temp = List.from(motors);

    if (searchQuery.isNotEmpty) {
      temp = temp.where((m) {
        final nama = m.nama.toLowerCase();
        final merk = m.merk.toLowerCase();
        final q = searchQuery.toLowerCase();
        return nama.contains(q) || merk.contains(q);
      }).toList();
    }

    if (selectedCategory != "all") {
      temp = temp
          .where((m) => m.kategori.toLowerCase() == selectedCategory)
          .toList();
    }

    setState(() {
      filteredMotors = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = ["all", "naked", "sportbike"];

    return Scaffold(
      appBar: AppBar(
        title: const Text("ChildsPlay Motors"),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Gagal memuat data 😢"),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: loadMotors,
                    child: const Text("Coba lagi"),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Search
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Cari motor atau merk...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      searchQuery = value;
                      applyFilters();
                    },
                  ),
                ),

                // Filter Chips
                SizedBox(
                  height: 45,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: categories.map((cat) {
                      final isSelected = selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat.toUpperCase()),
                          selected: isSelected,
                          selectedColor: Colors.deepPurpleAccent,
                          backgroundColor: Colors.grey[300],
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (value) {
                            setState(() {
                              selectedCategory = cat;
                            });
                            applyFilters();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 8),

                // List
                Expanded(
                  child: filteredMotors.isEmpty
                      ? const Center(child: Text("Motor tidak ditemukan 😢"))
                      : ListView.builder(
                          itemCount: filteredMotors.length,
                          itemBuilder: (context, index) {
                            final motor = filteredMotors[index];
                            return MotorCard(motor: motor);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
