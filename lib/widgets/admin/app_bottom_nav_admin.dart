import 'package:flutter/material.dart';

enum NavTabAdmin { home, pengajuan, verifikasi, management, profil }

class AppBottomNavAdmin extends StatelessWidget {
  final NavTabAdmin activeTab;
  final Function(NavTabAdmin) onTap;

  const AppBottomNavAdmin({
    super.key,
    required this.activeTab,
    required this.onTap,
  });

  static const Color _primaryRed = Color(0xFFB71C1C);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: activeTab.index,
      onTap: (i) => onTap(NavTabAdmin.values[i]),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: _primaryRed,
      unselectedItemColor: Colors.grey,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      backgroundColor: Colors.white,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.description_outlined),
          activeIcon: Icon(Icons.description),
          label: 'Pengajuan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.edit_outlined),
          activeIcon: Icon(Icons.edit),
          label: 'Verifikasi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          activeIcon: Icon(Icons.people),
          label: 'Management',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}