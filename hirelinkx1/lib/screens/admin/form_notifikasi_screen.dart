import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FormNotifikasiScreen extends StatefulWidget {
  const FormNotifikasiScreen({super.key});

  @override
  State<FormNotifikasiScreen> createState() => _FormNotifikasiScreenState();
}

class _FormNotifikasiScreenState extends State<FormNotifikasiScreen> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _isiController = TextEditingController();
  final supabase = Supabase.instance.client;
  bool isSaving = false;

  Future<void> _simpan() async {
    final judul = _judulController.text.trim();
    final isi = _isiController.text.trim();

    if (judul.isEmpty || isi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul dan isi wajib diisi.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      await supabase.from('notifikasi').insert({
        'judul': judul,
        'isi': isi,
        'gambar_url':
            'https://itrpmenjinbmvokaifqi.supabase.co/storage/v1/object/public/loker-images/loker/1752825138126.jpg',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notifikasi berhasil disimpan.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // untuk refresh list
    } catch (e) {
      debugPrint('Gagal simpan notifikasi: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyimpan notifikasi.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FB),
      appBar: AppBar(
        title: const Text('Tambah Notifikasi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _judulController,
              decoration: InputDecoration(
                labelText: 'Judul',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _isiController,
              decoration: InputDecoration(
                labelText: 'Isi Notifikasi',
                alignLabelWithHint: true,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : _simpan,
                icon: const Icon(Icons.save),
                label: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Simpan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
