import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'profile_lamar_screen.dart';
import 'saya_pelamar_screen.dart';
import 'pesan_screen.dart';

class DetailPelamarScreen extends StatefulWidget {
  final Map<String, dynamic> pelamar;

  const DetailPelamarScreen({super.key, required this.pelamar});

  @override
  State<DetailPelamarScreen> createState() => _DetailPelamarScreenState();
}

class _DetailPelamarScreenState extends State<DetailPelamarScreen> {
  String tempat = '';
  String jabatan = '';
  String status = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final rawStatus = widget.pelamar['status'] ?? 'menunggu';
    status = rawStatus.toString().toLowerCase().trim();
    fetchLokerInfo();
  }

  Future<void> fetchLokerInfo() async {
    final response = await Supabase.instance.client
        .from('loker')
        .select('tempat, jabatan')
        .eq('id', widget.pelamar['loker_id'])
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

  Future<void> updateStatus(String newStatus) async {
    setState(() => isLoading = true);

    await Supabase.instance.client
        .from('pelamar')
        .update({'status': newStatus})
        .eq('id', widget.pelamar['id']);

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SayaPelamarScreen()),
      );
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
          ...files.map((f) => buildFileCard(f.toString())),
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
    final pelamar = widget.pelamar;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FF),
      appBar: AppBar(
        title: const Text("Data Pelamar"),
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
                  buildTextRow("Nama", pelamar['nama']),
                  buildTextRow("Tanggal Lahir", pelamar['tanggal_lahir'].toString().split('T').first),
                  buildTextRow("Tempat", tempat),
                  buildTextRow("Jabatan", jabatan),
                  buildTextRow("Status", status.toUpperCase()),
                  const SizedBox(height: 16),

                  buildFileSection("Portofolio", pelamar['portofolio']),
                  buildFileSection("Resume", pelamar['resume']),

                  const SizedBox(height: 8),

                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfileLamarScreen(pelamar: pelamar),
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

                  const SizedBox(height: 12),

                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PesanScreen(
                            lokerId: pelamar['loker_id'],
                            pelamar: pelamar,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.message, color: Colors.white),
                    label: const Text(
                      "Kirim Pesan",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: const Size.fromHeight(56),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (status == 'menunggu')
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => updateStatus('diterima'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text("Terima"),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => updateStatus('ditolak'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text("Tolak"),
                          ),
                        ),
                      ],
                    )
                  else
                    Center(
                      child: Text(
                        "Status: ${status.toUpperCase()}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: status == 'diterima' ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
