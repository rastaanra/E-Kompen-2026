import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';
import '../../widgets/mahasiswa/app_bottom_nav.dart';
import '../../utils/nav_mahasiswa.dart';
import '../../models/pengajuan_kompen.dart';
import 'tracking_screen.dart';

class TrackingListScreen extends StatelessWidget {
  const TrackingListScreen({super.key});

  static const Color _primaryRed = Color(0xFFB71C1C);
  static const Color _backgroundCream = Color(0xFFF5EFE6);
  static const Color _textDark = Color(0xFF2D2D2D);
  static const Color _textGrey = Color(0xFF9E9E9E);

  // Dummy data — hanya yang sudah ajukan TTD (masuk tracking)
  // TODO: ganti dengan data dari PengajuanProvider
  static final List<Map<String, dynamic>> _pengajuanList = [
    {
      'idPengajuan': 1,
      'matkul': 'Pemrograman Web',
      'dosen': 'Siti Rahayu, S.Kom, M.T',
      'jamAlpha': 2,
      'tanggal': '13 Apr 2026',
      'status': 'selesai',
      'namaLokasi': 'Lab Komputer B',
      'latitude': -7.9402,
      'longitude': 112.6178,
      'deskripsiTugas': 'Menyiapkan modul Pemrograman Web semester depan',
    },
    {
      'idPengajuan': 2,
      'matkul': 'Jaringan Komputer',
      'dosen': 'Ir. Budi Santoso, M.T',
      'jamAlpha': 3,
      'tanggal': '05 Apr 2026',
      'status': 'menunggu_ttd_dosen',
      'namaLokasi': 'Lab Jaringan',
      'latitude': -7.9410,
      'longitude': 112.6190,
      'deskripsiTugas': 'Merapikan kabel jaringan di laboratorium komputer',
    },
    {
      'idPengajuan': 3,
      'matkul': 'Basis Data',
      'dosen': 'Dr. Ahmad Fauzi, M.Kom',
      'jamAlpha': 4,
      'tanggal': '10 Apr 2026',
      'status': 'menunggu_ttd_kaprodi',
      'namaLokasi': 'Lab Komputer A',
      'latitude': -7.9398,
      'longitude': 112.6165,
      'deskripsiTugas': 'Membantu persiapan UAS Basis Data',
    },
  ];

  bool _isSelesai(String status) => status == 'selesai';

  bool _isAktif(String status) => !_isSelesai(status);

  Color _statusBgColor(String status) {
    switch (status) {
      case 'selesai': return const Color(0xFFE8F5E9);
      case 'menunggu_ttd_kaprodi': return const Color(0xFFEDE7F6);
      case 'menunggu_ttd_dosen':
      case 'menunggu_ttd_admin': return const Color(0xFFFFF8E1);
      default: return const Color(0xFFF5F5F5);
    }
  }

  Color _statusTextColor(String status) {
    switch (status) {
      case 'selesai': return const Color(0xFF2E7D32);
      case 'menunggu_ttd_kaprodi': return const Color(0xFF6A1B9A);
      case 'menunggu_ttd_dosen':
      case 'menunggu_ttd_admin': return const Color(0xFFF57F17);
      default: return _textGrey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'selesai': return Icons.check_circle_outline;
      case 'menunggu_ttd_kaprodi': return Icons.verified_outlined;
      case 'menunggu_ttd_dosen':
      case 'menunggu_ttd_admin': return Icons.draw_outlined;
      default: return Icons.pending_outlined;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'selesai': return 'Selesai';
      case 'menunggu_ttd_dosen': return 'Menunggu TTD Dosen';
      case 'menunggu_ttd_admin': return 'Menunggu TTD Admin';
      case 'menunggu_ttd_kaprodi': return 'Menunggu TTD Kaprodi';
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final aktif = _pengajuanList.where((e) => _isAktif(e['status'])).toList();
    final selesai = _pengajuanList.where((e) => _isSelesai(e['status'])).toList();

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
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D2D2D)),
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
                        // Sedang Berjalan
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

                        // Kompen Selesai
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
                          ...selesai.map((item) =>
                              _buildCard(context, item, isSelesai: true)),
                        ],

                        if (aktif.isEmpty && selesai.isEmpty)
                          _buildEmptyState(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppBottomNav(
            activeTab: NavTab.tracking,
            onTabSelected: (tab) =>
                NavMahasiswa.handleBottomNav(context, tab, NavTab.tracking),
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
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: countTextColor),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, Map<String, dynamic> item,
      {bool isSelesai = false}) {
    final status = item['status'] as String;
    final jamAlpha = item['jamAlpha'] as int;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TrackingScreen(
            idPengajuan: item['idPengajuan'],
            matkul: item['matkul'],
            namaDosen: item['dosen'],
            jamAlpha: item['jamAlpha'],
            status: item['status'],
            namaLokasi: item['namaLokasi'],
            latitude: item['latitude'],
            longitude: item['longitude'],
            deskripsiTugas: item['deskripsiTugas'],
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelesai ? Colors.white.withOpacity(0.7) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelesai
              ? Border.all(color: const Color(0xFFE0E0E0))
              : null,
          boxShadow: isSelesai
              ? []
              : [
                  const BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.06),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Matkul + badge status
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
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF9E9E9E)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusBgColor(status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon(status),
                          size: 12, color: _statusTextColor(status)),
                      const SizedBox(width: 4),
                      Text(
                        _statusLabel(status),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _statusTextColor(status),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Jam alpha
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isSelesai
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFFCE8E8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelesai
                        ? Icons.verified_outlined
                        : Icons.timer_outlined,
                    size: 16,
                    color: isSelesai
                        ? const Color(0xFF2E7D32)
                        : _primaryRed,
                  ),
                  const SizedBox(width: 6),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          fontSize: 12, color: _textDark),
                      children: [
                        TextSpan(
                          text: '$jamAlpha Jam Alpha ',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isSelesai
                                ? const Color(0xFF2E7D32)
                                : _primaryRed,
                            fontSize: 13,
                          ),
                        ),
                        TextSpan(
                          text: isSelesai
                              ? 'berhasil dikompensasi'
                              : 'perlu dikompensasi',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Tanggal + arrow
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: Color(0xFF9E9E9E)),
                const SizedBox(width: 4),
                Text(
                  item['tanggal'],
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF9E9E9E)),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelesai
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFCE8E8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: isSelesai
                        ? const Color(0xFF2E7D32)
                        : _primaryRed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(Icons.track_changes_outlined,
                size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            const Text(
              'Belum ada tracking',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9E9E9E)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ajukan TTD dulu dari halaman Pengajuan',
              style:
                  TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
            ),
          ],
        ),
      ),
    );
  }
}