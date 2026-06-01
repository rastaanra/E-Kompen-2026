import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'views/login/login_screen.dart';
import 'views/mahasiswa/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/auth_provider.dart';
import 'providers/mahasiswa_provider.dart';
import 'providers/pengajuan_provider.dart';
import 'providers/dosen_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/absensi_provider.dart';
import 'providers/notifikasi_provider.dart';
import 'providers/admin_mahasiswa_provider.dart';
import 'theme/app_theme.dart';
import 'views/dosen/home_screen.dart';
import 'views/splash/splash_screen.dart';

// TODO: ganti Placeholder dengan view yang sesuai setelah dibuat
// import 'views/auth/login_view.dart';
// import 'views/mahasiswa/dashboard/dashboard_view.dart';
// import 'views/dosen/dashboard/dashboard_view.dart';
// import 'views/kaprodi/dashboard/dashboard_view.dart';
// import 'views/admin/dashboard/dashboard_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final role = prefs.getString('role');

  runApp(KompenApp(role: role));
}

class KompenApp extends StatelessWidget {
  final String? role;
  const KompenApp({super.key, this.role});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MahasiswaProvider()),
        ChangeNotifierProvider(create: (_) => PengajuanProvider()),
        ChangeNotifierProvider(create: (_) => DosenProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => AbsensiProvider()),
        ChangeNotifierProvider(create: (_) => NotifikasiProvider()),
        ChangeNotifierProvider(create: (_) => AdminMahasiswaProvider()),
      ],
      child: MaterialApp(
        title: 'E-Kompen JTI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: _getHomePage(),
      ),
    );
  }

  Widget _getHomePage() {
    if (role == 'mahasiswa') {
      return const Placeholder(); // ganti nanti: DashboardMahasiswaView()
    } else if (role == 'dosen') {
      return const Placeholder(); // ganti nanti: DashboardDosenView()
    } else if (role == 'kaprodi') {
      return const Placeholder(); // ganti nanti: DashboardKaprodiView()
    } else if (role == 'admin') {
      return const Placeholder(); // ganti nanti: DashboardAdminView()
    }
    return const Placeholder(); // ganti nanti: LoginView()
  }
}