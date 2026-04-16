import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nimController = TextEditingController();
  final _prodiController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _konfirmasiController = TextEditingController();

  static const Color _primaryRed = Color(0xFFB71C1C);
  static const Color _backgroundCream = Color(0xFFF5EFE6);
  static const Color _textDark = Color(0xFF2D2D2D);
  static const Color _textGrey = Color(0xFF9E9E9E);

  String? _selectedProdi;

  bool _obscurePassword = true;
  bool _obscureKonfirmasi = true;

  @override
  void dispose() {
    _namaController.dispose();
    _nimController.dispose();
    _prodiController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _konfirmasiController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pendaftaran berhasil! Silakan login.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    }
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primaryRed, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
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
                      Text('Biodata Diri',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark)),
                      Text('Lengkapi data berikut untuk mendaftar',
                          style: TextStyle(fontSize: 13, color: _textGrey)),
                      const SizedBox(height: 24),

                      // Nama
                      _buildField(
                        controller: _namaController,
                        hint: 'Nama Lengkap',
                        icon: Icons.person_outline,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Nama tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 12),

                      // NIM
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
                      ),
                      const SizedBox(height: 12),

                      // Program Studi
                      DropdownButtonFormField<String>(
                        value: _selectedProdi,
                        onChanged: (value) {
                          setState(() {
                            _selectedProdi = value;
                          });
                        },
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Program studi tidak boleh kosong' : null,
                        decoration: InputDecoration(
                          hintText: 'Program Studi',
                          prefixIcon: const Icon(Icons.school_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'TI', child: Text('D-IV Teknik Informatika')),
                          DropdownMenuItem(value: 'SIB', child: Text('D-IV Sistem Informasi Bisnis')),
                        ],
                      ),

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

                      // Konfirmasi password
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

                      // Tombol daftar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryRed,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Daftar',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
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
}