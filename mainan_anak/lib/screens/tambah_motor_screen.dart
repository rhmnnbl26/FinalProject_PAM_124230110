import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/motor_listing.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';

class TambahMotorScreen extends StatefulWidget {
  const TambahMotorScreen({super.key});

  @override
  State<TambahMotorScreen> createState() => _TambahMotorScreenState();
}

class _TambahMotorScreenState extends State<TambahMotorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _brandController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _ccController = TextEditingController();
  final _tahunController = TextEditingController();
  final _hargaController = TextEditingController();
  final _kilometerController = TextEditingController();
  final _lokasiController = TextEditingController(text: 'Yogyakarta');
  final _instagramController = TextEditingController();
  final _kontakController = TextEditingController();

  String _kondisi = 'bekas';
  List<File> _selectedImages = [];
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _namaController.dispose();
    _brandController.dispose();
    _deskripsiController.dispose();
    _ccController.dispose();
    _tahunController.dispose();
    _hargaController.dispose();
    _kilometerController.dispose();
    _lokasiController.dispose();
    _instagramController.dispose();
    _kontakController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maksimal 5 foto')),
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error memilih gambar: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<String> _saveImagePermanently(File image, int index) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final motorImagesDir = Directory('${appDir.path}/motor_images');
      
      if (!await motorImagesDir.exists()) {
        await motorImagesDir.create(recursive: true);
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$index.jpg';
      final savedImage = await image.copy('${motorImagesDir.path}/$fileName');
      
      return savedImage.path;
    } catch (e) {
      print('Error saving image: $e');
      return image.path;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimal tambahkan 1 foto motor')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Save images permanently
      List<String?> savedPaths = List.filled(5, null);
      for (int i = 0; i < _selectedImages.length && i < 5; i++) {
        savedPaths[i] = await _saveImagePermanently(_selectedImages[i], i);
      }

      // Create motor listing
      final motor = MotorListing(
        nama: _namaController.text.trim(),
        brand: _brandController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
        cc: int.parse(_ccController.text.trim()),
        tahun: int.parse(_tahunController.text.trim()),
        hargaIdr: double.parse(_hargaController.text.trim()),
        kilometer: int.parse(_kilometerController.text.trim()),
        kondisi: _kondisi,
        lokasi: _lokasiController.text.trim(),
        fotoPath1: savedPaths[0],
        fotoPath2: savedPaths[1],
        fotoPath3: savedPaths[2],
        fotoPath4: savedPaths[3],
        fotoPath5: savedPaths[4],
        instagramLink: _instagramController.text.trim(),
        kontakOpsional: _kontakController.text.trim().isEmpty
            ? null
            : _kontakController.text.trim(),
      );

      await DatabaseHelper.instance.createMotorListing(motor);

      // Show notification
      await NotificationService.instance.showMotorAddedNotification(motor.nama);

      if (!mounted) return;

      // Clear form
      _formKey.currentState!.reset();
      _namaController.clear();
      _brandController.clear();
      _deskripsiController.clear();
      _ccController.clear();
      _tahunController.clear();
      _hargaController.clear();
      _kilometerController.clear();
      _instagramController.clear();
      _kontakController.clear();
      setState(() {
        _selectedImages.clear();
        _kondisi = 'bekas';
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Motor berhasil ditambahkan!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error menambahkan motor: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Motor'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo section
              const Text(
                'Foto Motor (3-5 foto)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...List.generate(_selectedImages.length, (index) {
                      return Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: FileImage(_selectedImages[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 12,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    if (_selectedImages.length < 5)
                      GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[400]!),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate,
                                  size: 40, color: Colors.grey[600]),
                              const SizedBox(height: 4),
                              Text(
                                'Tambah Foto',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Form fields
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Motor *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Nama motor wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Brand/Merk *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Brand wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Deskripsi wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ccController,
                decoration: const InputDecoration(
                  labelText: 'CC Mesin *',
                  border: OutlineInputBorder(),
                  suffixText: 'cc',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'CC wajib diisi';
                  if (int.tryParse(value!) == null) return 'CC harus angka';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tahunController,
                decoration: const InputDecoration(
                  labelText: 'Tahun *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Tahun wajib diisi';
                  if (int.tryParse(value!) == null) return 'Tahun harus angka';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hargaController,
                decoration: const InputDecoration(
                  labelText: 'Harga (IDR) *',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Harga wajib diisi';
                  if (double.tryParse(value!) == null) {
                    return 'Harga harus angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _kilometerController,
                decoration: const InputDecoration(
                  labelText: 'Kilometer *',
                  border: OutlineInputBorder(),
                  suffixText: 'km',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Kilometer wajib diisi';
                  if (int.tryParse(value!) == null) {
                    return 'Kilometer harus angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _kondisi,
                decoration: const InputDecoration(
                  labelText: 'Kondisi *',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'baru', child: Text('Baru')),
                  DropdownMenuItem(value: 'bekas', child: Text('Bekas')),
                ],
                onChanged: (value) {
                  setState(() => _kondisi = value!);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lokasiController,
                decoration: const InputDecoration(
                  labelText: 'Lokasi *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Lokasi wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _instagramController,
                decoration: const InputDecoration(
                  labelText: 'Link Instagram *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Link Instagram wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _kontakController,
                decoration: const InputDecoration(
                  labelText: 'Kontak (Opsional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Tambah Motor',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
