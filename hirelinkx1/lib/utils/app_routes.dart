import 'package:get/get.dart';

// Screens: Umum
import '../../screens/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/home/notifikasi_screen.dart'; // ✅ Notifikasi utama
import '../../screens/home/detail_notifikasi_screen.dart'; // ✅ Detail notifikasi
import '../../screens/home/riwayat_screen.dart';

// Screens: Admin
import '../../screens/admin/pengguna_screen.dart';
import '../../screens/admin/kategori_screen.dart';
import '../../screens/admin/list_notifikasi_screen.dart';
import '../../screens/admin/form_notifikasi_screen.dart';

// Screens: Lowongan & Pelamar
import '../../screens/home2/list_loker_screen.dart';
import '../../screens/home2/form_loker_screen.dart';
import '../../screens/home2/saya_pelamar_screen.dart';

// Screens: Profile
import '../../screens/home/profile_screen.dart';
import '../../screens/home/add_education_screen.dart';
import '../../screens/home/add_experience_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String pengguna = '/pengguna';
  static const String kategori = '/kategori';
  static const String notifikasi = '/notifikasi'; // ✅ Ganti dari 'pesan'
  static const String detailNotifikasi = '/detail-notifikasi'; // ✅ Tambahan
  static const String riwayat = '/riwayat';
  static const String listLoker = '/list-loker';
  static const String formLoker = '/form-loker';
  static const String listRemote = '/list-remote';
  static const String formRemote = '/form-remote';
  static const String pelamar = '/pelamar';
  static const String profile = '/profile';
  static const String addEducation = '/add-education';
  static const String addExperience = '/add-experience';
  static const String listNotifikasi = '/list-notifikasi';
  static const String formNotifikasi = '/form-notifikasi';

  // Route definitions
  static final routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: register, page: () => const RegisterScreen()),
    GetPage(
      name: home,
      page: () => HomeScreen(
        onProfileUpdated: () {
          print('Profil telah diperbarui!');
        },
      ),
    ),
    GetPage(name: pengguna, page: () => const PenggunaScreen()),
    GetPage(name: kategori, page: () => const KategoriScreen()),
    GetPage(name: notifikasi, page: () => const NotifikasiScreen()), // ✅ Sudah diganti
    GetPage(name: detailNotifikasi, page: () => const DetailNotifikasiScreen()), // ✅ Baru
    GetPage(name: riwayat, page: () => const RiwayatScreen()),
    GetPage(name: listLoker, page: () => const ListLokerScreen()),
    GetPage(name: formLoker, page: () => const FormLokerScreen()),
    GetPage(name: pelamar, page: () => const SayaPelamarScreen()),
    GetPage(name: profile, page: () => const ProfileScreen()),
    GetPage(name: addEducation, page: () => const AddEducationScreen()),
    GetPage(name: addExperience, page: () => const AddExperienceScreen()),
    GetPage(name: listNotifikasi, page: () => const ListNotifikasiScreen()),
    GetPage(name: formNotifikasi, page: () => const FormNotifikasiScreen()),
  ];
}
