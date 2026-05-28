import 'package:flutter/material.dart';
import '../home_screen.dart';
import '../dosen/home_screen.dart';
import '../kaprodi/home_screen.dart';
import '../admin/home_screen.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  static const Color _primaryRed = Color(0xFFB71C1C);
  static const Color _backgroundCream = Color(0xFFF5EFE6);
  static const Color _textDark = Color(0xFF2D2D2D);
  static const Color _textGrey = Color(0xFF9E9E9E);

  bool _obscurePassword = true;
  String? _selectedRole;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih login sebagai terlebih dahulu'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      Widget targetScreen;

      switch (_selectedRole) {
        case 'Mahasiswa':
          targetScreen = const HomeScreen();
          break;
        case 'Dosen':
          targetScreen = const DosenHomeScreen();
          break;
        case 'Kaprodi':
          targetScreen = const KaprodiHomeScreen();
          break;
        case 'Admin':
          targetScreen = const AdminHomeScreen();
          break;
        default:
          targetScreen = const HomeScreen();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => targetScreen),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryRed,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          // ── Header merah
          Container(
            color: _primaryRed,
            padding: const EdgeInsets.only(top: 40, bottom: 16),
            width: double.infinity,
            child: const Column(
              children: [
                Icon(Icons.school, color: Colors.white, size: 38),
              ],
            ),
          ),

          // ── Body cream
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
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.75,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Judul
                        const Text(
                          'Selamat Datang!',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Silakan masuk ke akun Anda',
                          style: TextStyle(fontSize: 12, color: _textGrey),
                        ),
                        const SizedBox(height: 14),

                        // ── Pilih Role
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.brown.withOpacity(0.3))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'Login sebagai:',
                                style: TextStyle(fontSize: 12, color: _textGrey),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.brown.withOpacity(0.3))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildRoleButton('Mahasiswa', Icons.school_outlined),
                            const SizedBox(width: 10),
                            _buildRoleButton('Dosen', Icons.badge_outlined),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildRoleButton('Kaprodi', Icons.work_outline),
                            const SizedBox(width: 10),
                            _buildRoleButton('Admin', Icons.settings_outlined),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // ── Card Form
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Username
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Username tidak boleh kosong';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Username',
                                    hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
                                    prefixIcon: const Icon(Icons.person_outline, color: Colors.black45, size: 20),
                                    filled: true,
                                    fillColor: const Color(0xFFF8F4EE),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.black12)),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _primaryRed, width: 1.5)),
                                    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.redAccent)),
                                    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Password
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password tidak boleh kosong';
                                    }
                                    if (value.length < 6) {
                                      return 'Password minimal 6 karakter';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                    hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
                                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.black45, size: 20),
                                    suffixIcon: GestureDetector(
                                      onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                                      child: Icon(
                                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                        color: Colors.black45,
                                        size: 18,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF8F4EE),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.black12)),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _primaryRed, width: 1.5)),
                                    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.redAccent)),
                                    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Tombol Masuk
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _primaryRed,
                                      padding: const EdgeInsets.symmetric(vertical: 13),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Masuk',
                                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Lupa password
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                                  ),
                                  child: const Text(
                                    'Lupa Password?',
                                    style: TextStyle(color: _primaryRed, fontSize: 12, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Divider + Daftar
                        Divider(color: Colors.brown.withOpacity(0.3)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Belum punya akun? ', style: TextStyle(fontSize: 12, color: _textDark)),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RegisterScreen()),
                              ),
                              child: const Text(
                                'Daftar.',
                                style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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