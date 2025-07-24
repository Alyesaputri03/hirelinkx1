import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_routes.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.teal),
            child: Center(
              child: Text(
                'Admin Panel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Pengguna'),
            onTap: () {
              Navigator.pop(context);
              Get.toNamed(AppRoutes.pengguna);
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifikasi'),
            onTap: () {
              Navigator.pop(context);
              Get.toNamed(AppRoutes.listNotifikasi);
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Kategori'),
            onTap: () {
              Navigator.pop(context);
              Get.toNamed(AppRoutes.kategori);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              Get.offAllNamed(AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }
}
