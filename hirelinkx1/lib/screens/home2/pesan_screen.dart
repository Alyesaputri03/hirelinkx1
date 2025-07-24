import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'detail_pelamar_screen.dart';

class PesanScreen extends StatefulWidget {
  final String lokerId;
  final Map<String, dynamic> pelamar;

  const PesanScreen({
    super.key,
    required this.lokerId,
    required this.pelamar,
  });

  @override
  State<PesanScreen> createState() => _PesanScreenState();
}

class _PesanScreenState extends State<PesanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _isiController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
  }

  Future<void> kirimNotifikasi() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    try {
      // Ambil kolom 'gambar' dari tabel loker
      final lokerData = await Supabase.instance.client
          .from('loker')
          .select('gambar')
          .eq('id', widget.lokerId)
          .maybeSingle();

      final gambarUrl = lokerData?['gambar'] ?? '';

      // Ambil user_id pelamar
      final userIdPelamar = widget.pelamar['user_id'];

      // Kirim ke tabel notifikasi dengan user_id
      await Supabase.instance.client.from('notifikasi').insert({
        'judul': _judulController.text.trim(),
        'isi': _isiController.text.trim(),
        'gambar_url': gambarUrl,
        'user_id': userIdPelamar, // hanya untuk user terkait
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Notifikasi berhasil dikirim")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DetailPelamarScreen(pelamar: widget.pelamar),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengirim notifikasi: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kirim Notifikasi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _isiController,
                decoration: const InputDecoration(labelText: 'Isi Pesan'),
                maxLines: 4,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Isi pesan tidak boleh kosong' : null,
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: kirimNotifikasi,
                      icon: const Icon(Icons.send),
                      label: const Text("Kirim"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size.fromHeight(50),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
