import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ambil data login asli
import '../../widgets/app_header.dart';
import '../../widgets/admin/app_bottom_nav_admin.dart';
import '../../utils/nav_admin.dart';

// Import file Screen yang lupa dihubunginnn:
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'bantuan_faq_screen.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  static const Color _primaryRed = Color(0xFFB71C1C);
  static const Color _backgroundCream = Color(0xFFF5EFE6);
  static const Color _textDark = Color(0xFF2D2D2D);
  static const Color _textGrey = Color(0xFF9E9E9E);

  bool _notifEnabled = true;

  // Variabel penampung data login asli
  String _namaLengkap = 'Loading...';
  String _email = 'Loading...';
  String _initials = 'AD';
  String? _currentFotoPath; 

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Fungsi untuk meload data asli dari database/session login 
Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final nama = prefs.getString('nama_lengkap') ?? 'Admin E-Kompen';
    final email = prefs.getString('email') ?? 'admin@jti.com';
    String? foto = prefs.getString('foto_profil');

    // Jika foto kosong, pastikan jadi null
    String? fotoFix = (foto != null && foto.startsWith('http')) ? foto : null;

    String initials = '';
    final nameParts = nama.trim().split(' ');
    if (nameParts.length >= 2) {
      initials = '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else if (nameParts.isNotEmpty && nameParts[0].isNotEmpty) {
      initials = nameParts[0][0].toUpperCase();
    }

    if (mounted) {
      setState(() {
        _namaLengkap = nama;
        _email = email;
        _initials = initials;
        _currentFotoPath = fotoFix;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Evaluasi akhir sebelum render image network
    final bool isFotoValid = _currentFotoPath != null && 
    _currentFotoPath!.isNotEmpty && 
    _currentFotoPath!.startsWith('http');

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card profil
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // ─ AVATAR BERSIH DENGAN AMAN ─
                        CircleAvatar(
                            radius: 36,
                            backgroundColor: _primaryRed,
                            child: _currentFotoPath != null
                                ? ClipOval(
                                    child: Image.network(
                                      '$_currentFotoPath',
                                      fit: BoxFit.cover,
                                      width: 72,
                                      height: 72,
                                      errorBuilder: (ctx, err, stack) => Text(_initials, style: const TextStyle(color: Colors.white, fontSize: 20)),
                                    ),
                                  )
                                : Text(_initials, style: const TextStyle(color: Colors.white, fontSize: 20)),
                          ),
                          const SizedBox(width: 16),
                          // ─ BAGIAN DETAIL NAMA & BADGE ─
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _namaLengkap,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: _textDark,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _primaryRed.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'Admin Aktif',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: _primaryRed,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ─ TOMBOL EDIT ─
                          GestureDetector(
                            onTap: () async {
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                              );
                              if (updated == true) {
                                _loadProfileData();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _primaryRed.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.edit_outlined,
                                color: _primaryRed,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Kontak
                    const Text(
                      'KONTAK',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _textGrey,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _primaryRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.email_outlined,
                                color: _primaryRed, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Email',
                                    style: TextStyle(
                                        fontSize: 11, color: _textGrey)),
                                Text(
                                  _email, // Email dinamis asli database
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _primaryRed,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Pengaturan
                    const Text(
                      'PENGATURAN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _textGrey,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Ubah password
                          _buildSettingsTile(
                            icon: Icons.lock_outline,
                            label: 'Ubah Password',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                              );
                            },
                          ),
                          const Divider(height: 1, indent: 54),
                          // Notifikasi
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: _primaryRed.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                      Icons.notifications_outlined,
                                      color: _primaryRed,
                                      size: 18),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text('Notifikasi',
                                      style: TextStyle(
                                          fontSize: 14, color: _textDark)),
                                ),
                                Switch(
                                  value: _notifEnabled,
                                  onChanged: (val) =>
                                      setState(() => _notifEnabled = val),
                                  activeColor: _primaryRed,
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, indent: 54),
                          // Bantuan
                          _buildSettingsTile(
                            icon: Icons.help_outline,
                            label: 'Bantuan & FAQ',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const BantuanFaqScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Tombol Keluar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              title: const Text(
                                'Keluar dari Akun',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              content: const Text(
                                'Yakin keluar dari akun?',
                                textAlign: TextAlign.center,
                              ),
                              actionsAlignment: MainAxisAlignment.center,
                              actions: [
                                OutlinedButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: _primaryRed,
                                    side: const BorderSide(color: _primaryRed),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 10),
                                  ),
                                  child: const Text('Tidak'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    NavAdmin.toLogin(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primaryRed,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 10),
                                  ),
                                  child: const Text(
                                    'Ya',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text(
                          'Keluar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryRed,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AppBottomNavAdmin(
            activeTab: NavTabAdmin.profil,
            onTap: (tab) => NavAdmin.handleBottomNav(context, tab, NavTabAdmin.profil),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _primaryRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: _primaryRed, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(fontSize: 14, color: _textDark)),
            ),
            const Icon(Icons.chevron_right, color: _textGrey, size: 20),
          ],
        ),
      ),
    );
  }
}