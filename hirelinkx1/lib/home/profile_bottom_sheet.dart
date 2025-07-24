import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../main.dart';
import '../../models/profile_model.dart';
import '../../services/supabase_service.dart';

class ProfileBottomSheet extends StatefulWidget {
  final VoidCallback onProfileUpdated;

  const ProfileBottomSheet({super.key, required this.onProfileUpdated});

  @override
  State<ProfileBottomSheet> createState() => _ProfileBottomSheetState();
}

class _ProfileBottomSheetState extends State<ProfileBottomSheet> {
  final SupabaseService _supabaseService = SupabaseService();
  Profile? _profile;
  bool _isLoading = true;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noTelpController = TextEditingController();
  final TextEditingController _emailPesanController = TextEditingController();

  XFile? _selectedImage;
  Uint8List? _webImageBytes;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final data = await _supabaseService.getProfile();
      if (mounted && data != null) {
        _profile = Profile.fromJson(data);
        _usernameController.text = _profile?.username ?? '';
        _titleController.text = _profile?.title ?? '';
        _noTelpController.text = _profile?.noTelp ?? '';
        _emailPesanController.text = _profile?.emailPesan ?? '';
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat profil: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      maxHeight: 300,
    );

    if (imageFile != null) {
      setState(() => _selectedImage = imageFile);
      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        setState(() => _webImageBytes = bytes);
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_usernameController.text.isEmpty) {
      Get.snackbar('Error', 'Username tidak boleh kosong',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);
    String? avatarUrl;

    try {
      if (_selectedImage != null) {
        final fileName =
            '${supabase.auth.currentUser!.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';

        avatarUrl = kIsWeb && _webImageBytes != null
            ? await _supabaseService.uploadImageBytes(
                _webImageBytes!, fileName, 'avatars')
            : await _supabaseService.uploadImage(
                File(_selectedImage!.path), fileName, 'avatars');
      }

      await _supabaseService.updateProfile(
        username: _usernameController.text,
        avatarUrl: avatarUrl ?? _profile?.avatarUrl,
        title: _titleController.text,
        noTelp: _noTelpController.text,
        emailPesan: _emailPesanController.text,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onProfileUpdated();
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperbarui profil: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _titleController.dispose();
    _noTelpController.dispose();
    _emailPesanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? avatarPreview;

    if (_selectedImage != null) {
      avatarPreview = kIsWeb && _webImageBytes != null
          ? MemoryImage(_webImageBytes!)
          : FileImage(File(_selectedImage!.path));
    } else if (_profile?.avatarUrl != null) {
      avatarPreview = NetworkImage(_profile!.avatarUrl!);
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 620),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        const Text(
                          'Edit Profil',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1565C0), // biru
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _pickAvatar,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: avatarPreview,
                        backgroundColor: Colors.grey[300],
                        child: avatarPreview == null
                            ? const Icon(Icons.person,
                                size: 50, color: Colors.black54)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _pickAvatar,
                      icon: const Icon(Icons.camera_alt_outlined,
                          color: Color(0xFF1565C0)),
                      label: const Text(
                        'Ganti Foto Profil',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildInput(_usernameController, 'Username'),
                    const SizedBox(height: 14),
                    _buildInput(_titleController, 'Title'),
                    const SizedBox(height: 14),
                    _buildInput(_noTelpController, 'No. Telepon'),
                    const SizedBox(height: 14),
                    _buildInput(_emailPesanController, 'Email Pesan'),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _updateProfile,
                        icon: const Icon(Icons.save),
                        label: const Text(
                          'Simpan Perubahan',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF1565C0),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF1565C0), width: 1.5),
        ),
      ),
    );
  }
}
