import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';
import '../../widgets/dosen/app_bottom_nav_dosen.dart';
import '../../utils/nav_dosen.dart';
import '../../utils/session_manager.dart';
import '../../services/pengajuan_service.dart'; 
import '../../models/pengajuan_kompen.dart';    
import 'pengajuan_screen.dart';
import '../../services/notifikasi_service.dart';
import '../../views/notifikasi/notifikasi_screen.dart';
// Jika file verifikasi_screen.dart belum kamu buat, silakan komen/hapus baris import di bawah ini:
// import 'verifikasi_screen.dart';

class DosenHomeScreen extends StatefulWidget {
  const DosenHomeScreen({super.key});

  @override
  State<DosenHomeScreen> createState() => _DosenHomeScreenState();
}

class _DosenHomeScreenState extends State<DosenHomeScreen> {
  List<PengajuanKompen> pengajuanList = [];
  bool hasUnreadNotif = false;
  int jumlahPengajuan = 0;
  int jumlahVerifikasi = 0;
  int totalMahasiswa = 0;
  int totalDisetujui = 0;
  int totalMenunggu = 0;
  int totalSelesai = 0;

  static const Color _primaryRed = Color(0xFFB71C1C);
  static const Color _backgroundCream = Color(0xFFF5EFE6);
  static const Color _cardBeige = Color(0xFFEDE0CC);
  static const Color _textDark = Color(0xFF2D2D2D);
  static const Color _textGrey = Color(0xFF9E9E9E);
  String namaDosen = 'Dosen'; 

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadDataDariAPI(); 
    _loadNotif();
  }

  Future<void> _loadNotif() async {
    try {
      final idPengguna = await SessionManager.getIdPengguna();

      if (idPengguna == null) return;

      final notif =
          await NotifikasiService().getNotifikasi(idPengguna);

      setState(() {
        hasUnreadNotif =
            notif.any((n) => n.sudahDilihat == false);
      });
    } catch (e) {
      debugPrint('Notif error: $e');
    }
  }

  Future<void> _loadUser() async {
    final nama = await SessionManager.getNamaLengkap();
    if (nama != null && nama.isNotEmpty) {
      setState(() {
        namaDosen = nama;
      });
    }
  }

  Future<void> _loadDataDariAPI() async {
    try {
      final idDosen = await SessionManager.getIdDosen();
      if (idDosen == null) return;
      
      final data = await PengajuanService().getPengajuanDosen(idDosen);

      setState(() {
        pengajuanList = data;

        // 1. Menghitung pengajuan yang berstatus 'pending' (Menunggu Persetujuan) seperti di screen pengajuan
        jumlahPengajuan = data.where((p) => p.status == 'pending').length;
        
        // 2. Menghitung jumlah tindakan Tanda Tangan Penyelesaian
        jumlahVerifikasi = data.where((p) => p.status == 'menunggu_ttd_dosen').length;

        // 3. 🟢 PERBAIKAN: Menggunakan NIM atau namaMahasiswa untuk menghitung total Unik Mahasiswa agar tidak merah
        totalMahasiswa = data.map((p) => p.nim ?? p.namaMahasiswa).toSet().length;

        // 4. Hitung data rekapitulasi berdasarkan kondisi status kompen
        totalDisetujui = data.where((p) => p.status != 'pending').length;
        totalMenunggu = data.where((p) => p.status == 'pending' || p.status == 'menunggu_ttd_dosen').length;
        totalSelesai = data.where((p) => p.status == 'selesai').length;
      });
    } catch (e) {
      debugPrint("Gagal memuat data API Dosen: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryRed,
      body: Column(
        children: [
      AppHeader(
        hasUnreadNotif: hasUnreadNotif,
        onNotifTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NotifikasiScreen(),
            ),
          );

          _loadNotif(); // refresh badge
        },
      ), 
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
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('PERLU TINDAKAN'),
                          const SizedBox(height: 12),
                          _buildActionCard(
                            context: context,
                            icon: Icons.list_alt_outlined,
                            label: 'Konfirmasi Pengajuan',
                            count: jumlahPengajuan,
                            emptyText: 'Tidak ada pengajuan',
                            onTap: () => NavDosen.toPengajuan(context),
                          ),
                          const SizedBox(height: 12),
                          _buildActionCard(
                            context: context,
                            icon: Icons.draw_outlined,
                            label: 'Tanda Tangan Penyelesaian',
                            count: jumlahVerifikasi,
                            emptyText: 'Tidak ada form',
                            onTap: () {
                              // Navigasi dialihkan sementara jika verifikasi_screen belum ada
                              // atau tetap menggunakan fungsi NavDosen milikmu
                              NavDosen.handleBottomNav(context, NavTabDosen.pengajuan, NavTabDosen.home);
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildSectionTitle('REKAPITULASI'),
                          const SizedBox(height: 12),
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
          AppBottomNavDosen(
            activeTab: NavTabDosen.home,
            onTabSelected: (tab) =>
                NavDosen.handleBottomNav(context, tab, NavTabDosen.home),
          ),
        ],
      ),
    );
  }

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
              children: [
                Text(
                  'Halo, $namaDosen', 
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Dosen Pengampu',
                  style: TextStyle(fontSize: 14, color: _textGrey),
                ),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(183, 28, 28, 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              Positioned(top: -8, left: 6, child: _buildDocIcon()),
              Positioned(top: 4, left: 28, child: _buildDocIcon()),
              Positioned(
                bottom: -6,
                right: -4,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: _primaryRed,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocIcon() {
    return Container(
      width: 52,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(7),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            5,
            (i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Container(
                height: 4,
                width: i == 0 ? 32.0 : i == 2 ? 24.0 : 28.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: _textDark,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int count,
    required String emptyText,
    required VoidCallback onTap,
  }) {
    final bool hasAction = count > 0;
    
    final Color bgColor = hasAction ? _primaryRed : const Color(0xFFBDB5A6);
    final Color iconBg = hasAction ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.3);
    final Color iconColor = hasAction ? Colors.white : const Color(0xFF7A6F65);
    final Color labelColor = hasAction ? Colors.white.withOpacity(0.75) : const Color(0xFF8A7F75);
    final Color valueColor = hasAction ? Colors.white : const Color(0xFF7A6F65);
    final Color arrowColor = hasAction ? Colors.white.withOpacity(0.8) : const Color(0xFFA09890);

    return GestureDetector(
      onTap: hasAction ? onTap : null, 
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 11, color: labelColor)),
                  const SizedBox(height: 2),
                  Text(
                    hasAction ? '$count Pengajuan' : emptyText,
                    style: TextStyle(
                      fontSize: hasAction ? 16 : 14,
                      fontWeight: hasAction ? FontWeight.w700 : FontWeight.w600,
                      color: valueColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: arrowColor, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildRekapitulasiSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildRekapCard(label: 'Total Mahasiswa', value: '$totalMahasiswa Orang')),
            const SizedBox(width: 12),
            Expanded(child: _buildRekapCard(label: 'Disetujui', value: '$totalDisetujui Pengajuan')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildRekapCard(label: 'Menunggu', value: '$totalMenunggu Pengajuan')),
            const SizedBox(width: 12),
            Expanded(child: _buildRekapCard(label: 'Selesai', value: '$totalSelesai Pengajuan')),
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
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: _textDark),
          ),
        ],
      ),
    );
  }

  
}