import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../widgets/app_header.dart';
import '../widgets/app_bottom_nav.dart';

const _red = Color(0xFFB71C1C);
const _cream = Color(0xFFF5EFE6);
const _dark = Color(0xFF2D2D2D);
const _grey = Color(0xFF9E9E9E);
const _fieldBg = Color(0xFFF8F4EE);
const _fieldBorder = Color(0xFFE8E0D5);

class PengajuanKompenScreen extends StatelessWidget {
  const PengajuanKompenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _red,
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: _cream,
                borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
              ),
              child: ScrollConfiguration(
                behavior: const ScrollBehavior().copyWith(overscroll: false),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul
                      const Text('Pengajuan Kompen',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _dark)),
                      const SizedBox(height: 4),
                      const Text('Ajukan kompensasi kehadiran kamu di sini',
                          style: TextStyle(fontSize: 13, color: _grey)),
                      const SizedBox(height: 16),

                      // Summary card alpha
                      _alphaSummaryCard(),
                      const SizedBox(height: 20),

                      // Info banner
                      _infoBanner(),
                      const SizedBox(height: 16),

                      // Form card
                      _formCard(),
                      const SizedBox(height: 20),

                      // Tombol submit
                      _submitButton(context),
                    ],
                  ),
                ),
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

  // ── Summary card
  Widget _alphaSummaryCard() => Container(
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
  );

  Widget _alphaStat(String label, String value) => Expanded(
    child: Column(children: [
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 10)),
    ]),
  );

  // ── Info banner
  Widget _infoBanner() => Container(
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
  );

  // ── Form card
  Widget _formCard() => Container(
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

  // ── Submit button
  Widget _submitButton(BuildContext context) => SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: () => _showSubmitDialog(context),
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
  );

  void _showSubmitDialog(BuildContext context) => showDialog(
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
}