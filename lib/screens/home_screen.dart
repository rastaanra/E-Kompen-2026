import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color _primaryRed = Color(0xFFB71C1C);
  static const Color _backgroundCream = Color(0xFFF5EFE6);
  static const Color _cardBeige = Color(0xFFEDE0CC);
  static const Color _textDark = Color(0xFF2D2D2D);
  static const Color _textGrey = Color(0xFF9E9E9E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryRed, // Biar background di belakang header ikut merah
      body: Column(
        children: [
          _buildHeader(),
          // Expanded cream area dengan rounded top corners
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: _backgroundCream,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              child: Column(
                children: [
                  _buildGreetingCard(),
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatusKompen(),
                          const SizedBox(height: 16),
                          _buildRekapitulasiSection(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  // ── Header merah
  Widget _buildHeader() {
    return Container(
      color: _primaryRed,
      padding: const EdgeInsets.only(top: 52, left: 20, right: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
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
              Stack(
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 26,
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.yellow,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Greeting
  Widget _buildGreetingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Halo, Sally Savista!',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: _textDark,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'NIM: 244107060064',
                  style: TextStyle(
                    fontSize: 14,
                    color: _textGrey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Color.fromRGBO(183, 28, 28, 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: _primaryRed,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }

  // ── Status Kompen
  Widget _buildStatusKompen() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'STATUS KOMPEN',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: _textDark,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 13, color: _textDark),
              children: [
                TextSpan(text: 'Sisa Jam Alpha: '),
                TextSpan(
                  text: '18 Jam',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: const LinearProgressIndicator(
              value: 0.75,
              minHeight: 10,
              backgroundColor: Color(0xFFE0E0E0),
              valueColor: AlwaysStoppedAnimation<Color>(_primaryRed),
            ),
          ),
        ],
      ),
    );
  }

  // ── Rekapitulasi
  Widget _buildRekapitulasiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'REKAPITULASI',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: _textDark,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildRekapCard(label: 'Total Kompen', value: '24 Jam')),
            const SizedBox(width: 12),
            Expanded(child: _buildRekapCard(label: 'Disetujui', value: '6 Jam')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildRekapCard(label: 'Menunggu', value: '12 Jam')),
            const SizedBox(width: 12),
            Expanded(child: _buildRekapCard(label: 'Ditolak', value: '0 Jam')),
          ],
        ),
      ],
    );
  }

  Widget _buildRekapCard({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: _cardBeige,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: _textGrey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: _textDark,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Nav
  Widget _buildBottomNav() {
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
          _buildNavItem(icon: Icons.home, label: 'Home', isActive: true),
          _buildNavItem(icon: Icons.list_alt_outlined, label: 'Pengajuan'),
          _buildNavItem(icon: Icons.check_circle_outline, label: 'Tracking'),
          _buildNavItem(icon: Icons.person_outline, label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    bool isActive = false,
  }) {
    final color = isActive ? _primaryRed : _textGrey;
    return Column(
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
    );
  }
}