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

// ── Model pengajuan
class _Pengajuan {
  // Field awal
  String mataKuliah, namaDosen, nip, tanggal;
  // Field lanjutan (dilengkapi setelah kompen selesai)
  String jenisPekerjaan, deskripsi;
  int jam;

  _Pengajuan({
    required this.mataKuliah,
    required this.namaDosen,
    required this.nip,
    required this.tanggal,
    this.jenisPekerjaan = '',
    this.deskripsi = '',
    this.jam = 0,
  });

  // Form dianggap lengkap jika semua field lanjutan sudah diisi
  bool get isLengkap =>
      jenisPekerjaan.isNotEmpty && deskripsi.isNotEmpty && jam > 0;
}

// ── Dummy data
final _dummyList = [
  _Pengajuan(
    mataKuliah: 'Basis Data',
    namaDosen: 'Dr. Ahmad Fauzi, M.Kom',
    nip: '197501012005011001',
    tanggal: '08 Apr 2026',
    jenisPekerjaan: 'Membantu laboran',
    deskripsi: 'Menyiapkan modul praktikum basis data semester genap',
    jam: 2,
  ),
  _Pengajuan(
    mataKuliah: 'Jaringan Komputer',
    namaDosen: 'Ir. Budi Santoso, M.T',
    nip: '198203152010011002',
    tanggal: '25 Mar 2026',
    // belum dilengkapi
  ),
];

// ────────────────────────────────────────────
class PengajuanKompenScreen extends StatefulWidget {
  const PengajuanKompenScreen({super.key});
  @override
  State<PengajuanKompenScreen> createState() => _State();
}

class _State extends State<PengajuanKompenScreen> {
  final List<_Pengajuan> _list = _dummyList;

  // Controllers form awal
  final _mkCtrl = TextEditingController();
  final _dosenCtrl = TextEditingController();
  final _nipCtrl = TextEditingController();
  final _tglCtrl = TextEditingController();

  @override
  void dispose() {
    _mkCtrl.dispose(); _dosenCtrl.dispose();
    _nipCtrl.dispose(); _tglCtrl.dispose();
    super.dispose();
  }

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
                      const Text('Pengajuan Kompen',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _dark)),
                      const SizedBox(height: 4),
                      const Text('Ajukan kompensasi kehadiran kamu di sini',
                          style: TextStyle(fontSize: 13, color: _grey)),
                      const SizedBox(height: 16),
                      _alphaSummaryCard(),
                      const SizedBox(height: 20),
                      _infoBanner(),
                      const SizedBox(height: 16),
                      _formAwalCard(),
                      const SizedBox(height: 16),
                      _submitButton(),
                      // List pengajuan
                      if (_list.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        const Text('Pengajuan Saya',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _dark)),
                        const SizedBox(height: 10),
                        ..._list.map((p) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _pengajuanCard(p),
                        )),
                      ],
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

  // ── Alpha summary
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

  // ── Form awal (data dasar)
  Widget _formAwalCard() => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
    ),
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Data Pengajuan',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _dark)),
      const SizedBox(height: 4),
      const Text('Isi data awal sebelum melakukan kompen',
          style: TextStyle(fontSize: 11, color: _grey)),
      const SizedBox(height: 14),
      _dropdown('Mata Kuliah', 'Pilih mata kuliah yang di-alpha', Icons.menu_book_outlined,
          ['Basis Data', 'Pemrograman Web', 'Jaringan Komputer', 'Analisis Sistem']),
      const SizedBox(height: 14),
      _inputField('Nama Dosen / Admin', 'Masukkan nama dosen atau admin',
          Icons.person_outlined, _dosenCtrl),
      const SizedBox(height: 14),
      _inputField('NIP Dosen / Admin', 'Masukkan NIP',
          Icons.badge_outlined, _nipCtrl, isNumber: true),
      const SizedBox(height: 14),
      _fieldLabel('Tanggal Pertemuan'),
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
    ]),
  );

  Widget _fieldLabel(String t) =>
      Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _grey));

  Widget _inputField(String label, String hint, IconData icon, TextEditingController ctrl,
      {bool isNumber = false}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _fieldLabel(label),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(color: _fieldBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _fieldBorder)),
          child: TextField(
            controller: ctrl,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: const TextStyle(fontSize: 13, color: _dark),
            decoration: InputDecoration(
              hintText: hint, hintStyle: const TextStyle(fontSize: 13, color: _grey),
              prefixIcon: Icon(icon, size: 18, color: _grey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ]);

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
  Widget _submitButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: () => _showSubmitDialog(),
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

  void _showSubmitDialog() => showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Konfirmasi Pengajuan',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: _dark)),
      content: const Text(
        'Data awal pengajuan akan dikirim. Kamu bisa melengkapi detail pekerjaan setelah kompen selesai dikerjakan.',
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
            setState(() {
              _list.add(_Pengajuan(
                mataKuliah: 'Mata Kuliah Baru',
                namaDosen: _dosenCtrl.text.isEmpty ? 'Nama Dosen' : _dosenCtrl.text,
                nip: _nipCtrl.text.isEmpty ? '-' : _nipCtrl.text,
                tanggal: 'Hari ini',
              ));
            });
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

  // ── Card list pengajuan
  Widget _pengajuanCard(_Pengajuan p) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
    ),
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Header: nama MK + badge kelengkapan
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p.mataKuliah,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _dark)),
          const SizedBox(height: 2),
          Text(p.namaDosen, style: const TextStyle(fontSize: 12, color: _grey)),
        ])),
        _badgeLengkap(p.isLengkap),
      ]),
      const SizedBox(height: 10),
      // Info NIP & tanggal
      Row(children: [
        _chip(Icons.badge_outlined, 'NIP: ${p.nip}'),
        const SizedBox(width: 12),
        _chip(Icons.calendar_today_outlined, p.tanggal),
      ]),
      // Preview data lanjutan kalau sudah diisi
      if (p.isLengkap) ...[
        const SizedBox(height: 8),
        Row(children: [
          _chip(Icons.access_time_outlined, '${p.jam} Jam'),
          const SizedBox(width: 12),
          _chip(Icons.work_outline, p.jenisPekerjaan),
        ]),
      ],
      const SizedBox(height: 12),
      const Divider(height: 1, thickness: 0.5, color: Color(0xFFF0EBE0)),
      const SizedBox(height: 12),
      // Tombol aksi
      Row(children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showEditDialog(p),
            icon: const Icon(Icons.edit_outlined, size: 15, color: _red),
            label: const Text('Edit', style: TextStyle(fontSize: 13, color: _red, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _red),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: p.isLengkap ? () => _showAjukanTTDDialog(p) : null,
            icon: Icon(Icons.draw_outlined, size: 15,
                color: p.isLengkap ? Colors.white : _grey),
            label: Text('Ajukan TTD',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                    color: p.isLengkap ? Colors.white : _grey)),
            style: ElevatedButton.styleFrom(
              backgroundColor: p.isLengkap ? _red : const Color(0xFFE0E0E0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 10),
              elevation: 0,
            ),
          ),
        ),
      ]),
      // Hint kalau belum lengkap
      if (!p.isLengkap) ...[
        const SizedBox(height: 8),
        Row(children: const [
          Icon(Icons.lock_outline, size: 12, color: _grey),
          SizedBox(width: 4),
          Text('Lengkapi form terlebih dahulu untuk mengajukan TTD',
              style: TextStyle(fontSize: 11, color: _grey)),
        ]),
      ],
    ]),
  );

  Widget _badgeLengkap(bool lengkap) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: lengkap ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(lengkap ? Icons.check_circle_outline : Icons.edit_note_outlined,
          size: 12, color: lengkap ? const Color(0xFF2E7D32) : const Color(0xFFE65100)),
      const SizedBox(width: 4),
      Text(lengkap ? 'Lengkap' : 'Belum Lengkap',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
              color: lengkap ? const Color(0xFF2E7D32) : const Color(0xFFE65100))),
    ]),
  );

  Widget _chip(IconData icon, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 13, color: _grey), const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 11, color: _grey)),
  ]);

  // ── Dialog edit (lengkapi form)
  void _showEditDialog(_Pengajuan p) {
    final pekerjaanCtrl = TextEditingController(text: p.jenisPekerjaan);
    final deskripsiCtrl = TextEditingController(text: p.deskripsi);
    final jamCtrl = TextEditingController(text: p.jam > 0 ? '${p.jam}' : '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Handle bar
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Lengkapi Form — ${p.mataKuliah}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _dark)),
            const Text('Isi detail pekerjaan setelah kompen selesai dikerjakan',
                style: TextStyle(fontSize: 12, color: _grey)),
            const SizedBox(height: 16),
            _fieldLabel('Jenis Pekerjaan Kompen'),
            const SizedBox(height: 6),
            _rawInput('Contoh: Membantu laboran', pekerjaanCtrl, Icons.work_outline),
            const SizedBox(height: 14),
            _fieldLabel('Jumlah Jam Kompensasi'),
            const SizedBox(height: 6),
            _rawInput('Contoh: 2', jamCtrl, Icons.access_time_outlined, isNumber: true, suffix: 'jam'),
            const SizedBox(height: 14),
            _fieldLabel('Deskripsi Pekerjaan'),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(color: _fieldBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _fieldBorder)),
              child: TextField(
                controller: deskripsiCtrl,
                maxLines: 3,
                style: const TextStyle(fontSize: 13, color: _dark),
                decoration: const InputDecoration(
                  hintText: 'Jelaskan detail pekerjaan yang sudah dilakukan...',
                  hintStyle: TextStyle(fontSize: 13, color: _grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    p.jenisPekerjaan = pekerjaanCtrl.text.trim();
                    p.deskripsi = deskripsiCtrl.text.trim();
                    p.jam = int.tryParse(jamCtrl.text.trim()) ?? 0;
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: const Color(0xFF1565C0),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    content: const Row(children: [
                      Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                      SizedBox(width: 10),
                      Text('Form berhasil dilengkapi!',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ]),
                    duration: const Duration(seconds: 2),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Simpan', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _rawInput(String hint, TextEditingController ctrl, IconData icon,
      {bool isNumber = false, String? suffix}) =>
      Container(
        decoration: BoxDecoration(color: _fieldBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _fieldBorder)),
        child: TextField(
          controller: ctrl,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(fontSize: 13, color: _dark),
          decoration: InputDecoration(
            hintText: hint, hintStyle: const TextStyle(fontSize: 13, color: _grey),
            prefixIcon: Icon(icon, size: 18, color: _grey),
            suffixText: suffix, suffixStyle: const TextStyle(fontSize: 13, color: _grey),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      );

  // ── Dialog ajukan TTD
  void _showAjukanTTDDialog(_Pengajuan p) => showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Ajukan Tanda Tangan Digital',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: _dark)),
      content: Text(
        'Form kompen ${p.mataKuliah} akan dikirim ke ${p.namaDosen} untuk ditandatangani secara digital.',
        style: const TextStyle(fontSize: 13, color: _grey, height: 1.5),
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
              backgroundColor: const Color(0xFF6A1B9A),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: const Row(children: [
                Icon(Icons.draw_outlined, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text('Pengajuan TTD berhasil dikirim!',
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
          child: const Text('Kirim', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ],
    ),
  );
}