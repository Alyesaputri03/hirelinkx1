import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'form_loker_screen.dart';
import 'user2_sidebar.dart';
import 'detail_loker2_screen.dart'; // ✅ import detail screen

class ListLokerScreen extends StatefulWidget {
  const ListLokerScreen({super.key});

  @override
  State<ListLokerScreen> createState() => _ListLokerScreenState();
}

class _ListLokerScreenState extends State<ListLokerScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> _lokerList = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchLoker();
  }

  Future<void> fetchLoker() async {
    setState(() => _loading = true);
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        Get.snackbar('Error', 'User belum login');
        return;
      }

      final data = await supabase
          .from('loker')
          .select('*, kategori(nama)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        _lokerList = data;
        _loading = false;
      });
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> deleteLoker(String id) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Yakin ingin menghapus lowongan ini?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Batal')),
          TextButton(onPressed: () => Get.back(result: true), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await supabase.from('loker').delete().eq('id', id);
        fetchLoker();
        Get.snackbar('Sukses', 'Lowongan berhasil dihapus');
      } catch (e) {
        Get.snackbar('Error', 'Gagal menghapus: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const User2Sidebar(),
      appBar: AppBar(
        title: const Text('Daftar Lowongan Saya'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.to(() => const FormLokerScreen())!
                .then((_) => fetchLoker()),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _lokerList.isEmpty
              ? const Center(child: Text('Belum ada lowongan.'))
              : ListView.builder(
                  itemCount: _lokerList.length,
                  itemBuilder: (context, index) {
                    final loker = _lokerList[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        tileColor: Colors.blue.shade50,
                        leading: loker['gambar'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  loker['gambar'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.image, size: 40),
                        title: Text(
                          loker['jabatan'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${loker['tempat']} • ${loker['kategori']['nama']}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        onTap: () {
                          Get.to(() => DetailLoker2Screen(loker: loker));
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Get.to(() => FormLokerScreen(
                                      lokerData: loker,
                                    ))!.then((_) => fetchLoker());
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteLoker(loker['id'].toString()),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
