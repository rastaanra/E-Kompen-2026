import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../widgets/app_header.dart';
import '../widgets/app_bottom_nav.dart';

// ── Model data pengajuan
class _PengajuanItem {
  final String mataKuliah;
  final String dosen;
  final String tanggal;
  final int jamKompen;
  final String deskripsiTugas;
  final String status; // 'Menunggu Konfirmasi', 'Sedang Dikerjakan', 'Menunggu TTD Dosen', 'Menunggu Validasi Kaprodi', 'Selesai'

  const _PengajuanItem({
    required this.mataKuliah,
    required this.dosen,
    required this.tanggal,
    required this.jamKompen,
    required this.deskripsiTugas,
    required this.status,
  });
}

class PengajuanKompenScreen extends StatefulWidget {
  const PengajuanKompenScreen({super.key});

  @override
  State<PengajuanKompenScreen> createState() => _PengajuanKompenScreenState();
}

class _PengajuanKompenScreenState extends State<PengajuanKompenScreen>
    with SingleTickerProviderStateMixin {
  static const Color _primaryRed = Color(0xFFB71C1C);
  static const Color _backgroundCream = Color(0xFFF5EFE6);
  static const Color _textDark = Color(0xFF2D2D2D);
  static const Color _textGrey = Color(0xFF9E9E9E);

  late TabController _tabController;

  // Dummy data riwayat pengajuan
  final List<_PengajuanItem> _riwayat = const [
    _PengajuanItem(
      mataKuliah: 'Basis Data',
      dosen: 'Dr. Ahmad Fauzi, M.Kom',
      tanggal: '08 Apr 2026',
      jamKompen: 2,
      deskripsiTugas: 'Membantu laboran menyiapkan modul praktikum basis data',
      status: 'Menunggu Validasi Kaprodi',
    ),
    _PengajuanItem(
      mataKuliah: 'Pemrograman Web',
      dosen: 'Luqman Affandi, S.Kom., MMSI',
      tanggal: '01 Apr 2026',
      jamKompen: 3,
      deskripsiTugas: 'Membuat dokumentasi teknis modul login sistem informasi',
      status: 'Selesai',
    ),
    _PengajuanItem(
      mataKuliah: 'Jaringan Komputer',
      dosen: 'Ir. Budi Santoso, M.T',
      tanggal: '25 Mar 2026',
      jamKompen: 1,
      deskripsiTugas: 'Merapikan kabel jaringan di laboratorium komputer',
      status: 'Sedang Dikerjakan',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                children: [
                  // ── Judul halaman + ringkasan alpha
                  _buildPageHeader(),
                  // ── Tab bar
                  _buildTabBar(),
                  // ── Tab content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildFormTab(),
                        _buildRiwayatTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppBottomNav(
            activeTab: NavTab.kompen,
            onTabSelected: (tab) {
              if (tab == NavTab.home) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              }
            },
          ),
        ],
      ),
      // FAB untuk ajukan kompen baru (di tab riwayat)
      floatingActionButton: ValueListenableBuilder<TabController>(
        valueListenable: _tabController.animation!.toValueListenable(),
        builder: (_, __, ___) {
          return _tabController.index == 1
              ? FloatingActionButton.extended(
                  onPressed: () =>
                      _tabController.animateTo(0),
                  backgroundColor: _primaryRed,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Ajukan Baru',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }

  // ── Header ringkasan alpha
  Widget _buildPageHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pengajuan Kompen',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ajukan kompensasi kehadiran kamu di sini',
            style: TextStyle(fontSize: 13, color: _textGrey),
          ),
          const SizedBox(height: 16),
          // Ringkasan alpha card
          _buildAlphaSummaryCard(),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildAlphaSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB71C1C), Color(0xFFD32F2F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB71C1C).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildAlphaStat('Total Jam Alpha', '12 Jam'),
          ),
          Container(width: 1, height: 40, color: Colors.white24),
          Expanded(
            child: _buildAlphaStat('Sudah Dikompensasi', '4 Jam'),
          ),
          Container(width: 1, height: 40, color: Colors.white24),
          Expanded(
            child: _buildAlphaStat('Sisa Alpha', '8 Jam'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlphaStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // ── Tab bar
  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEDE8DF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: _primaryRed,
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: _textGrey,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          dividerColor: Colors.transparent,
          padding: const EdgeInsets.all(4),
          tabs: const [
            Tab(text: 'Ajukan Kompen'),
            Tab(text: 'Riwayat'),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TAB 1: Form Pengajuan
  // ─────────────────────────────────────────────
  Widget _buildFormTab() {
    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: false),
      child: SingleChildScrollView(
        physics:
            const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner hybrid workflow
            _buildInfoBanner(),
            const SizedBox(height: 16),
            // Form card
            _buildFormCard(),
            const SizedBox(height: 16),
            // Tombol submit
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFCC02), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFF59E0B), size: 18),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Pastikan kamu sudah menemui dosen secara langsung (offline) sebelum mengajukan kompen melalui aplikasi ini.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF92400E),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel('Detail Pengajuan'),
            const SizedBox(height: 14),
            // Pilih Mata Kuliah
            _buildDropdownField(
              label: 'Mata Kuliah',
              hint: 'Pilih mata kuliah yang di-alpha',
              icon: Icons.menu_book_outlined,
              items: const [
                'Basis Data',
                'Pemrograman Web',
                'Jaringan Komputer',
                'Analisis Sistem',
              ],
            ),
            const SizedBox(height: 14),
            // Pilih Tujuan (Dosen / Admin)
            _buildDropdownField(
              label: 'Ajukan Kepada',
              hint: 'Pilih dosen atau admin',
              icon: Icons.person_outlined,
              items: const [
                'Dr. Ahmad Fauzi, M.Kom',
                'Luqman Affandi, S.Kom., MMSI',
                'Ir. Budi Santoso, M.T',
                'Admin JTI',
              ],
            ),
            const SizedBox(height: 14),
            // Tanggal pertemuan
            _buildDateField(
              label: 'Tanggal Pertemuan Dosen',
              icon: Icons.calendar_today_outlined,
            ),
            const SizedBox(height: 14),
            // Jam kompen
            _buildNumberField(
              label: 'Jumlah Jam yang Dibayar',
              hint: 'Contoh: 2',
              icon: Icons.access_time_outlined,
            ),
            const SizedBox(height: 14),
            // Deskripsi tugas
            _buildTextAreaField(
              label: 'Deskripsi Tugas Kompen',
              hint:
                  'Jelaskan jenis pekerjaan kompensasi yang akan dilakukan...',
              icon: Icons.description_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: _textDark,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required IconData icon,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textGrey,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F4EE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8E0D5)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Row(
                children: [
                  Icon(icon, size: 18, color: _textGrey),
                  const SizedBox(width: 10),
                  Text(
                    hint,
                    style: const TextStyle(fontSize: 13, color: _textGrey),
                  ),
                ],
              ),
              items: items
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Row(
                          children: [
                            Icon(icon, size: 18, color: _primaryRed),
                            const SizedBox(width: 10),
                            Text(item,
                                style: const TextStyle(
                                    fontSize: 13, color: _textDark)),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (_) {},
              icon: const Icon(Icons.keyboard_arrow_down, color: _textGrey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({required String label, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textGrey,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F4EE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8E0D5)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: _textGrey),
              const SizedBox(width: 10),
              const Text(
                'Pilih tanggal...',
                style: TextStyle(fontSize: 13, color: _textGrey),
              ),
              const Spacer(),
              const Icon(Icons.keyboard_arrow_down, color: _textGrey),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textGrey,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F4EE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8E0D5)),
          ),
          child: TextField(
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 13, color: _textDark),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 13, color: _textGrey),
              prefixIcon: Icon(icon, size: 18, color: _textGrey),
              suffixText: 'jam',
              suffixStyle:
                  const TextStyle(fontSize: 13, color: _textGrey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextAreaField({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textGrey,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F4EE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8E0D5)),
          ),
          child: TextField(
            maxLines: 4,
            style: const TextStyle(fontSize: 13, color: _textDark),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 13, color: _textGrey),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Icon(icon, size: 18, color: _textGrey),
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showSubmitDialog(),
        icon: const Icon(Icons.send_outlined, color: Colors.white, size: 18),
        label: const Text(
          'Ajukan Kompen',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryRed,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  void _showSubmitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Konfirmasi Pengajuan',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: _textDark,
          ),
        ),
        content: const Text(
          'Pastikan data yang kamu isi sudah benar sebelum mengajukan. Pengajuan ini akan dikirim ke dosen/admin untuk dikonfirmasi.',
          style: TextStyle(fontSize: 13, color: _textGrey, height: 1.5),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _primaryRed),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            child: const Text('Batal',
                style: TextStyle(
                    color: _primaryRed, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showSuccessSnackbar();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryRed,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              elevation: 0,
            ),
            child: const Text('Ajukan',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text(
              'Pengajuan berhasil dikirim!',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
    _tabController.animateTo(1);
  }

  // ─────────────────────────────────────────────
  // TAB 2: Riwayat Pengajuan
  // ─────────────────────────────────────────────
  Widget _buildRiwayatTab() {
    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: false),
      child: SingleChildScrollView(
        physics:
            const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          children: _riwayat
              .map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildRiwayatCard(item),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildRiwayatCard(_PengajuanItem item) {
    final statusColor = _getStatusColor(item.status);
    final statusBg = _getStatusBg(item.status);
    final statusIcon = _getStatusIcon(item.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header kartu
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.mataKuliah,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.dosen,
                        style: const TextStyle(
                            fontSize: 12, color: _textGrey),
                      ),
                    ],
                  ),
                ),
                // Badge status
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        item.status,
                        style: TextStyle(
                          fontSize: 10,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            thickness: 0.5,
            color: Color(0xFFF0EBE0),
            indent: 16,
            endIndent: 16,
          ),
          // Detail info
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildDetailChip(
                        Icons.calendar_today_outlined, item.tanggal),
                    const SizedBox(width: 12),
                    _buildDetailChip(Icons.access_time_outlined,
                        '${item.jamKompen} Jam'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.description_outlined,
                        size: 14, color: _textGrey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.deskripsiTugas,
                        style: const TextStyle(
                            fontSize: 12,
                            color: _textGrey,
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
                // Tombol aksi berdasarkan status
                if (item.status == 'Sedang Dikerjakan') ...[
                  const SizedBox(height: 12),
                  _buildActionButton(
                    label: 'Isi Form Digital Penyelesaian',
                    icon: Icons.edit_note_outlined,
                    onTap: () {},
                  ),
                ],
                if (item.status == 'Selesai') ...[
                  const SizedBox(height: 12),
                  _buildActionButton(
                    label: 'Unduh Bukti Kompen',
                    icon: Icons.download_outlined,
                    onTap: () {},
                    isOutlined: true,
                  ),
                ],
              ],
            ),
          ),
          // Progress tracker
          _buildProgressTracker(item.status),
        ],
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: _textGrey),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: _textGrey),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isOutlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: isOutlined
          ? OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 16, color: _primaryRed),
              label: Text(
                label,
                style: const TextStyle(
                    fontSize: 13,
                    color: _primaryRed,
                    fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _primaryRed),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            )
          : ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 16, color: Colors.white),
              label: Text(
                label,
                style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryRed,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                elevation: 0,
              ),
            ),
    );
  }

  // Progress tracker horizontal
  Widget _buildProgressTracker(String currentStatus) {
    const steps = [
      'Diajukan',
      'Dikerjakan',
      'TTD Dosen',
      'Validasi\nKaprodi',
      'Selesai',
    ];
    const statusToStep = {
      'Menunggu Konfirmasi': 0,
      'Sedang Dikerjakan': 1,
      'Menunggu TTD Dosen': 2,
      'Menunggu Validasi Kaprodi': 3,
      'Selesai': 4,
    };
    final currentStep = statusToStep[currentStatus] ?? 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F4EE),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            // Connector line
            final stepIndex = (index - 1) ~/ 2;
            final isDone = stepIndex < currentStep;
            return Expanded(
              child: Container(
                height: 2,
                color: isDone ? _primaryRed : const Color(0xFFDDD6CC),
              ),
            );
          }
          final stepIndex = index ~/ 2;
          final isDone = stepIndex <= currentStep;
          final isCurrent = stepIndex == currentStep;
          return Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isDone ? _primaryRed : const Color(0xFFDDD6CC),
                  shape: BoxShape.circle,
                  border: isCurrent
                      ? Border.all(
                          color: _primaryRed.withOpacity(0.3), width: 3)
                      : null,
                ),
                child: Icon(
                  isDone ? Icons.check : Icons.circle,
                  color: Colors.white,
                  size: isDone ? 12 : 6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[stepIndex],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  color: isDone ? _primaryRed : _textGrey,
                  fontWeight:
                      isCurrent ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Selesai':
        return const Color(0xFF2E7D32);
      case 'Sedang Dikerjakan':
        return const Color(0xFF1565C0);
      case 'Menunggu Validasi Kaprodi':
        return const Color(0xFF6A1B9A);
      case 'Menunggu TTD Dosen':
        return const Color(0xFFE65100);
      default: // Menunggu Konfirmasi
        return const Color(0xFF9E9E9E);
    }
  }

  Color _getStatusBg(String status) {
    switch (status) {
      case 'Selesai':
        return const Color(0xFFE8F5E9);
      case 'Sedang Dikerjakan':
        return const Color(0xFFE3F2FD);
      case 'Menunggu Validasi Kaprodi':
        return const Color(0xFFF3E5F5);
      case 'Menunggu TTD Dosen':
        return const Color(0xFFFFF3E0);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Selesai':
        return Icons.check_circle_outline;
      case 'Sedang Dikerjakan':
        return Icons.construction_outlined;
      case 'Menunggu Validasi Kaprodi':
        return Icons.approval_outlined;
      case 'Menunggu TTD Dosen':
        return Icons.draw_outlined;
      default:
        return Icons.schedule_outlined;
    }
  }
}

// Extension helper untuk ValueListenable di FAB
extension on Animation<double> {
  ValueListenable<double> toValueListenable() => _AnimationValueListenable(this);
}

class _AnimationValueListenable extends ValueNotifier<double> {
  final Animation<double> _animation;
  _AnimationValueListenable(this._animation) : super(_animation.value) {
    _animation.addListener(_update);
  }
  void _update() => value = _animation.value;
  @override
  void dispose() {
    _animation.removeListener(_update);
    super.dispose();
  }
}