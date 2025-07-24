import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'admin_sidebar.dart';

class KategoriScreen extends StatefulWidget {
  const KategoriScreen({super.key});

  @override
  State<KategoriScreen> createState() => _KategoriScreenState();
}

class _KategoriScreenState extends State<KategoriScreen> {
  final _namaController = TextEditingController();
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _kategoriList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchKategori();
  }

  Future<void> fetchKategori() async {
    setState(() => _isLoading = true);
    try {
      final data = await supabase.from('kategori').select();
      setState(() {
        _kategoriList = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> tambahKategori() async {
    final nama = _namaController.text.trim();
    if (nama.isEmpty) return;

    try {
      await supabase.from('kategori').insert({'nama': nama});
      _namaController.clear();
      Get.snackbar('Sukses', 'Kategori ditambahkan',
          backgroundColor: Colors.green, colorText: Colors.white);
      fetchKategori();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menambahkan: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminSidebar(), // Tambah drawer sidebar
      appBar: AppBar(
        title: const Text('Kelola Kategori'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Kategori',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Tambah'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                ),
                onPressed: tambahKategori,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _kategoriList.length,
                      itemBuilder: (context, index) {
                        final kategori = _kategoriList[index];
                        return Card(
                          color: Colors.blue[50],
                          child: ListTile(
                            leading: const Icon(Icons.label, color: Colors.blue),
                            title: Text(
                              kategori['nama'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
