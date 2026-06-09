import 'dart:io'; // Wajib untuk penanganan file gambar
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Wajib untuk mengambil foto dari galeri/kamera
import 'package:provider/provider.dart';
import '../login/login_screen.dart';
import '../../widgets/app_header.dart';
import '../../widgets/dosen/app_bottom_nav_dosen.dart';
import '../../utils/nav_dosen.dart';
import '../../utils/session_manager.dart'; 
import '../../services/auth_service.dart';
import '../../providers/auth_provider.dart';

class ProfileDosenScreen extends StatefulWidget {
  const ProfileDosenScreen({super.key});

  @override
  State<ProfileDosenScreen> createState() => _ProfileDosenScreenState();
}

class _ProfileDosenScreenState extends State<ProfileDosenScreen> {
  String namaDosen = 'Memuat...';
  String nipDosen = '-';
  String emailDosen = '-';
  String fotoProfilUrl = ''; // Menyimpan URL foto profil lokal/server
  bool notifikasiAktif = true;
  bool _isLoading = false;

  static const Color _primaryRed = Color(0xFFB71C1C);
  static const Color _backgroundCream = Color(0xFFF5EFE6);
  static const Color _textDark = Color(0xFF2D2D2D);
  static const Color _textGrey = Color(0xFF9E9E9E);

  @override
  void initState() {
    super.initState();
    _loadProfileData(); 
  }

  // Memuat data dosen dari SessionManager
  Future<void> _loadProfileData() async {
    final nama = await SessionManager.getNamaLengkap();
    final nip = await SessionManager.getNip(); 
    final email = await SessionManager.getEmail(); 
    final foto = await SessionManager.getFotoProfil();
    final notif = await SessionManager.getNotifikasiAktif();

    setState(() {
      namaDosen = nama ?? 'Dosen Pengampu';
      nipDosen = nip ?? '-';
      emailDosen = email ?? '${nip ?? 'dosen'}@jti.polinema.ac.id';
      fotoProfilUrl = foto ?? '';
      notifikasiAktif = notif;
    });
  }

  String _getInisial(String nama) {
    if (nama.isEmpty || nama == 'Memuat...') return 'DS';
    List<String> kata = nama.trim().split(' ');
    if (kata.length > 1) {
      return (kata[0][0] + kata[1][0]).toUpperCase();
    }
    return nama[0].toUpperCase();
  }

  // Proses simpan perubahan nama lengkap dosen
  Future<void> _prosesUpdateNama(String namaBaru) async {
    if (namaBaru.trim().isEmpty) {
      _showSnackBar("Nama tidak boleh kosong!", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final Map<String, dynamic> dataUpdate = {
        'nama_lengkap': namaBaru,
      };

      final bool statusSukses = await authProvider.updateProfile(dataUpdate);

      if (statusSukses) {
        await SessionManager.setNamaLengkap(namaBaru);
        await _loadProfileData();
        _showSnackBar("Profil berhasil diperbarui! ✨");
      } else {
        _showSnackBar(authProvider.errorMessage ?? "Gagal memperbarui profil", isError: true);
      }
    } catch (e) {
      _showSnackBar("Terjadi kesalahan: $e", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Ambil gambar dari Kamera/Galeri dan upload ke server sekali pakai
  Future<void> _pickAndUploadImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 50, // Mengompres gambar
    );
    
    if (image == null) return; 

    final File imageFile = File(image.path);
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final bool statusSukses = await authProvider.uploadFotoProfilOnce(imageFile);

      if (statusSukses) {
        final String? newFotoUrl = authProvider.pengguna?.fotoProfil;
        if (newFotoUrl != null) {
          await SessionManager.setFotoProfil(newFotoUrl);
          setState(() {
            fotoProfilUrl = newFotoUrl;
          });
          _showSnackBar("Foto profil berhasil dipasang! ✨");
        }
      } else {
        _showSnackBar(authProvider.errorMessage ?? "Gagal memasang foto profil", isError: true);
      }
    } catch (e) {
      _showSnackBar("Terjadi kesalahan sistem: $e", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ganti Foto Profil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: _primaryRed),
                title: const Text('Ambil Foto dari Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image_outlined, color: _primaryRed),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditProfileSheet() {
    final namaController = TextEditingController(text: namaDosen);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit Profil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _prosesUpdateNama(namaController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Simpan', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Ubah Password', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password Lama'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password Baru'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: _textGrey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final idPengguna = await SessionManager.getIdPengguna();
                if (idPengguna == null) return;

                Navigator.pop(context);
                setState(() => _isLoading = true);

                try {
                  final result = await AuthService().changePassword(
                    idPengguna: idPengguna,
                    oldPassword: oldPasswordController.text,
                    newPassword: newPasswordController.text,
                  );

                  if (!mounted) return;

                  if (result['success'] == true) {
                    _showSnackBar(result['message'] ?? 'Password berhasil diubah! ✨');
                  } else {
                    _showSnackBar(result['message'] ?? 'Gagal mengubah password', isError: true);
                  }
                } catch (e) {
                  _showSnackBar('Terjadi kesalahan: $e', isError: true);
                } finally {
                  setState(() => _isLoading = false);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: _primaryRed),
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryRed,
      body: Stack(
        children: [
          Column(
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
                      physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileCard(),
                          const SizedBox(height: 20),
                          _buildSectionLabel('Kontak'),
                          const SizedBox(height: 10),
                          _buildInfoCard(items: [
                            _InfoItem(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              value: emailDosen, 
                              valueColor: _primaryRed,
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
              AppBottomNavDosen(
                activeTab: NavTabDosen.profil,
                onTabSelected: (tab) =>
                    NavDosen.handleBottomNav(context, tab, NavTabDosen.profil),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: _primaryRed),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final bool isFotoAda = fotoProfilUrl.isNotEmpty && fotoProfilUrl != 'null';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: const BoxDecoration(
                  color: _primaryRed,
                  shape: BoxShape.circle,
                ),
                child: isFotoAda
                    ? ClipOval(
                        child: Image.network(
                          fotoProfilUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Center(
                            child: Text(
                              _getInisial(namaDosen),
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          _getInisial(namaDosen),
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
                        ),
                      ),
              ),
              if (!isFotoAda)
                Positioned(
                  bottom: -3,
                  right: -3,
                  child: GestureDetector(
                    onTap: _showPhotoOptions,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: _primaryRed,
                        size: 15,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  namaDosen,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: _textDark),
                ),
                const SizedBox(height: 3),
                Text(
                  'NIP: $nipDosen',
                  style: const TextStyle(fontSize: 13, color: _textGrey),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE5E5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7, height: 7,
                        decoration: const BoxDecoration(color: _primaryRed, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'Dosen Aktif',
                        style: TextStyle(fontSize: 11, color: _primaryRed, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showEditProfileSheet,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE5E5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.edit_outlined, color: _primaryRed, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _textGrey, letterSpacing: 0.8),
    );
  }

  Widget _buildInfoCard({required List<_InfoItem> items}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(color: const Color(0xFFFFE5E5), borderRadius: BorderRadius.circular(10)),
                      child: Icon(item.icon, color: _primaryRed, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: const TextStyle(fontSize: 12, color: _textGrey, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.value,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: item.valueColor ?? _textDark),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(height: 1, thickness: 0.5, color: Color(0xFFF0EBE0), indent: 16, endIndent: 16),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.lock_outline,
            label: 'Ubah Password',
            trailing: const Icon(Icons.chevron_right, color: _textGrey, size: 20),
            onTap: _showChangePasswordDialog,
          ),
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFF0EBE0), indent: 16, endIndent: 16),
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            label: 'Notifikasi',
            trailing: _buildToggle(notifikasiAktif),
            onTap: () async {
              final newValue = !notifikasiAktif;
              await SessionManager.setNotifikasiAktif(newValue);
              setState(() {
                notifikasiAktif = newValue;
              });
            },
          ),
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFF0EBE0), indent: 16, endIndent: 16),
          _buildSettingsTile(
            icon: Icons.help_outline,
            label: 'Bantuan & FAQ',
            trailing: const Icon(Icons.chevron_right, color: _textGrey, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String label,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: const Color(0xFFFFE5E5), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: _primaryRed, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _textDark),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(bool isOn) {
    return Container(
      width: 38, height: 22,
      decoration: BoxDecoration(
        color: isOn ? _primaryRed : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Align(
        alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 18, height: 18,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Keluar dari Akun', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: _textDark)),
              content: const Text('Yakin keluar dari akun?', style: TextStyle(fontSize: 14, color: _textGrey)),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _primaryRed),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  ),
                  child: const Text('Tidak', style: TextStyle(color: _primaryRed, fontWeight: FontWeight.w600)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    elevation: 0,
                  ),
                  child: const Text('Ya', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          );
          if (confirm == true && context.mounted) {
            await SessionManager.hapus(); 
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        },
        icon: const Icon(Icons.logout, color: Colors.white, size: 18),
        label: const Text('Keluar', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryRed,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool isLast;

  _InfoItem({required this.icon, required this.label, required this.value, this.valueColor, this.isLast = false});
}