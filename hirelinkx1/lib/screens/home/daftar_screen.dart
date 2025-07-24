import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dotted_border/dotted_border.dart';

import 'riwayat_screen.dart';

class DaftarScreen extends StatefulWidget {
  final String lokerId;
  final String tempat;
  final String jabatan;

  const DaftarScreen({
    super.key,
    required this.lokerId,
    required this.tempat,
    required this.jabatan,
  });

  @override
  State<DaftarScreen> createState() => _DaftarScreenState();
}

class _DaftarScreenState extends State<DaftarScreen> {
  final namaController = TextEditingController();
  DateTime? tanggalLahir;
  List<PlatformFile> portofolioFiles = [];
  List<PlatformFile> resumeFiles = [];
  bool isLoading = false;

  Future<void> pickFiles(bool isPortofolio) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true, withData: true);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        if (isPortofolio) {
          portofolioFiles = result.files;
        } else {
          resumeFiles = result.files;
        }
      });
    }
  }

  Widget buildFileItem(PlatformFile file) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.indigo.shade50,
      elevation: 1,
      child: ListTile(
        leading: const Icon(Icons.insert_drive_file, color: Colors.indigo),
        title: Text(file.name, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text("${(file.size / 1024).toStringAsFixed(0)} KB"),
      ),
    );
  }

  Widget buildDashedUploadBox(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(16),
        dashPattern: const [8, 4],
        color: const Color.fromARGB(255, 53, 137, 255),
        strokeWidth: 1.5,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32),
          alignment: Alignment.center,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.indigo,
            ),
          ),
        ),
      ),
    );
  }

  Future<String> uploadFileToStorage(PlatformFile file, String folder) async {
    final supabase = Supabase.instance.client;
    final fileName = '${folder}_${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    final filePath = '$folder/$fileName';
    final bytes = file.bytes ?? await File(file.path!).readAsBytes();

    await supabase.storage
        .from('pelamar')
        .uploadBinary(filePath, bytes, fileOptions: const FileOptions(upsert: true));

    return supabase.storage.from('pelamar').getPublicUrl(filePath);
  }

  Future<void> submit() async {
    if (namaController.text.isEmpty ||
        tanggalLahir == null ||
        portofolioFiles.isEmpty ||
        resumeFiles.isEmpty) {
      Get.snackbar('Error', 'Lengkapi semua data');
      return;
    }

    setState(() => isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("User belum login");

      final profileRes = await supabase
          .from('profiles')
          .select('username, avatar_url, title, no_telp, email_pesan')
          .eq('id', user.id)
          .single();

      final avatarUrl = profileRes['avatar_url'] as String?;
      final username = profileRes['username'] as String?;
      final title = profileRes['title'] as String?;
      final noTelp = profileRes['no_telp'] as String?;
      final emailPesan = profileRes['email_pesan'] as String?;

      final expRes = await supabase
          .from('experience')
          .select('jabatan, tempat, wilayah, waktu')
          .eq('profile_id', user.id);
      final experiences = (expRes as List<dynamic>)
          .map((e) => {
                'jabatan': e['jabatan'],
                'tempat': e['tempat'],
                'wilayah': e['wilayah'],
                'waktu': e['waktu'],
              })
          .toList();

      final eduRes = await supabase
          .from('education')
          .select('jurusan, nama_tempat, waktu')
          .eq('profile_id', user.id);
      final educations = (eduRes as List<dynamic>)
          .map((e) => {
                'jurusan': e['jurusan'],
                'nama_tempat': e['nama_tempat'],
                'waktu': e['waktu'],
              })
          .toList();

      final portofolioUrls = <String>[];
      for (final file in portofolioFiles) {
        portofolioUrls.add(await uploadFileToStorage(file, 'portofolio'));
      }

      final resumeUrls = <String>[];
      for (final file in resumeFiles) {
        resumeUrls.add(await uploadFileToStorage(file, 'resume'));
      }

      await supabase.from('pelamar').insert({
        'user_id': user.id,
        'loker_id': widget.lokerId,
        'nama': namaController.text,
        'tanggal_lahir': tanggalLahir!.toIso8601String(),
        'portofolio': portofolioUrls,
        'resume': resumeUrls,
        'status': 'menunggu',
        'created_at': DateTime.now().toIso8601String(),
        'avatar_url': avatarUrl,
        'username': username,
        'experience': experiences,
        'education': educations,
        'title': title,
        'no_telp': noTelp,
        'email_pesan': emailPesan,
      });

      Get.off(() => const RiwayatScreen());
      Get.snackbar('Sukses', 'Pendaftaran berhasil!');
    } catch (e) {
      debugPrint(e.toString());
      Get.snackbar('Gagal', 'Terjadi kesalahan saat mendaftar.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Daftar Lowongan"),
        backgroundColor: const Color.fromARGB(255, 75, 129, 255),
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
                onPressed: submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 62, 133, 255),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Daftar Sekarang',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: namaController,
                      decoration: const InputDecoration(
                        labelText: "Nama Lengkap",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      tileColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      title: Text(
                        tanggalLahir == null
                            ? "Pilih Tanggal Lahir"
                            : "Tanggal Lahir: ${tanggalLahir!.toLocal().toString().split(' ')[0]}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime(2000),
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => tanggalLahir = picked);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Upload Portofolio
            portofolioFiles.isEmpty
                ? buildDashedUploadBox('Add Portofolio', () => pickFiles(true))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => pickFiles(true),
                        icon: const Icon(Icons.upload_file),
                        label: Text('Upload Portofolio (${portofolioFiles.length})'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade100,
                          foregroundColor: const Color.fromARGB(255, 70, 113, 255),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...portofolioFiles.map(buildFileItem),
                    ],
                  ),
            const SizedBox(height: 20),

            // Upload Resume
            resumeFiles.isEmpty
                ? buildDashedUploadBox('Add Resume', () => pickFiles(false))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => pickFiles(false),
                        icon: const Icon(Icons.upload_file),
                        label: Text('Upload Resume (${resumeFiles.length})'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade100,
                          foregroundColor: const Color.fromARGB(255, 73, 131, 255),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...resumeFiles.map(buildFileItem),
                    ],
                  ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
