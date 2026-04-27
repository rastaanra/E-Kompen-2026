import 'package:flutter/material.dart';
import 'login/login_screen.dart';
import '../widgets/app_header.dart';
import '../widgets/app_bottom_nav.dart';
import '../utils/nav_mahasiswa.dart';
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color _primaryRed = Color(0xFFB71C1C);
  static const Color _backgroundCream = Color(0xFFF5EFE6);
  static const Color _textDark = Color(0xFF2D2D2D);
  static const Color _textGrey = Color(0xFF9E9E9E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryRed,
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: _backgroundCream,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              child: ScrollConfiguration(
                behavior: const ScrollBehavior().copyWith(overscroll: false),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileCard(),
                    const SizedBox(height: 20),
                    _buildSectionLabel('Informasi Akademik'),
                    const SizedBox(height: 10),
                    _buildInfoCard(items: [
                      _InfoItem(
                        icon: Icons.school_outlined,
                        label: 'Program Studi',
                        value: 'Sistem Informasi Bisnis',
                      ),
                      _InfoItem(
                        icon: Icons.menu_book_outlined,
                        label: 'Semester',
                        value: '4 (Genap 2025/2026)',
                      ),
                      _InfoItem(
                        icon: Icons.person_outline,
                        label: 'Dosen Pembimbing Akademik',
                        value: 'Luqman Affandi, S.Kom., MMSI',
                        isLast: true,
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _buildSectionLabel('Kontak'),
                    const SizedBox(height: 10),
                    _buildInfoCard(items: [
                      _InfoItem(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: 'sally.savista@student.jti.ac.id',
                        valueColor: _primaryRed,
                      ),
                      _InfoItem(
                        icon: Icons.phone_outlined,
                        label: 'No. Telepon',
                        value: '+62 812-3456-7890',
                        isLast: true,
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _buildSectionLabel('Pengaturan'),
                    const SizedBox(height: 10),
                    _buildSettingsCard(context),
                    const SizedBox(height: 24),
                    _buildLogoutButton(context),
                    const SizedBox(height: 8),
                  ],
                ),
                ),
              ),
            ),
          ),
          AppBottomNav(
            activeTab: NavTab.profil,
            onTabSelected: (tab) =>
                NavMahasiswa.handleBottomNav(context, tab, NavTab.profil),
          ),
        ],
      ),
    );
  }


  // ── Kartu profil utama
  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar lingkaran merah
          Container(
            width: 66,
            height: 66,
            decoration: const BoxDecoration(
              color: _primaryRed,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'SS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Nama + NIM + badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sally Savista',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  '244107060064',
                  style: TextStyle(
                    fontSize: 13,
                    color: _textGrey,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE5E5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: _primaryRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'Mahasiswa Aktif',
                        style: TextStyle(
                          fontSize: 11,
                          color: _primaryRed,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Tombol edit
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE5E5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.edit_outlined,
              color: _primaryRed,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: _textGrey,
        letterSpacing: 0.8,
      ),
    );
  }

  // ── Card info (akademik & kontak)
  Widget _buildInfoCard({required List<_InfoItem> items}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE5E5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, color: _primaryRed, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: const TextStyle(
                              fontSize: 12,
                              color: _textGrey,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.value,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: item.valueColor ?? _textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  thickness: 0.5,
                  color: Color(0xFFF0EBE0),
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }),
      ),
    );
  }

  // ── Card pengaturan
  Widget _buildSettingsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.lock_outline,
            label: 'Ubah Password',
            trailing: const Icon(
              Icons.chevron_right,
              color: _textGrey,
              size: 20,
            ),
          ),
          const Divider(
            height: 1,
            thickness: 0.5,
            color: Color(0xFFF0EBE0),
            indent: 16,
            endIndent: 16,
          ),
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            label: 'Notifikasi',
            trailing: _buildToggle(true),
          ),
          const Divider(
            height: 1,
            thickness: 0.5,
            color: Color(0xFFF0EBE0),
            indent: 16,
            endIndent: 16,
          ),
          _buildSettingsTile(
            icon: Icons.help_outline,
            label: 'Bantuan & FAQ',
            trailing: const Icon(
              Icons.chevron_right,
              color: _textGrey,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String label,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE5E5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _primaryRed, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _textDark,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildToggle(bool isOn) {
    return Container(
      width: 38,
      height: 22,
      decoration: BoxDecoration(
        color: isOn ? _primaryRed : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Align(
        alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 18,
          height: 18,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  // Tombol logout 
  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Keluar dari Akun',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: _textDark,
                ),
              ),
              content: const Text(
                'Yakin keluar dari akun?',
                style: TextStyle(fontSize: 14, color: _textGrey),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _primaryRed),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                  ),
                  child: const Text(
                    'Tidak',
                    style: TextStyle(
                      color: _primaryRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Ya',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
          if (confirm == true && context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        },
        icon: const Icon(Icons.logout, color: Colors.white, size: 18),
        label: const Text(
          'Keluar',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryRed,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }


}

// ── Model data baris info
class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool isLast;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.isLast = false,
  });
}