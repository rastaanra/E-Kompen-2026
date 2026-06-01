import 'package:flutter/material.dart';

enum NavTabAdmin { home, pengajuan, verifikasi, management, profil }

class AppBottomNavAdmin extends StatelessWidget {
  final NavTabAdmin activeTab;
  final void Function(NavTabAdmin tab)? onTabSelected;

  const AppBottomNavAdmin({
    super.key,
    required this.activeTab,
    this.onTabSelected,
  });

  static const Color _primaryRed = Color(0xFFB71C1C);
  static const Color _textGrey = Color(0xFF9E9E9E);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.08),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(NavTabAdmin.home, Icons.home_outlined, 'Home'),
          _buildNavItem(NavTabAdmin.pengajuan, Icons.list_alt_outlined, 'Pengajuan'),
          _buildNavItem(NavTabAdmin.verifikasi, Icons.draw_outlined, 'Verifikasi'),
          _buildNavItem(NavTabAdmin.management, Icons.manage_accounts_outlined, 'Management'),
          _buildNavItem(NavTabAdmin.profil, Icons.person_outline, 'Profil'),
        ],
      ),
    );
  }

  Widget _buildNavItem(NavTabAdmin tab, IconData icon, String label) {
    final isActive = activeTab == tab;
    final color = isActive ? _primaryRed : _textGrey;

    return GestureDetector(
      onTap: () => onTabSelected?.call(tab),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: color,
            ),
          ),
          if (isActive) ...[
            const SizedBox(height: 3),
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: _primaryRed,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
