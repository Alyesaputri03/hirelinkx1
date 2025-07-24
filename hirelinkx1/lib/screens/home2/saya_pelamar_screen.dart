import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'detail_pelamar_screen.dart';
import 'user2_sidebar.dart';

class SayaPelamarScreen extends StatelessWidget {
  const SayaPelamarScreen({super.key});

  Future<List<Map<String, dynamic>>> fetchPelamar() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return [];

    final data = await Supabase.instance.client
        .from('pelamar')
        .select('*, loker: loker_id(id, jabatan, tempat, user_id)')
        .order('created_at', ascending: false);

    final filtered = data.where((item) {
      final loker = item['loker'];
      return loker != null && loker['user_id'] == user.id;
    }).toList();

    return List<Map<String, dynamic>>.from(filtered);
  }

  String formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const User2Sidebar(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Pelamar Masuk"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchPelamar(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Gagal memuat data."));
          }

          final data = snapshot.data!;
          if (data.isEmpty) {
            return const Center(child: Text("Belum ada pelamar."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: data.length,
            itemBuilder: (_, i) {
              final item = data[i];
              final status = item['status'] ?? 'Belum diproses';

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  tileColor: Colors.white,
                  title: Text(
                    item['nama'] ?? 'Tanpa Nama',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text("${item['loker']['jabatan']} - ${item['loker']['tempat']}"),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(formatDate(item['created_at'])),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(color: Colors.blue, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailPelamarScreen(pelamar: item),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
