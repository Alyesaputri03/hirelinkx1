import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../home2/profile_lamar_screen.dart';

class DetailRiwayatScreen extends StatefulWidget {
  const DetailRiwayatScreen({super.key});

  @override
  State<DetailRiwayatScreen> createState() => _DetailRiwayatScreenState();
}

class _DetailRiwayatScreenState extends State<DetailRiwayatScreen> {
  Map<String, dynamic>? pelamar;
  String tempat = '';
  String jabatan = '';
  String status = '';
  bool isLoading = true;
  bool initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      pelamar = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      status = pelamar?['status']?.toString().toLowerCase().trim() ?? 'menunggu';
      fetchLokerInfo();
      initialized = true;
    }
  }

  Future<void> fetchLokerInfo() async {
    if (pelamar == null) return;
    final response = await Supabase.instance.client
        .from('loker')
        .select('tempat, jabatan')
        .eq('id', pelamar!['loker_id'])
        .maybeSingle();

    if (response != null) {
      setState(() {
        tempat = response['tempat'] ?? '';
        jabatan = response['jabatan'] ?? '';
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Widget buildFileCard(String url) {
    final fileName = Uri.parse(url).pathSegments.last;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.blue.shade50,
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
        title: Text(fileName, style: const TextStyle(fontWeight: FontWeight.w600)),
        onTap: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
      ),
    );
  }

  Widget buildFileSection(String title, List<dynamic>? files) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        const SizedBox(height: 8),
        if (files == null || files.isEmpty)
          const Text("Tidak ada file.")
        else
          ...files.map((f) => buildFileCard(f.toString())).toList(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget buildTextRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (pelamar == null) {
      return const Scaffold(
        body: Center(child: Text("Data tidak ditemukan.")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FF),
      appBar: AppBar(
        title: const Text("Detail Riwayat"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  buildTextRow("Nama", pelamar!['nama'] ?? '-'),
                  buildTextRow("Tanggal Lahir", pelamar!['tanggal_lahir']?.toString().split('T').first ?? '-'),
                  buildTextRow("Tempat", tempat),
                  buildTextRow("Jabatan", jabatan),
                  buildTextRow("Status", status.toUpperCase()),
                  const SizedBox(height: 16),

                  buildFileSection("Portofolio", pelamar!['portofolio']),
                  buildFileSection("Resume", pelamar!['resume']),

                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfileLamarScreen(pelamar: pelamar!),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person, color: Colors.white),
                    label: const Text(
                      "Lihat Profil",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      minimumSize: const Size.fromHeight(56),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      "Status: ${status.toUpperCase()}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: status == 'diterima'
                            ? Colors.green
                            : status == 'ditolak'
                                ? Colors.red
                                : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
