import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/motor_listing.dart';
import '../services/database_helper.dart';

class EditMotorScreen extends StatefulWidget {
  final MotorListing motor;

  const EditMotorScreen({super.key, required this.motor});

  @override
  State<EditMotorScreen> createState() => _EditMotorScreenState();
}

class _EditMotorScreenState extends State<EditMotorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _brandController;
  late TextEditingController _deskripsiController;
  late TextEditingController _ccController;
  late TextEditingController _tahunController;
  late TextEditingController _hargaController;
  late TextEditingController _kilometerController;
  late TextEditingController _lokasiController;
  late TextEditingController _instagramController;
  late TextEditingController _kontakController;

  late String _kondisi;
  final List<File?> _selectedImages = List.filled(5, null);
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.motor.nama);
    _brandController = TextEditingController(text: widget.motor.brand);
    _deskripsiController = TextEditingController(text: widget.motor.deskripsi);
    _ccController = TextEditingController(text: widget.motor.cc.toString());
    _tahunController = TextEditingController(text: widget.motor.tahun.toString());
    _hargaController = TextEditingController(text: widget.motor.hargaIdr.toString());
    _kilometerController = TextEditingController(text: widget.motor.kilometer.toString());
    _lokasiController = TextEditingController(text: widget.motor.lokasi);
    _instagramController = TextEditingController(text: widget.motor.instagramLink);
    _kontakController = TextEditingController(text: widget.motor.kontakOpsional ?? '');
    _kondisi = widget.motor.kondisi;

    // Load existing photos
    final photos = widget.motor.allPhotos;
    for (int i = 0; i < photos.length && i < 5; i++) {
      _selectedImages[i] = File(photos[i]);
    }
  }

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

  Future<void> _pickImage(int index) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        final imageFile = File(image.path);
        
        // Validate file size (max 5MB)
        final fileSize = await imageFile.length();
        if (fileSize > 5 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ukuran foto maksimal 5MB')),
            );
          }
          return;
        }
        
        if (!mounted) return;
        setState(() {
          _selectedImages[index] = imageFile;
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
    if (!mounted) return;
    setState(() {
      _selectedImages[index] = null;
    });
  }

  Future<String?> _saveImagePermanently(File image, int index) async {
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

    // Check if at least one photo exists
    if (_selectedImages.every((img) => img == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimal tambahkan 1 foto motor')),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Save images permanently
      List<String?> savedPaths = List.filled(5, null);
      for (int i = 0; i < _selectedImages.length; i++) {
        if (_selectedImages[i] != null) {
          savedPaths[i] = await _saveImagePermanently(_selectedImages[i]!, i);
        }
      }

      // Update motor listing
      final updatedMotor = widget.motor.copyWith(
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

      await DatabaseHelper.instance.updateMotorListing(updatedMotor);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Motor berhasil diupdate!'),
          backgroundColor: Color(0xFF2196F3),
        ),
      );

      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error mengupdate motor: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Motor'),
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
                'Foto Motor (minimal 1 foto)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _selectedImages[index] == null
                        ? _pickImage(index)
                        : null,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                            image: _selectedImages[index] != null
                                ? DecorationImage(
                                    image: FileImage(_selectedImages[index]!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _selectedImages[index] == null
                              ? Center(
                                  child: Icon(
                                    Icons.add_photo_alternate,
                                    size: 40,
                                    color: Colors.grey[600],
                                  ),
                                )
                              : null,
                        ),
                        if (_selectedImages[index] != null)
                          Positioned(
                            top: 4,
                            right: 4,
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
                    ),
                  );
                },
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
                initialValue: _kondisi,
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
                        'Update Motor',
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

