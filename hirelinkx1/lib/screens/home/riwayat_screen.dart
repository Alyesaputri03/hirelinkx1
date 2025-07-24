import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';

import 'menu.dart'; // Pastikan path ini sesuai
import 'detail_riwayat_screen.dart'; // Import halaman detail

class RiwayatScreen extends StatelessWidget {
  const RiwayatScreen({super.key});

  Future<List<Map<String, dynamic>>> fetchRiwayat() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return [];

    return await Supabase.instance.client
        .from('pelamar')
        .select('*, loker: loker_id(jabatan, tempat)')
        .eq('user_id', user.id);
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'diterima':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'diterima':
        return Icons.check_circle;
      case 'ditolak':
        return Icons.cancel;
      default:
        return Icons.hourglass_top;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text("Riwayat Pendaftaran"),
      ),
      bottomNavigationBar: const Menu(currentIndex: 2),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchRiwayat(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada riwayat pendaftaran."));
          }

          final data = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (_, i) {
              final item = data[i];
              final loker = item['loker'] ?? {};
              final status = item['status'] ?? 'menunggu';

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  onTap: () {
                    Get.to(() => const DetailRiwayatScreen(), arguments: item);
                  },
                  leading: CircleAvatar(
                    backgroundColor: getStatusColor(status),
                    child: Icon(getStatusIcon(status), color: Colors.white),
                  ),
                  title: Text(
                    loker['jabatan'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(loker['tempat'] ?? ''),
                  trailing: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: getStatusColor(status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
