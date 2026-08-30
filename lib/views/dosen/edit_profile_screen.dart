import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../widgets/app_header.dart';
import '../../providers/auth_provider.dart';
import '../../utils/session_manager.dart';

class EditProfileDosenScreen extends StatefulWidget {
  const EditProfileDosenScreen({super.key});

  @override
  State<EditProfileDosenScreen> createState() => _EditProfileDosenScreenState();
}

class _EditProfileDosenScreenState extends State<EditProfileDosenScreen> {
  static const Color _primaryRed = Color(0xFFB71C1C);
  static const Color _backgroundCream = Color(0xFFF5EFE6);
  static const Color _textDark = Color(0xFF2D2D2D);
  static const Color _textGrey = Color(0xFF9E9E9E);

  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _nipController = TextEditingController();

  bool _isLoading = false;
  bool _isFetching = true;

  String? _idPengguna;
  String _fotoProfilUrl = '';

  @override
  void initState() {
    super.initState();
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    String savedFoto = prefs.getString('foto_profil') ?? '';

    if (savedFoto.isNotEmpty && !savedFoto.startsWith('http')) {
      savedFoto = '';
    }

    setState(() {
      _idPengguna = prefs.getInt('id_pengguna')?.toString();
      _namaController.text = prefs.getString('nama_lengkap') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      _nipController.text = prefs.getString('nip') ?? '-';
      _fotoProfilUrl = savedFoto;
      _isFetching = false;
    });
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

  Future<void> _pickAndUploadImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 50,
    );

    if (image == null) return;

    final File imageFile = File(image.path);
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final bool statusSukses = await authProvider.uploadFotoProfilOnce(imageFile);

      if (statusSukses) {
        final dynamic penggunaData = authProvider.pengguna;
        String? newFotoUrl;

        if (penggunaData != null) {
          if (penggunaData is Map) {
            final fotoRaw = penggunaData['foto_profil'];
            if (fotoRaw is Map) {
              newFotoUrl = fotoRaw['foto_profil_full'] ?? fotoRaw['foto_profil']?.toString();
            } else {
              newFotoUrl = fotoRaw?.toString();
            }
          } else {
            newFotoUrl = authProvider.pengguna?.fotoProfil?.toString();
          }
        }

        if (newFotoUrl != null &&
            newFotoUrl.isNotEmpty &&
            newFotoUrl != 'null' &&
            newFotoUrl.startsWith('http')) {
          await SessionManager.setFotoProfil(newFotoUrl);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('foto_profil', newFotoUrl);

          setState(() {
            _fotoProfilUrl = newFotoUrl!;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Foto profil berhasil dipasang! ✨"),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          setState(() {
            _fotoProfilUrl = '';
          });
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('foto_profil', '');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Profil tersinkronisasi (Menggunakan Inisial)."),
                backgroundColor: Colors.blue,
              ),
            );
          }
        }
      } else {
        _showError(authProvider.errorMessage ?? "Gagal memasang foto profil");
      }
    } catch (e) {
      _showError("Terjadi kesalahan sistem: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) {
      _showError('Nama tidak boleh kosong!');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.put('auth/update-profile/$_idPengguna', {
        'nama_lengkap': _namaController.text.trim(),
        'email': _emailController.text.trim(),
      });

      if (!mounted) return;

      if (result['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('nama_lengkap', _namaController.text.trim());

        final fotoBaru = result['data']['foto_profil'];
        if (fotoBaru != null && fotoBaru.toString().startsWith('http')) {
          await prefs.setString('foto_profil', fotoBaru.toString());
        } else {
          await prefs.remove('foto_profil');
        }

        Navigator.pop(context, true);
      } else {
        _showError(result['message'] ?? 'Gagal memperbarui profil');
      }
    } catch (e) {
      _showError('Terjadi kesalahan koneksi.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red[800]),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _nipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isFotoAda = _fotoProfilUrl.isNotEmpty &&
        _fotoProfilUrl != 'null' &&
        _fotoProfilUrl.startsWith('http');

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
              child: _isFetching
                  ? const Center(
                      child: CircularProgressIndicator(color: _primaryRed),
                    )
                  : Stack(
                      children: [
                        SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: const Icon(Icons.arrow_back_ios,
                                          color: _primaryRed, size: 20),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Edit Profil',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: _textDark,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 28),

                                // Foto profil
                                Center(
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        width: 96,
                                        height: 96,
                                        decoration: const BoxDecoration(
                                          color: _primaryRed,
                                          shape: BoxShape.circle,
                                        ),
                                        child: isFotoAda
                                            ? ClipOval(
                                                child: Image.network(
                                                  '$_fotoProfilUrl?v=${DateTime.now().millisecondsSinceEpoch}',
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (ctx, err, stack) => Center(
                                                    child: Text(
                                                      _namaController.text.isNotEmpty
                                                          ? _namaController.text.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join()
                                                          : 'DS',
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 24,
                                                          fontWeight: FontWeight.w700),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Center(
                                                child: Text(
                                                  _namaController.text.isNotEmpty
                                                      ? _namaController.text.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join()
                                                      : 'DS',
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.w700),
                                                ),
                                              ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: -4,
                                        child: GestureDetector(
                                          onTap: isFotoAda ? null : _showPhotoOptions,
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: isFotoAda ? Colors.grey[400] : Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                )
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.camera_alt,
                                              color: isFotoAda ? Colors.white : _primaryRed,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 35),

                                // Nama Lengkap (editable)
                                const Text(
                                  'Nama Lengkap',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _textDark),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _namaController,
                                  style: const TextStyle(fontSize: 15, color: _textDark),
                                  decoration: InputDecoration(
                                    hintText: 'Masukkan nama lengkap',
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Nama lengkap tidak boleh kosong';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                // NIP (read-only)
                                const Text(
                                  'NIP',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _textDark),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _nipController,
                                  readOnly: true,
                                  style: const TextStyle(fontSize: 15, color: _textGrey),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    prefixIcon: const Icon(Icons.lock_outline,
                                        size: 18, color: _textGrey),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Email (read-only)
                                const Text(
                                  'Alamat Email',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _textDark),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _emailController,
                                  readOnly: true,
                                  style: const TextStyle(fontSize: 15, color: _textGrey),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    prefixIcon: const Icon(Icons.lock_outline,
                                        size: 18, color: _textGrey),
                                  ),
                                ),
                                const SizedBox(height: 40),

                                // Tombol Simpan
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _simpan,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _primaryRed,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                                color: Colors.white, strokeWidth: 2.5),
                                          )
                                        : const Text(
                                            'Simpan Perubahan',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}