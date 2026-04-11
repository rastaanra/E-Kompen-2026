import 'package:flutter/material.dart';

enum NavTab { home, pengajuan, tracking, profil }

class AppBottomNav extends StatelessWidget {
  final NavTab activeTab;
  final void Function(NavTab tab)? onTabSelected;

  const AppBottomNav({
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
          _buildNavItem(NavTab.home, Icons.home_outlined, 'Home'),
          _buildNavItem(NavTab.pengajuan, Icons.list_alt_outlined, 'Pengajuan'),
          _buildNavItem(NavTab.tracking, Icons.check_circle_outline, 'Tracking'),
          _buildNavItem(NavTab.profil, Icons.person, 'Profil'),
        ],
      ),
    );
  }

  Widget _buildNavItem(NavTab tab, IconData icon, String label) {
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