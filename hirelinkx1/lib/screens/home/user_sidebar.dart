import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/supabase_service.dart';
import '../../utils/app_routes.dart';

class UserSidebar extends StatefulWidget {
  final VoidCallback onProfileUpdated;

  const UserSidebar({
    super.key,
    required this.onProfileUpdated,
  });

  @override
  State<UserSidebar> createState() => _UserSidebarState();
}

class _UserSidebarState extends State<UserSidebar> {
  final SupabaseService _supabaseService = SupabaseService();
  bool isLoading = true;
  String? avatarUrl;
  String? username;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => isLoading = true);
    try {
      final data = await _supabaseService.getProfile();
      setState(() {
        avatarUrl = data?['avatar_url'];
        username = data?['username'];
      });
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat profil: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Drawer(
        child: Container(
          color: const Color.fromARGB(255, 55, 128, 255),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                isLoading
                    ? const CircularProgressIndicator(color: Color.fromARGB(255, 255, 255, 255))
                    : Column(
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                                ? NetworkImage(avatarUrl!)
                                : const NetworkImage('https://via.placeholder.com/150'),
                            backgroundColor: Colors.grey[300],
                            child: (avatarUrl == null || avatarUrl!.isEmpty)
                                ? const Icon(Icons.person, size: 40, color: Colors.grey)
                                : null,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Selamat Datang',
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            username ?? 'Pengguna',
                            style: const TextStyle(
                              color: Color.fromARGB(221, 255, 255, 255),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                const SizedBox(height: 12),

                // Tombol Edit Profil
                TextButton.icon(
                  onPressed: () {
                    Get.toNamed(AppRoutes.profile)?.then((_) {
                      widget.onProfileUpdated();
                      _loadProfile();
                    });
                  },
                  icon: const Icon(Icons.edit, color: Color.fromARGB(255, 255, 255, 255), size: 20),
                  label: const Text(
                    'Edit Profil',
                    style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                  ),
                ),
                const Divider(
                  color: Color.fromARGB(255, 255, 255, 255),
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                ),

                const SizedBox(height: 12),

                // Menu Buat Lowongan
                ListTile(
                  leading: const Icon(Icons.work_outline, color: Color.fromARGB(255, 255, 255, 255)),
                  title: const Text(
                    'Buat Lowongan',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Get.toNamed(AppRoutes.listLoker);
                  },
                ),

                const Spacer(),

                // Tombol Logout
                ListTile(
                  leading: const Icon(Icons.logout, color: Color.fromARGB(255, 255, 255, 255)),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () async {
                    await Supabase.instance.client.auth.signOut();
                    Get.offAllNamed(AppRoutes.splash);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
