import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../widgets/app_header.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  static const Color _primaryRed = Color(0xFFB71C1C);
  static const Color _backgroundCream = Color(0xFFF5EFE6);
  static const Color _textDark = Color(0xFF2D2D2D);
  static const Color _textGrey = Color(0xFF9E9E9E);

  final _formKey = GlobalKey<FormState>();
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _isLoading = false;
  bool _showOld = false;
  bool _showNew = false;
  bool _showConfirm = false;

  Future<void> _gantiPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final idPengguna = prefs.getInt('id_pengguna')?.toString();

      if (idPengguna == null) {
        _showError('Session tidak ditemukan. Silakan login ulang.');
        return;
      }

      final result = await ApiService.post(
        'auth/change-password/$idPengguna',
        {
          'old_password': _oldPassController.text,
          'new_password': _newPassController.text,
        },
      );

      if (!mounted) return;

      if (result['success'] == true) {
        _showSuccessDialog();
      } else {
        _showError(result['message'] ?? 'Gagal mengubah password');
      }
    } catch (e) {
      _showError('Terjadi kesalahan. Coba lagi.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle_outline,
                  color: Colors.green[700], size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'Password Berhasil Diubah',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Password kamu sudah diperbarui.',
              style: TextStyle(fontSize: 13, color: _textGrey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
            ),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red[800]),
    );
  }

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

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
              child: SingleChildScrollView(
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
                            'Ubah Password',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Info banner
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _primaryRed.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _primaryRed.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                color: _primaryRed, size: 18),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Password baru minimal 6 karakter dan '
                                'harus berbeda dari password lama.',
                                style: TextStyle(fontSize: 12, color: _textDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Password lama
                      _buildLabel('Password Lama'),
                      const SizedBox(height: 6),
                      _buildPasswordField(
                        controller: _oldPassController,
                        hint: 'Masukkan password lama',
                        show: _showOld,
                        onToggle: () => setState(() => _showOld = !_showOld),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Password lama tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Password baru
                      _buildLabel('Password Baru'),
                      const SizedBox(height: 6),
                      _buildPasswordField(
                        controller: _newPassController,
                        hint: 'Masukkan password baru',
                        show: _showNew,
                        onToggle: () => setState(() => _showNew = !_showNew),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Password baru tidak boleh kosong';
                          }
                          if (v.length < 6) {
                            return 'Minimal 6 karakter';
                          }
                          if (v == _oldPassController.text) {
                            return 'Password baru harus berbeda dari password lama';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Konfirmasi password baru
                      _buildLabel('Konfirmasi Password Baru'),
                      const SizedBox(height: 6),
                      _buildPasswordField(
                        controller: _confirmPassController,
                        hint: 'Ulangi password baru',
                        show: _showConfirm,
                        onToggle: () => setState(() => _showConfirm = !_showConfirm),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Konfirmasi password tidak boleh kosong';
                          }
                          if (v != _newPassController.text) {
                            return 'Password tidak cocok';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 36),

                      // Tombol Simpan
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _gantiPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryRed,
                            disabledBackgroundColor: _primaryRed.withOpacity(0.6),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'Simpan Password Baru',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _textGrey,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool show,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !show,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _textGrey, fontSize: 14),
        prefixIcon: const Icon(Icons.lock_outline, color: _primaryRed, size: 20),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
            show ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: _textGrey,
            size: 20,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryRed, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }
}