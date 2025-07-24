import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home/home_screen.dart';
import 'list_loker_screen.dart';
import 'saya_pelamar_screen.dart';


class User2Sidebar extends StatelessWidget {
  const User2Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Image.network(
                      'https://itrpmenjinbmvokaifqi.supabase.co/storage/v1/object/public/loker-images/loker/1752817667421.jpg',
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Menu Loker',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.work, color: Colors.blue),
              title: const Text('Lowongan', style: TextStyle(color: Colors.blue)),
              onTap: () {
                Get.to(() => const ListLokerScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Colors.blue),
              title: const Text('Pelamar', style: TextStyle(color: Colors.blue)),
              onTap: () {
                Get.to(() => const SayaPelamarScreen());
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.home, color: Colors.blue),
              title: const Text('Kembali', style: TextStyle(color: Colors.blue)),
              onTap: () {
                Get.offAll(() => HomeScreen(
                      onProfileUpdated: () {},
                    ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
