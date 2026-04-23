import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
import '../widgets/app_bottom_nav.dart';
import '../utils/nav_mahasiswa.dart';


const _red = Color(0xFFB71C1C);
const _cream = Color(0xFFF5EFE6);
const _dark = Color(0xFF2D2D2D);
const _grey = Color(0xFF9E9E9E);
const _fieldBg = Color(0xFFF8F4EE);
const _fieldBorder = Color(0xFFE8E0D5);

// ── Model pengajuan
class _Pengajuan {
  String mataKuliah, namaDosen, tanggal, deskripsi;
  int jam;
  // Field lanjutan (dilengkapi setelah kompen selesai)
  String jenisPekerjaan, nip;

  _Pengajuan({
    required this.mataKuliah,
    required this.namaDosen,
    required this.tanggal,
    required this.deskripsi,
    required this.jam,
    this.jenisPekerjaan = '',
    this.nip = '',
  });

  // Form dianggap lengkap untuk TTD jika field lanjutan sudah diisi
  bool get isLengkap => jenisPekerjaan.isNotEmpty && nip.isNotEmpty;
}

// ── Dummy data
final _dummyList = [
  _Pengajuan(
    mataKuliah: 'Basis Data',
    namaDosen: 'Dr. Ahmad Fauzi, M.Kom',
    tanggal: '08 Apr 2026',
    deskripsi: 'Menyiapkan modul praktikum basis data semester genap',
    jam: 2,
    jenisPekerjaan: 'Membantu laboran',
    nip: '197501012005011001',
  ),
  _Pengajuan(
    mataKuliah: 'Jaringan Komputer',
    namaDosen: 'Ir. Budi Santoso, M.T',
    tanggal: '25 Mar 2026',
    deskripsi: 'Merapikan kabel jaringan di laboratorium komputer',
    jam: 1,
    // belum dilengkapi untuk TTD
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
  final _formKey = GlobalKey<FormState>();

  // Controllers form awal (sesuai UC-06)
  String? _selectedMK;
  String? _selectedTujuan;
  final _dosenCtrl = TextEditingController();
  final _tglCtrl = TextEditingController();
  final _jamCtrl = TextEditingController();
  final _deskripsiCtrl = TextEditingController();

  @override
  void dispose() {
    _dosenCtrl.dispose(); _tglCtrl.dispose();
    _jamCtrl.dispose(); _deskripsiCtrl.dispose();
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
                  child: Form(
                    key: _formKey,
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
                        _formCard(),
                        const SizedBox(height: 16),
                        _submitButton(),
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
          ),
          AppBottomNav(
            activeTab: NavTab.pengajuan,
            onTabSelected: (tab) =>
                NavMahasiswa.handleBottomNav(context, tab, NavTab.pengajuan),
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

  // ── Form card (sesuai UC-06)
  Widget _formCard() => Container(
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
      const Text('Isi semua field sebelum mengajukan',
          style: TextStyle(fontSize: 11, color: _grey)),
      const SizedBox(height: 16),

      // Mata Kuliah
      _formDropdown(
        label: 'Mata Kuliah',
        hint: 'Pilih mata kuliah yang di-alpha',
        icon: Icons.menu_book_outlined,
        value: _selectedMK,
        items: const ['Basis Data', 'Pemrograman Web', 'Jaringan Komputer', 'Analisis Sistem'],
        onChanged: (v) => setState(() => _selectedMK = v),
        errorMsg: 'Mata kuliah wajib dipilih',
      ),
      const SizedBox(height: 14),

      // Nama Dosen
      _formField(
        label: 'Nama Dosen Pengampu',
        hint: 'Masukkan nama dosen pengampu',
        icon: Icons.person_outlined,
        controller: _dosenCtrl,
        errorMsg: 'Nama dosen wajib diisi',
      ),
      const SizedBox(height: 14),

      // Tujuan pengajuan (ke Dosen / Admin) — UC-05 keputusan
      _formDropdown(
        label: 'Tujuan Pengajuan',
        hint: 'Pilih tujuan pengajuan',
        icon: Icons.send_outlined,
        value: _selectedTujuan,
        items: const ['Ke Dosen', 'Ke Admin'],
        onChanged: (v) => setState(() => _selectedTujuan = v),
        errorMsg: 'Tujuan pengajuan wajib dipilih',
      ),
      const SizedBox(height: 14),

      // Tanggal pertemuan
      _formDateField(),
      const SizedBox(height: 14),

      // Total jam
      _formField(
        label: 'Total Jam yang Dibayar',
        hint: 'Contoh: 2',
        icon: Icons.access_time_outlined,
        controller: _jamCtrl,
        isNumber: true,
        suffix: 'jam',
        errorMsg: 'Jumlah jam wajib diisi',
      ),
      const SizedBox(height: 14),

      // Deskripsi tugas
      _formTextArea(
        label: 'Deskripsi Tugas Kompen',
        hint: 'Jelaskan jenis pekerjaan kompensasi yang akan dilakukan...',
        controller: _deskripsiCtrl,
        errorMsg: 'Deskripsi tugas wajib diisi',
      ),
    ]),
  );

  Widget _fieldLabel(String t) =>
      Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _grey));

  // Dropdown dengan validasi
  Widget _formDropdown({
    required String label,
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    required String errorMsg,
  }) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _fieldLabel(label),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          validator: (v) => (v == null || v.isEmpty) ? errorMsg : null,
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: _grey),
            filled: true,
            fillColor: _fieldBg,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _fieldBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _fieldBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _red, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
          ),
          hint: Text(hint, style: const TextStyle(fontSize: 13, color: _grey)),
          items: items.map((e) => DropdownMenuItem(
            value: e,
            child: Text(e, style: const TextStyle(fontSize: 13, color: _dark)),
          )).toList(),
          icon: const Icon(Icons.keyboard_arrow_down, color: _grey),
        ),
      ]);

  // Text field dengan validasi
  Widget _formField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required String errorMsg,
    bool isNumber = false,
    String? suffix,
  }) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _fieldLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(fontSize: 13, color: _dark),
          validator: (v) => (v == null || v.trim().isEmpty) ? errorMsg : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: _grey),
            prefixIcon: Icon(icon, size: 18, color: _grey),
            suffixText: suffix,
            suffixStyle: const TextStyle(fontSize: 13, color: _grey),
            filled: true,
            fillColor: _fieldBg,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _fieldBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _fieldBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _red, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
          ),
        ),
      ]);

  // Date field dengan validasi
  Widget _formDateField() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _fieldLabel('Tanggal Pertemuan'),
    const SizedBox(height: 6),
    TextFormField(
      controller: _tglCtrl,
      readOnly: true,
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Tanggal pertemuan wajib diisi' : null,
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2024),
          lastDate: DateTime.now(),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(primary: _red),
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          setState(() {
            _tglCtrl.text =
                '${picked.day.toString().padLeft(2, '0')} ${_bulan(picked.month)} ${picked.year}';
          });
        }
      },
      style: const TextStyle(fontSize: 13, color: _dark),
      decoration: InputDecoration(
        hintText: 'Pilih tanggal pertemuan...',
        hintStyle: const TextStyle(fontSize: 13, color: _grey),
        prefixIcon: const Icon(Icons.calendar_today_outlined, size: 18, color: _grey),
        suffixIcon: const Icon(Icons.keyboard_arrow_down, color: _grey),
        filled: true,
        fillColor: _fieldBg,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _fieldBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _fieldBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _red, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
      ),
    ),
  ]);

  // Textarea dengan validasi
  Widget _formTextArea({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String errorMsg,
  }) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _fieldLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: 4,
          style: const TextStyle(fontSize: 13, color: _dark),
          validator: (v) => (v == null || v.trim().isEmpty) ? errorMsg : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: _grey),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 60),
              child: Icon(Icons.description_outlined, size: 18, color: _grey),
            ),
            filled: true,
            fillColor: _fieldBg,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _fieldBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _fieldBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _red, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
          ),
        ),
      ]);

  String _bulan(int m) => ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'][m - 1];

  // ── Submit button
  Widget _submitButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: _handleSubmit,
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

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      // Ada field kosong — Form sudah tampilkan error masing-masing field
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Row(children: [
          Icon(Icons.warning_amber_outlined, color: Colors.white, size: 18),
          SizedBox(width: 10),
          Text('Lengkapi semua field terlebih dahulu!',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ]),
        duration: const Duration(seconds: 2),
      ));
      return;
    }
    _showSubmitDialog();
  }

  void _showSubmitDialog() => showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Konfirmasi Pengajuan',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: _dark)),
      content: const Text(
        'Data pengajuan akan dikirim. Setelah kompen selesai dikerjakan, kamu bisa melengkapi form untuk mengajukan TTD.',
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
                mataKuliah: _selectedMK ?? '-',
                namaDosen: _dosenCtrl.text.trim(),
                tanggal: _tglCtrl.text.trim(),
                deskripsi: _deskripsiCtrl.text.trim(),
                jam: int.tryParse(_jamCtrl.text.trim()) ?? 0,
              ));
              // Reset form
              _selectedMK = null;
              _selectedTujuan = null;
              _dosenCtrl.clear(); _tglCtrl.clear();
              _jamCtrl.clear(); _deskripsiCtrl.clear();
              _formKey.currentState!.reset();
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
      // Header
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p.mataKuliah,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _dark)),
          const SizedBox(height: 2),
          Text(p.namaDosen, style: const TextStyle(fontSize: 12, color: _grey)),
        ])),
        // Badge kelengkapan untuk TTD
        _badgeLengkap(p.isLengkap),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        _chip(Icons.calendar_today_outlined, p.tanggal),
        const SizedBox(width: 12),
        _chip(Icons.access_time_outlined, '${p.jam} Jam'),
      ]),
      const SizedBox(height: 6),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.description_outlined, size: 13, color: _grey),
        const SizedBox(width: 4),
        Expanded(child: Text(p.deskripsi,
            maxLines: 2, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: _grey, height: 1.4))),
      ]),
      if (p.isLengkap) ...[
        const SizedBox(height: 6),
        _chip(Icons.work_outline, p.jenisPekerjaan),
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
      if (!p.isLengkap) ...[
        const SizedBox(height: 8),
        const Row(children: [
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
      Text(lengkap ? 'Siap TTD' : 'Belum Lengkap',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
              color: lengkap ? const Color(0xFF2E7D32) : const Color(0xFFE65100))),
    ]),
  );

  Widget _chip(IconData icon, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 13, color: _grey), const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 11, color: _grey)),
  ]);

  // ── Dialog edit (lengkapi form untuk TTD)
  void _showEditDialog(_Pengajuan p) {
    final pekerjaanCtrl = TextEditingController(text: p.jenisPekerjaan);
    final nipCtrl = TextEditingController(text: p.nip);
    final editKey = GlobalKey<FormState>();

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
          child: Form(
            key: editKey,
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text('Lengkapi Form — ${p.mataKuliah}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _dark)),
              const Text('Isi detail pekerjaan setelah kompen selesai dikerjakan',
                  style: TextStyle(fontSize: 12, color: _grey)),
              const SizedBox(height: 16),
              // NIP Dosen
              _fieldLabel('NIP Dosen'),
              const SizedBox(height: 6),
              TextFormField(
                controller: nipCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 13, color: _dark),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'NIP wajib diisi' : null,
                decoration: _inputDeco('Masukkan NIP dosen', Icons.badge_outlined),
              ),
              const SizedBox(height: 14),
              // Jenis pekerjaan
              _fieldLabel('Jenis Pekerjaan Kompen'),
              const SizedBox(height: 6),
              TextFormField(
                controller: pekerjaanCtrl,
                style: const TextStyle(fontSize: 13, color: _dark),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Jenis pekerjaan wajib diisi' : null,
                decoration: _inputDeco('Contoh: Membantu laboran', Icons.work_outline),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (!editKey.currentState!.validate()) return;
                    setState(() {
                      p.nip = nipCtrl.text.trim();
                      p.jenisPekerjaan = pekerjaanCtrl.text.trim();
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
      ),
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
    hintText: hint, hintStyle: const TextStyle(fontSize: 13, color: _grey),
    prefixIcon: Icon(icon, size: 18, color: _grey),
    filled: true, fillColor: _fieldBg,
    contentPadding: const EdgeInsets.symmetric(vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _fieldBorder)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _fieldBorder)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _red, width: 1.5)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
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