import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './admin_sidebar.dart';

class PenggunaScreen extends StatefulWidget {
  const PenggunaScreen({super.key});

  @override
  State<PenggunaScreen> createState() => _PenggunaScreenState();
}

class _PenggunaScreenState extends State<PenggunaScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> _pengguna = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPengguna();
  }

  Future<void> fetchPengguna() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase.from('profiles').select();
      setState(() {
        _pengguna = response;
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data pengguna: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('Daftar Pengguna'),
        backgroundColor: Colors.blue,
      ),
      drawer: const AdminSidebar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pengguna.isEmpty
              ? const Center(child: Text('Tidak ada pengguna ditemukan.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _pengguna.length,
                  itemBuilder: (context, index) {
                    final user = _pengguna[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(
                          user['username'] ?? 'Tanpa Nama',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user['email'] ?? '-'),
                            if (user['phone'] != null && user['phone'].toString().isNotEmpty)
                              Text("Telp: ${user['phone']}"),
                          ],
                        ),
                        tileColor: Colors.white,
                      ),
                    );
                  },
                ),
    );
  }
}
