import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';
import '../../widgets/dosen/app_bottom_nav_dosen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Admin')),
      body: const Center(
        child: Text(
          'Halaman Admin\n(Coming Soon)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}