import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'form_notifikasi_screen.dart';
import 'admin_sidebar.dart'; // Pastikan file ini tersedia

class ListNotifikasiScreen extends StatefulWidget {
  const ListNotifikasiScreen({super.key});

  @override
  State<ListNotifikasiScreen> createState() => _ListNotifikasiScreenState();
}

class _ListNotifikasiScreenState extends State<ListNotifikasiScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> notifikasiList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifikasi();
  }

  Future<void> fetchNotifikasi() async {
    setState(() => isLoading = true);
    final response = await supabase
        .from('notifikasi')
        .select()
        .order('created_at', ascending: false);
    setState(() {
      notifikasiList = List<Map<String, dynamic>>.from(response);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AdminSidebar(), // Sidebar di kiri
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white), // Icon drawer jadi putih
        title: const Text(
          'Daftar Notifikasi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifikasiList.isEmpty
              ? const Center(child: Text('Belum ada notifikasi.'))
              : ListView.builder(
                  itemCount: notifikasiList.length,
                  itemBuilder: (context, index) {
                    final notif = notifikasiList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      elevation: 3,
                      child: ListTile(
                        title: Text(
                          notif['judul'] ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent),
                        ),
                        subtitle: Text(
                          notif['isi'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          _formatTanggal(notif['created_at']),
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(notif['judul'] ?? ''),
                              content: Text(notif['isi'] ?? ''),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Tutup'),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormNotifikasiScreen()),
          );
          if (result == true) {
            await fetchNotifikasi(); // Refresh saat kembali
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Tambah Notifikasi',
      ),
    );
  }

  String _formatTanggal(String isoDate) {
    final dateTime = DateTime.parse(isoDate);
    final bulan = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${dateTime.day} ${bulan[dateTime.month - 1]} ${dateTime.year}';
  }
}
