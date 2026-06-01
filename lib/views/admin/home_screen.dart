import 'package:flutter/material.dart';
import '../../widgets/admin/app_bottom_nav_admin.dart';
import '../../utils/nav_admin.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  static const Color _primaryRed = Color(0xFFB71C1C);
  static const Color _bgColor = Color(0xFFF5F0EE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _primaryRed,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.school, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
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
            onPressed: () {},
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Dashboard Admin\n(Coming Soon)',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ),
      bottomNavigationBar: AppBottomNavAdmin(
        activeTab: NavTabAdmin.home,
        onTabSelected: (tab) => NavAdmin.handleBottomNav(context, tab, NavTabAdmin.home),
      ),
    );
  }
}
