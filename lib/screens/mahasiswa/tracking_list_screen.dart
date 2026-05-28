import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';
import '../../widgets/mahasiswa/app_bottom_nav.dart';
import 'tracking_screen.dart';

class TrackingListScreen extends StatelessWidget {
  const TrackingListScreen({super.key});

  static const Color _primaryRed = Color(0xFFB71C1C);
  static const Color _backgroundCream = Color(0xFFF5EFE6);
  static const Color _textDark = Color(0xFF2D2D2D);
  static const Color _textGrey = Color(0xFF9E9E9E);

  static const List<Map<String, dynamic>> _pengajuanList = [
    {
      "matkul": "Pemrograman Web",
      "dosen": "Dr. Ahmad Fauzi, M.Kom",
      "jamAlpha": 2,
      "tanggal": "13 Apr 2026",
      "statusLabel": "Menunggu TTD",
      "statusType": "waiting",
    },
    {
      "matkul": "Jaringan Komputer",
      "dosen": "Ir. Budi Santoso, M.T",
      "jamAlpha": 1,
      "tanggal": "05 Apr 2026",
      "statusLabel": "Sedang Diproses",
      "statusType": "progress",
    },
    {
      "matkul": "Basis Data",
      "dosen": "Luqman Affandi, S.Kom., MMSI",
      "jamAlpha": 3,
      "tanggal": "10 Apr 2026",
      "statusLabel": "Selesai",
      "statusType": "selesai",
    },
  ];

  Color _statusBgColor(String type) {
    switch (type) {
      case 'selesai': return const Color(0xFFE8F5E9);
      case 'progress': return const Color(0xFFFFF8E1);
      case 'waiting': return const Color(0xFFFCE8E8);
      case 'ditolak': return const Color(0xFFFFEBEE);
      default: return const Color(0xFFF5F5F5);
    }
  }

  Color _statusTextColor(String type) {
    switch (type) {
      case 'selesai': return const Color(0xFF2E7D32);
      case 'progress': return const Color(0xFFF57F17);
      case 'waiting': return _primaryRed;
      case 'ditolak': return const Color(0xFFC62828);
      default: return _textGrey;
    }
  }

  IconData _statusIcon(String type) {
    switch (type) {
      case 'selesai': return Icons.check_circle_outline;
      case 'progress': return Icons.autorenew;
      case 'waiting': return Icons.pending_outlined;
      case 'ditolak': return Icons.cancel_outlined;
      default: return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final aktif = _pengajuanList.where((e) => e['statusType'] != 'selesai').toList();
    final selesai = _pengajuanList.where((e) => e['statusType'] == 'selesai').toList();

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 22, 20, 4),
                    child: Text(
                      'Tracking Pengajuan',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2D2D2D)),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Text(
                      'Pantau status kompensasi kamu',
                      style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      children: [
                        // ── SECTION AKTIF ──
                        if (aktif.isNotEmpty) ...[
                          _buildSectionHeader(
                            icon: Icons.radio_button_checked,
                            iconColor: _primaryRed,
                            label: 'Sedang Berjalan',
                            count: aktif.length,
                            countBgColor: const Color(0xFFFCE8E8),
                            countTextColor: _primaryRed,
                          ),
                          const SizedBox(height: 10),
                          ...aktif.map((item) => _buildCard(context, item)),
                        ],

                        // ── SECTION SELESAI ──
                        if (selesai.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _buildSectionHeader(
                            icon: Icons.check_circle,
                            iconColor: const Color(0xFF2E7D32),
                            label: 'Kompen Selesai',
                            count: selesai.length,
                            countBgColor: const Color(0xFFE8F5E9),
                            countTextColor: const Color(0xFF2E7D32),
                          ),
                          const SizedBox(height: 10),
                          ...selesai.map((item) => _buildCard(context, item, isSelesai: true)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppBottomNav(
            activeTab: NavTab.tracking,
            onTabSelected: (tab) {
              switch (tab) {
                case NavTab.home: Navigator.pop(context); break;
                case NavTab.pengajuan: Navigator.pop(context); break;
                case NavTab.profil: Navigator.pop(context); break;
                case NavTab.tracking: break;
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required Color iconColor,
    required String label,
    required int count,
    required Color countBgColor,
    required Color countTextColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: iconColor,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: countBgColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count pengajuan',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: countTextColor),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, Map<String, dynamic> item, {bool isSelesai = false}) {
    final statusType = item['statusType'] as String;
    final jamAlpha = item['jamAlpha'] as int;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TrackingScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelesai ? Colors.white.withOpacity(0.7) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelesai ? Border.all(color: const Color(0xFFE0E0E0), width: 1) : null,
          boxShadow: isSelesai
              ? []
              : const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.06),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris atas: nama matkul + badge status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['matkul'],
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: isSelesai ? _textGrey : _textDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item['dosen'],
                        style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusBgColor(statusType),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon(statusType), size: 12, color: _statusTextColor(statusType)),
                      const SizedBox(width: 4),
                      Text(
                        item['statusLabel'],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _statusTextColor(statusType),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Jam alpha — dibikin menonjol
            if (!isSelesai)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE8E8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: _primaryRed),
                    const SizedBox(width: 6),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 12, color: _textDark),
                        children: [
                          TextSpan(
                            text: '$jamAlpha Jam Alpha ',
                            style: const TextStyle(fontWeight: FontWeight.w700, color: _primaryRed, fontSize: 13),
                          ),
                          const TextSpan(text: 'perlu dikompensasi'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            if (isSelesai)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_outlined, size: 16, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 6),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 12, color: _textDark),
                        children: [
                          TextSpan(
                            text: '$jamAlpha Jam Alpha ',
                            style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2E7D32), fontSize: 13),
                          ),
                          const TextSpan(text: 'berhasil dikompensasi'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 10),

            // Baris bawah: tanggal + arrow
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF9E9E9E)),
                const SizedBox(width: 4),
                Text(
                  item['tanggal'],
                  style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelesai ? const Color(0xFFE8F5E9) : const Color(0xFFFCE8E8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: isSelesai ? const Color(0xFF2E7D32) : _primaryRed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}