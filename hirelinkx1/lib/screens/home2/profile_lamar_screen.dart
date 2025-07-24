import 'package:flutter/material.dart';

class ProfileLamarScreen extends StatelessWidget {
  final Map<String, dynamic> pelamar;

  const ProfileLamarScreen({super.key, required this.pelamar});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = pelamar['avatar_url'] ??
        'https://ui-avatars.com/api/?name=${pelamar['username'] ?? 'Pelamar'}';
    final username = pelamar['username'] ?? 'Pelamar';
    final title = pelamar['title'] ?? '';
    final noTelp = pelamar['no_telp'] ?? '-';
    final emailPesan = pelamar['email_pesan'] ?? '-';

    final experiences =
        List<Map<String, dynamic>>.from(pelamar['experience'] ?? []);
    final educations =
        List<Map<String, dynamic>>.from(pelamar['education'] ?? []);

    return Scaffold(
      backgroundColor: const Color(0xFF1565C0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, avatarUrl, username, title, noTelp, emailPesan),
                const SizedBox(height: 20),
                _buildSection("Experience", experiences, isEducation: false),
                const SizedBox(height: 20),
                _buildSection("Education", educations, isEducation: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String avatarUrl, String username,
      String title, String noTelp, String emailPesan) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(avatarUrl),
                backgroundColor: Colors.white24,
              ),
              const SizedBox(height: 12),
              Text(
                username,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title.isNotEmpty ? title : '-',
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.verified, color: Colors.white, size: 18),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.phone, size: 16, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(noTelp, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(width: 12),
                  const Icon(Icons.email, size: 16, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(emailPesan,
                      style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String label, List<Map<String, dynamic>> items,
      {required bool isEducation}) {
    if (items.isEmpty) {
      return Text("Belum ada $label",
          style: const TextStyle(color: Colors.white70));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        ...items.map((item) => _infoCard(
              icon: isEducation ? Icons.school : Icons.settings,
              title: isEducation ? item['jurusan'] ?? '-' : item['jabatan'] ?? '-',
              subtitle: isEducation ? item['nama_tempat'] ?? '-' : item['tempat'] ?? '-',
              location: isEducation ? 'Tahun' : item['wilayah'] ?? '-',
              duration: item['waktu'] ?? '-',
            )),
      ],
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String location,
    required String duration,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFECF3FE),
              child: Icon(icon, color: Colors.black)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(color: Colors.black54)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(location, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(duration, style: const TextStyle(color: Colors.black54)),
          ]),
        ],
      ),
    );
  }
}
