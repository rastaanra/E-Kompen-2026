import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'home_screen.dart';
import '../widgets/app_header.dart';
import '../widgets/app_bottom_nav.dart';

// ── Konstanta warna
const _red = Color(0xFFB71C1C);
const _cream = Color(0xFFF5EFE6);
const _dark = Color(0xFF2D2D2D);
const _grey = Color(0xFF9E9E9E);
const _fieldBg = Color(0xFFF8F4EE);
const _fieldBorder = Color(0xFFE8E0D5);

// ── Model
class _Item {
  final String mataKuliah, dosen, tanggal, deskripsi, status;
  final int jam;
  const _Item(this.mataKuliah, this.dosen, this.tanggal, this.jam, this.deskripsi, this.status);
}

const _dummyData = [
  _Item('Basis Data', 'Dr. Ahmad Fauzi, M.Kom', '08 Apr 2026', 2,
      'Membantu laboran menyiapkan modul praktikum basis data', 'Menunggu Validasi Kaprodi'),
  _Item('Pemrograman Web', 'Luqman Affandi, S.Kom., MMSI', '01 Apr 2026', 3,
      'Membuat dokumentasi teknis modul login sistem informasi', 'Selesai'),
  _Item('Jaringan Komputer', 'Ir. Budi Santoso, M.T', '25 Mar 2026', 1,
      'Merapikan kabel jaringan di laboratorium komputer', 'Sedang Dikerjakan'),
];

// ── Status helpers
Color _statusColor(String s) => switch (s) {
  'Selesai' => const Color(0xFF2E7D32),
  'Sedang Dikerjakan' => const Color(0xFF1565C0),
  'Menunggu Validasi Kaprodi' => const Color(0xFF6A1B9A),
  'Menunggu TTD Dosen' => const Color(0xFFE65100),
  _ => _grey,
};
Color _statusBg(String s) => switch (s) {
  'Selesai' => const Color(0xFFE8F5E9),
  'Sedang Dikerjakan' => const Color(0xFFE3F2FD),
  'Menunggu Validasi Kaprodi' => const Color(0xFFF3E5F5),
  'Menunggu TTD Dosen' => const Color(0xFFFFF3E0),
  _ => const Color(0xFFF5F5F5),
};
IconData _statusIcon(String s) => switch (s) {
  'Selesai' => Icons.check_circle_outline,
  'Sedang Dikerjakan' => Icons.construction_outlined,
  'Menunggu Validasi Kaprodi' => Icons.approval_outlined,
  'Menunggu TTD Dosen' => Icons.draw_outlined,
  _ => Icons.schedule_outlined,
};
int _statusStep(String s) => switch (s) {
  'Menunggu Konfirmasi' => 0,
  'Sedang Dikerjakan' => 1,
  'Menunggu TTD Dosen' => 2,
  'Menunggu Validasi Kaprodi' => 3,
  'Selesai' => 4,
  _ => 0,
};

// ────────────────────────────────────────────
class PengajuanKompenScreen extends StatefulWidget {
  const PengajuanKompenScreen({super.key});
  @override
  State<PengajuanKompenScreen> createState() => _State();
}

class _State extends State<PengajuanKompenScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _red,
      floatingActionButton: ListenableBuilder(
        listenable: _tab,
        builder: (_, __) => _tab.index == 1
            ? FloatingActionButton.extended(
                onPressed: () => _tab.animateTo(0),
                backgroundColor: _red,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Ajukan Baru',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              )
            : const SizedBox.shrink(),
      ),
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: _cream,
                borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
              ),
              child: Column(
                children: [
                  _pageHeader(),
                  _tabBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tab,
                      children: [_formTab(), _riwayatTab()],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppBottomNav(
            activeTab: NavTab.pengajuan,
            onTabSelected: (t) {
              if (t == NavTab.home) Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomeScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _pageHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Pengajuan Kompen',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _dark)),
      const SizedBox(height: 4),
      const Text('Ajukan kompensasi kehadiran kamu di sini',
          style: TextStyle(fontSize: 13, color: _grey)),
      const SizedBox(height: 16),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFB71C1C), Color(0xFFD32F2F)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: _red.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          _alphaStat('Total Jam Alpha', '12 Jam'),
          Container(width: 1, height: 40, color: Colors.white24),
          _alphaStat('Sudah Dikompensasi', '4 Jam'),
          Container(width: 1, height: 40, color: Colors.white24),
          _alphaStat('Sisa Alpha', '8 Jam'),
        ]),
      ),
      const SizedBox(height: 4),
    ]),
  );

  Widget _alphaStat(String label, String value) => Expanded(
    child: Column(children: [
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 10)),
    ]),
  );

  Widget _tabBar() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    child: Container(
      decoration: BoxDecoration(color: const Color(0xFFEDE8DF), borderRadius: BorderRadius.circular(12)),
      child: TabBar(
        controller: _tab,
        indicator: BoxDecoration(color: _red, borderRadius: BorderRadius.circular(10)),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: _grey,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.all(4),
        tabs: const [Tab(text: 'Ajukan Kompen'), Tab(text: 'Riwayat')],
      ),
    ),
  );

  // ── TAB 1: Form
  Widget _formTab() => ScrollConfiguration(
    behavior: const ScrollBehavior().copyWith(overscroll: false),
    child: SingleChildScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFCC02)),
          ),
          child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.info_outline, color: Color(0xFFF59E0B), size: 18),
            SizedBox(width: 10),
            Expanded(child: Text(
              'Pastikan kamu sudah menemui dosen secara langsung (offline) sebelum mengajukan kompen melalui aplikasi ini.',
              style: TextStyle(fontSize: 12, color: Color(0xFF92400E), height: 1.5),
            )),
          ]),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Detail Pengajuan',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _dark)),
            const SizedBox(height: 14),
            _dropdown('Mata Kuliah', 'Pilih mata kuliah yang di-alpha', Icons.menu_book_outlined,
                ['Basis Data', 'Pemrograman Web', 'Jaringan Komputer', 'Analisis Sistem']),
            const SizedBox(height: 14),
            _dropdown('Ajukan Kepada', 'Pilih dosen atau admin', Icons.person_outlined,
                ['Dr. Ahmad Fauzi, M.Kom', 'Luqman Affandi, S.Kom., MMSI', 'Ir. Budi Santoso, M.T', 'Admin JTI']),
            const SizedBox(height: 14),
            _fieldLabel('Tanggal Pertemuan Dosen'),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(color: _fieldBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _fieldBorder)),
              child: const Row(children: [
                Icon(Icons.calendar_today_outlined, size: 18, color: _grey),
                SizedBox(width: 10),
                Expanded(child: Text('Pilih tanggal...', style: TextStyle(fontSize: 13, color: _grey))),
                Icon(Icons.keyboard_arrow_down, color: _grey),
              ]),
            ),
            const SizedBox(height: 14),
            _fieldLabel('Jumlah Jam yang Dibayar'),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(color: _fieldBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _fieldBorder)),
              child: const TextField(
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 13, color: _dark),
                decoration: InputDecoration(
                  hintText: 'Contoh: 2', hintStyle: TextStyle(fontSize: 13, color: _grey),
                  prefixIcon: Icon(Icons.access_time_outlined, size: 18, color: _grey),
                  suffixText: 'jam', suffixStyle: TextStyle(fontSize: 13, color: _grey),
                  border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _fieldLabel('Deskripsi Tugas Kompen'),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(color: _fieldBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _fieldBorder)),
              child: const TextField(
                maxLines: 4,
                style: TextStyle(fontSize: 13, color: _dark),
                decoration: InputDecoration(
                  hintText: 'Jelaskan jenis pekerjaan kompensasi yang akan dilakukan...',
                  hintStyle: TextStyle(fontSize: 13, color: _grey),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.description_outlined, size: 18, color: _grey),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _showSubmitDialog,
            icon: const Icon(Icons.send_outlined, color: Colors.white, size: 18),
            label: const Text('Ajukan Kompen',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _red,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
      ]),
    ),
  );

  Widget _fieldLabel(String t) =>
      Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _grey));

  Widget _dropdown(String label, String hint, IconData icon, List<String> items) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _fieldLabel(label),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(color: _fieldBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _fieldBorder)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Row(children: [
                Icon(icon, size: 18, color: _grey), const SizedBox(width: 10),
                Text(hint, style: const TextStyle(fontSize: 13, color: _grey)),
              ]),
              items: items.map((e) => DropdownMenuItem(
                value: e,
                child: Row(children: [
                  Icon(icon, size: 18, color: _red), const SizedBox(width: 10),
                  Text(e, style: const TextStyle(fontSize: 13, color: _dark)),
                ]),
              )).toList(),
              onChanged: (_) {},
              icon: const Icon(Icons.keyboard_arrow_down, color: _grey),
            ),
          ),
        ),
      ]);

  void _showSubmitDialog() => showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Konfirmasi Pengajuan',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: _dark)),
      content: const Text(
        'Pastikan data yang kamu isi sudah benar. Pengajuan akan dikirim ke dosen/admin untuk dikonfirmasi.',
        style: TextStyle(fontSize: 13, color: _grey, height: 1.5),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(ctx),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: _red),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          ),
          child: const Text('Batal', style: TextStyle(color: _red, fontWeight: FontWeight.w600)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: const Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: const Row(children: [
                Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text('Pengajuan berhasil dikirim!',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ]),
              duration: const Duration(seconds: 3),
            ));
            _tab.animateTo(1);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _red,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            elevation: 0,
          ),
          child: const Text('Ajukan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ],
    ),
  );

  // ── TAB 2: Riwayat
  Widget _riwayatTab() => ScrollConfiguration(
    behavior: const ScrollBehavior().copyWith(overscroll: false),
    child: SingleChildScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        children: _dummyData.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _riwayatCard(item),
        )).toList(),
      ),
    ),
  );

  Widget _riwayatCard(_Item item) {
    final sc = _statusColor(item.status);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.mataKuliah,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _dark)),
              const SizedBox(height: 3),
              Text(item.dosen, style: const TextStyle(fontSize: 12, color: _grey)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: _statusBg(item.status), borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(_statusIcon(item.status), size: 12, color: sc),
                const SizedBox(width: 4),
                Text(item.status, style: TextStyle(fontSize: 10, color: sc, fontWeight: FontWeight.w600)),
              ]),
            ),
          ]),
        ),
        const Divider(height: 1, thickness: 0.5, color: Color(0xFFF0EBE0), indent: 16, endIndent: 16),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          child: Column(children: [
            Row(children: [
              _chip(Icons.calendar_today_outlined, item.tanggal),
              const SizedBox(width: 12),
              _chip(Icons.access_time_outlined, '${item.jam} Jam'),
            ]),
            const SizedBox(height: 8),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.description_outlined, size: 14, color: _grey),
              const SizedBox(width: 6),
              Expanded(child: Text(item.deskripsi,
                  style: const TextStyle(fontSize: 12, color: _grey, height: 1.4))),
            ]),
            if (item.status == 'Sedang Dikerjakan') ...[
              const SizedBox(height: 12),
              _actionBtn('Isi Form Digital Penyelesaian', Icons.edit_note_outlined, () {}),
            ],
            if (item.status == 'Selesai') ...[
              const SizedBox(height: 12),
              _actionBtn('Unduh Bukti Kompen', Icons.download_outlined, () {}, outlined: true),
            ],
          ]),
        ),
        _progressTracker(item.status),
      ]),
    );
  }

  Widget _chip(IconData icon, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 13, color: _grey), const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 12, color: _grey)),
  ]);

  Widget _actionBtn(String label, IconData icon, VoidCallback onTap, {bool outlined = false}) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
    final pad = const EdgeInsets.symmetric(vertical: 10);
    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 16, color: _red),
              label: Text(label, style: const TextStyle(fontSize: 13, color: _red, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: _red), shape: shape, padding: pad),
            )
          : ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 16, color: Colors.white),
              label: Text(label, style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(backgroundColor: _red, shape: shape, padding: pad, elevation: 0),
            ),
    );
  }

  Widget _progressTracker(String status) {
    const steps = ['Diajukan', 'Dikerjakan', 'TTD Dosen', 'Validasi\nKaprodi', 'Selesai'];
    final cur = _statusStep(status);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F4EE),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final done = (i - 1) ~/ 2 < cur;
            return Expanded(child: Container(height: 2, color: done ? _red : const Color(0xFFDDD6CC)));
          }
          final idx = i ~/ 2;
          final done = idx <= cur;
          final current = idx == cur;
          return Column(children: [
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                color: done ? _red : const Color(0xFFDDD6CC),
                shape: BoxShape.circle,
                border: current ? Border.all(color: _red.withOpacity(0.3), width: 3) : null,
              ),
              child: Icon(done ? Icons.check : Icons.circle, color: Colors.white, size: done ? 12 : 6),
            ),
            const SizedBox(height: 4),
            Text(steps[idx], textAlign: TextAlign.center,
                style: TextStyle(fontSize: 9, color: done ? _red : _grey,
                    fontWeight: current ? FontWeight.w700 : FontWeight.normal)),
          ]);
        }),
      ),
    );
  }
}