import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nimController = TextEditingController();
  final _nipController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _konfirmasiController = TextEditingController();

  static const Color _primaryRed = Color(0xFFB71C1C);
  static const Color _backgroundCream = Color(0xFFF5EFE6);
  static const Color _textDark = Color(0xFF2D2D2D);
  static const Color _textGrey = Color(0xFF9E9E9E);

  bool _obscurePassword = true;
  bool _obscureKonfirmasi = true;
  String? _selectedRole; // 'Mahasiswa' | 'Dosen/Kaprodi'

  @override
  void dispose() {
    _nimController.dispose();
    _nipController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _konfirmasiController.dispose();
    super.dispose();
  }

Future<void> _register() async {
  if (_selectedRole == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Silakan pilih role terlebih dahulu'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  if (!_formKey.currentState!.validate()) return;

  // 'Dosen/Kaprodi' di UI → kirim 'dosen' ke backend (sesuai pesan temanmu)
  final String backendRole =
      _selectedRole == 'Mahasiswa' ? 'mahasiswa' : 'dosen';

  final Map<String, dynamic> data = {
    'email': _emailController.text.trim(),
    'password': _passwordController.text,
    'role': backendRole,
    if (_selectedRole == 'Mahasiswa')
      'nim': _nimController.text.trim()
    else
      'nip': _nipController.text.trim(),
  };

  final provider = Provider.of<AuthProvider>(context, listen: false);
  final success = await provider.register(data);

  if (!mounted) return;

  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pendaftaran berhasil! Silakan login.'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(provider.errorMessage ?? 'Registrasi gagal'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

  Widget _buildRoleButton(String label, IconData icon) {
    final bool isSelected = _selectedRole == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF8B0000) : _primaryRed,
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    bool showToggle = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.black45, size: 20),
        suffixIcon: showToggle
            ? GestureDetector(
                onTap: onToggleObscure,
                child: Icon(
                  obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.black45,
                  size: 20,
                ),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.black12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.black12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _primaryRed, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.redAccent)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryRed,
      body: Column(
        children: [
          // Header
          Container(
            color: _primaryRed,
            padding: const EdgeInsets.only(top: 56, bottom: 24, left: 16),
            width: double.infinity,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Daftar Akun',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: _backgroundCream,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daftar Sebagai',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark)),
                      Text('Pilih role dan lengkapi data berikut',
                          style: TextStyle(fontSize: 13, color: _textGrey)),
                      const SizedBox(height: 16),

                      // ── Pilih Role
                      Row(
                        children: [
                          _buildRoleButton('Mahasiswa', Icons.school_outlined),
                          const SizedBox(width: 10),
                          _buildRoleButton('Dosen/Kaprodi', Icons.badge_outlined),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ── Form menyesuaikan role
                      if (_selectedRole == null)
                        Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 24),
                              Icon(Icons.person_outline, size: 48, color: _textGrey.withOpacity(0.5)),
                              const SizedBox(height: 12),
                              Text(
                                'Pilih role terlebih dahulu',
                                style: TextStyle(fontSize: 14, color: _textGrey),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        // NIM (Mahasiswa) atau NIP (Dosen/Kaprodi)
                        if (_selectedRole == 'Mahasiswa')
                          _buildField(
                            controller: _nimController,
                            hint: 'NIM',
                            icon: Icons.badge_outlined,
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'NIM tidak boleh kosong';
                              if (v.length < 6) return 'NIM tidak valid';
                              return null;
                            },
                          )
                        else
                          _buildField(
                            controller: _nipController,
                            hint: 'NIP',
                            icon: Icons.badge_outlined,
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'NIP tidak boleh kosong';
                              if (v.length < 6) return 'NIP tidak valid';
                              return null;
                            },
                          ),
                        const SizedBox(height: 12),

                        // Email
                        _buildField(
                          controller: _emailController,
                          hint: 'Email Aktif',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
                            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegex.hasMatch(v)) return 'Format email tidak valid';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Password
                        _buildField(
                          controller: _passwordController,
                          hint: 'Password',
                          icon: Icons.lock_outline,
                          obscure: _obscurePassword,
                          showToggle: true,
                          onToggleObscure: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Password tidak boleh kosong';
                            if (v.length < 6) return 'Password minimal 6 karakter';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Konfirmasi Password
                        _buildField(
                          controller: _konfirmasiController,
                          hint: 'Konfirmasi Password',
                          icon: Icons.lock_outline,
                          obscure: _obscureKonfirmasi,
                          showToggle: true,
                          onToggleObscure: () =>
                              setState(() => _obscureKonfirmasi = !_obscureKonfirmasi),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Konfirmasi password tidak boleh kosong';
                            if (v != _passwordController.text) return 'Password tidak cocok';
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),

                        // Tombol Daftar
                        SizedBox(
                          width: double.infinity,
                          child: Consumer<AuthProvider>(
                            builder: (context, auth, _) => ElevatedButton(
                              onPressed: auth.isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryRed,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: auth.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Daftar',
                                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                                    ),
                            ),
                          ),
                        ),
                      ],
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
}