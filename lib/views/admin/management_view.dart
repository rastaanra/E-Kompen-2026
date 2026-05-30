import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_mahasiswa_provider.dart';
import '../../../widgets/admin/app_bottom_nav_admin.dart';
import '../../../utils/nav_admin.dart';
import 'mahasiswa/list_mahasiswa_view.dart';

// TODO: import ini kalau udah dibuat
// import 'dosen/list_dosen_view.dart';
// import 'absensi/list_absensi_view.dart';

class ManagementView extends StatefulWidget {
  const ManagementView({super.key});

  @override
  State<ManagementView> createState() => _ManagementViewState();
}

class _ManagementViewState extends State<ManagementView> {
  int _activeTab = 0; // 0: Mahasiswa, 1: Dosen, 2: Absensi

  static const Color _primaryRed = Color(0xFFB71C1C);
  static const Color _bgColor = Color(0xFFF5F0EE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: _buildAppBar(),
      bottomNavigationBar: AppBottomNavAdmin(
        activeTab: NavTabAdmin.management,
        onTabSelected: (tab) => NavAdmin.handleBottomNav(context, tab, NavTabAdmin.management),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Management Kompen',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pengelolaan data',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 14),
                // Tab buttons
                Row(
                  children: [
                    _buildTabButton(0, 'Mahasiswa'),
                    const SizedBox(width: 10),
                    _buildTabButton(1, 'Dosen'),
                    const SizedBox(width: 10),
                    _buildTabButton(2, 'Absensi'),
                  ],
                ),
              ],
            ),
          ),

          // Content per tab
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _primaryRed,
      elevation: 0,
      title: Row(
        children: [
          const Icon(Icons.school, color: Colors.white, size: 22),
          const SizedBox(width: 8),
          const Text(
            'E-Kompen JTI',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined, color: Colors.white, size: 26),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {
            // TODO: navigasi ke notifikasi
          },
        ),
      ],
    );
  }

  Widget _buildTabButton(int index, String label) {
    final isActive = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? _primaryRed : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? null
              : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_activeTab) {
      case 0:
        return ChangeNotifierProvider(
          create: (_) => AdminMahasiswaProvider(),
          child: const ListMahasiswaView(),
        );
      case 1:
        // TODO: ganti dengan ListDosenView() kalau udah dibuat
        return _buildComingSoon('Dosen');
      case 2:
        // TODO: ganti dengan ListAbsensiView() kalau udah dibuat
        return _buildComingSoon('Absensi');
      default:
        return const SizedBox();
    }
  }

  Widget _buildComingSoon(String label) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction_outlined, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'Halaman $label\nbelum tersedia',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
