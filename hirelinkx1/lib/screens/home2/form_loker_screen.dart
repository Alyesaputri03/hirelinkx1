// Tambahan import tidak perlu (sudah lengkap)
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../main.dart';
import '../../utils/app_routes.dart';

class FormLokerScreen extends StatefulWidget {
  final Map<String, dynamic>? lokerData;
  const FormLokerScreen({super.key, this.lokerData});

  @override
  State<FormLokerScreen> createState() => _FormLokerScreenState();
}

class _FormLokerScreenState extends State<FormLokerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jabatanController = TextEditingController();
  final _tempatController = TextEditingController();
  final _detailController = TextEditingController();
  final _gajiController = TextEditingController();
  final _wilayahController = TextEditingController();
  final _deskripsiController = TextEditingController();

  String? _selectedKategoriId;
  String? _tipe; // Tambahan tipe (onsite/remote)
  List<Map<String, dynamic>> _kategoriList = [];

  File? _imageFile;
  Uint8List? _webImage;
  String? _imageName;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    fetchKategori();

    if (widget.lokerData != null) {
      final loker = widget.lokerData!;
      _jabatanController.text = loker['jabatan'] ?? '';
      _tempatController.text = loker['tempat'] ?? '';
      _detailController.text = loker['detail'] ?? '';
      _gajiController.text = loker['gaji'] ?? '';
      _wilayahController.text = loker['wilayah'] ?? '';
      _deskripsiController.text = loker['deskripsi'] ?? '';
      _selectedKategoriId = loker['kategori_id']?.toString();
      _tipe = loker['tipe']; // Set tipe dari data
      _existingImageUrl = loker['gambar'];
    }
  }

  Future<void> fetchKategori() async {
    final data = await supabase.from('kategori').select();
    setState(() {
      _kategoriList = List<Map<String, dynamic>>.from(data);
    });
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final fileName =
          'loker/${DateTime.now().millisecondsSinceEpoch}.${picked.name.split('.').last}';
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _webImage = bytes;
          _imageName = fileName;
        });
      } else {
        setState(() {
          _imageFile = File(picked.path);
          _imageName = fileName;
        });
      }
    }
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'User belum login');
        return;
      }

      String? imageUrl = _existingImageUrl;

      if (_webImage != null) {
        await supabase.storage.from('loker-images').uploadBinary(_imageName!, _webImage!);
        imageUrl = supabase.storage.from('loker-images').getPublicUrl(_imageName!);
      } else if (_imageFile != null) {
        await supabase.storage.from('loker-images').upload(_imageName!, _imageFile!);
        imageUrl = supabase.storage.from('loker-images').getPublicUrl(_imageName!);
      }

      final payload = {
        'user_id': user.id,
        'gambar': imageUrl,
        'jabatan': _jabatanController.text,
        'tempat': _tempatController.text,
        'kategori_id': _selectedKategoriId,
        'detail': _detailController.text,
        'gaji': _gajiController.text,
        'wilayah': _wilayahController.text,
        'deskripsi': _deskripsiController.text,
        'tipe': _tipe,
      };

      if (widget.lokerData != null) {
        await supabase.from('loker').update(payload).eq('id', widget.lokerData!['id']);
        Get.snackbar('Sukses', 'Lowongan berhasil diperbarui');
      } else {
        await supabase.from('loker').insert(payload);
        Get.snackbar('Sukses', 'Lowongan berhasil ditambahkan');
      }

      Get.offNamed(AppRoutes.listLoker);
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Widget _buildImagePreview() {
    if (_webImage != null) {
      return Image.memory(_webImage!, height: 150, fit: BoxFit.cover);
    } else if (_imageFile != null) {
      return Image.file(_imageFile!, height: 150, fit: BoxFit.cover);
    } else if (_existingImageUrl != null) {
      return Image.network(_existingImageUrl!, height: 150, fit: BoxFit.cover);
    } else {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey),
        ),
        child: const Center(
          child: Icon(Icons.image, size: 50, color: Colors.grey),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lokerData != null ? 'Edit Loker' : 'Form Loker'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildImagePreview(),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Pilih Gambar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jabatanController,
                decoration: const InputDecoration(
                  labelText: 'Jabatan',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tempatController,
                decoration: const InputDecoration(
                  labelText: 'Tempat',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _tipe,
                decoration: const InputDecoration(
                  labelText: 'Tipe Pekerjaan',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'onsite', child: Text('On-site Job')),
                  DropdownMenuItem(value: 'remote', child: Text('Remote Job')),
                ],
                onChanged: (value) => setState(() => _tipe = value),
                validator: (value) => value == null ? 'Pilih tipe pekerjaan' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField(
                value: _selectedKategoriId,
                items: _kategoriList.map((kategori) {
                  return DropdownMenuItem(
                    value: kategori['id'].toString(),
                    child: Text(kategori['nama']),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedKategoriId = value.toString()),
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null ? 'Pilih kategori' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _detailController,
                decoration: const InputDecoration(
                  labelText: 'Detail',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _gajiController,
                decoration: const InputDecoration(
                  labelText: 'Gaji',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _wilayahController,
                decoration: const InputDecoration(
                  labelText: 'Wilayah',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: submit,
                child: const Text('Simpan'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
