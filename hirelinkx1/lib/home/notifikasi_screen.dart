import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/app_routes.dart';
import 'menu.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> notifikasiList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifikasi();
  }

  Future<void> fetchNotifikasi() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Ambil tanggal dibuatnya akun user
      final profile = await supabase
          .from('profiles')
          .select('created_at')
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null || profile['created_at'] == null) {
        throw 'Profil tidak ditemukan atau tanggal tidak valid';
      }

      final createdAt = DateTime.parse(profile['created_at']).toLocal();

      // Ambil notifikasi berdasarkan user_id ATAU yang global (user_id null)
      final response = await supabase
          .from('notifikasi')
          .select()
          .or('user_id.eq.${user.id},user_id.is.null')
          .gte('created_at', createdAt.toIso8601String())
          .order('created_at', ascending: false);

      setState(() {
        notifikasiList = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Gagal mengambil notifikasi: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatTanggal(String tanggal) {
    final dateTime = DateTime.parse(tanggal).toLocal();
    return DateFormat('dd MMM yyyy • HH:mm', 'id_ID').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifikasiList.isEmpty
              ? const Center(child: Text('Tidak ada notifikasi.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifikasiList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = notifikasiList[index];
                    return GestureDetector(
                      onTap: () {
                        Get.toNamed(AppRoutes.detailNotifikasi,
                            arguments: item);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F8FF),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            item['gambar_url'] != null
                                ? ClipOval(
                                    child: Image.network(
                                      item['gambar_url'],
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.blue,
                                    child: Icon(Icons.notifications,
                                        color: Colors.white),
                                  ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['judul'] ?? 'Tanpa Judul',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['isi'] ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatTanggal(item['created_at']),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: const Menu(currentIndex: 1),
    );
  }
}
