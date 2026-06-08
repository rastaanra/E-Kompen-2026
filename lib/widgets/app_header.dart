import 'package:flutter/material.dart';
import '../views/shared/notifikasi.dart';

class AppHeader extends StatelessWidget {
  final String role; // Tambahkan variabel untuk menampung role dari halaman asal

  // Wajibkan pengisian role saat AppHeader dipanggil
  const AppHeader({super.key, required this.role});

  static const Color _primaryRed = Color(0xFFB71C1C);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _primaryRed,
      padding: const EdgeInsets.only(top: 52, left: 20, right: 20, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.school, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text(
                'E-Kompen JTI',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              // SEKARANG BERUBAH DI SINI: oper string role-nya secara dinamis!
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationScreen(role: role),
                ),
              );
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Stack(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        shape: BoxShape.circle,
                        border: Border.all(color: _primaryRed, width: 1.5),
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