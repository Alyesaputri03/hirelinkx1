import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_routes.dart'; // ← pastikan path benar

class Menu extends StatelessWidget {
  final int currentIndex;

  const Menu({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            if (currentIndex != 0) Get.offAllNamed(AppRoutes.home);
            break;
          case 1:
            if (currentIndex != 1) Get.offAllNamed(AppRoutes.notifikasi);
            break;
          case 2:
            if (currentIndex != 2) Get.offAllNamed(AppRoutes.riwayat);
            break;
        }
      },
      selectedItemColor: const Color.fromARGB(255, 28, 157, 255),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications), // ✅ Ganti dari Icons.message
          label: 'Notifikasi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Riwayat',
        ),
      ],
    );
  }
}
