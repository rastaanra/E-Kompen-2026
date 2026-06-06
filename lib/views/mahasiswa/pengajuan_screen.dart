import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/mahasiswa/app_bottom_nav.dart';
import '../../utils/nav_mahasiswa.dart';
import '../../providers/pengajuan_provider.dart';
import '../../models/pengajuan_kompen.dart';
import '../../utils/session_manager.dart';
import 'map_picker_view.dart';

const _red = Color(0xFFB71C1C);
const _cream = Color(0xFFF5EFE6);
const _dark = Color(0xFF2D2D2D);
const _grey = Color(0xFF9E9E9E);
const _fieldBg = Color(0xFFF8F4EE);
const _fieldBorder = Color(0xFFE8E0D5);

class PengajuanScreen extends StatefulWidget {
  const PengajuanScreen({super.key});

  @override
  State<PengajuanScreen> createState() => _PengajuanScreenState();
}

class _PengajuanScreenState extends State<PengajuanScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedMK;
  String? _selectedTujuan;
  String? _selectedSemester;
  String? _selectedDosen;
  final _dosenCtrl = TextEditingController();
  final _tglCtrl = TextEditingController();
  final _jamCtrl = TextEditingController();
  double? _selectedLat;
  double? _selectedLng;
  String? _selectedNamaLokasi;

  @override
  void initState() {
    super.initState();
    _loadPengajuan();
    _loadMataKuliah();
    _loadDosen();
    _loadAdmin();
  }

  Future<void> _loadPengajuan() async {
    final idMahasiswa = await SessionManager.getIdMahasiswa();
    if (idMahasiswa != null && mounted) {
      context.read<PengajuanProvider>().getAllPengajuan(idMahasiswa);
    }
  }

  Future<void> _loadMataKuliah() async {
    final idMahasiswa = await SessionManager.getIdMahasiswa();
    if (idMahasiswa != null && mounted) {
      context.read<PengajuanProvider>().getMataKuliah(idMahasiswa);
    }
  }

  Future<void> _loadDosen() async {
    await context.read<PengajuanProvider>().getDosen();
    print(context.read<PengajuanProvider>().dosen.length);
  }

Future<void> _loadAdmin() async {
  try {
    print('LOAD ADMIN START');
    await context.read<PengajuanProvider>().getAdmin();
    print('LOAD ADMIN DONE: ${context.read<PengajuanProvider>().admin?.idAdmin}');
  } catch (e) {
    print('LOAD ADMIN ERROR: $e');
  }
}

  String _getMatkul(int? idMataKuliah) {
    final provider = context.read<PengajuanProvider>();
    try {
      return provider.mataKuliah
          .firstWhere((e) => e.idMataKuliah == idMataKuliah)
          .namaMk;
    } catch (_) {
      return 'Mata Kuliah';
    }
  }

  String _getNamaDosen(int? idDosen) {
    final provider = context.read<PengajuanProvider>();
    try {
      return provider.dosen
          .firstWhere((e) => e.idDosen == idDosen)
          .namaLengkap;
    } catch (_) {
      return 'Dosen';
    }
  }

  @override
  void dispose() {
    _dosenCtrl.dispose();
    _tglCtrl.dispose();
    _jamCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PengajuanProvider>();
    if (provider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final listTampil =
        provider.listPengajuan.where((p) => !p.sudahAjukanTTD).toList();

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
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pengajuan Kompen',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: _dark),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Ajukan kompensasi kehadiran kamu disini',
                        style: TextStyle(fontSize: 13, color: _grey),
                      ),
                      const SizedBox(height: 16),
                      _buildAjukanButton(),
                      const SizedBox(height: 24),
                      if (listTampil.isNotEmpty) ...[
                        const Text(
                          'Daftar Pengajuan Saya',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _dark),
                        ),
                        const SizedBox(height: 12),
                        ...listTampil.map((p) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildPengajuanCard(p),
                            )),
                      ] else
                        _buildEmptyState(),
                    ],
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

  Widget _buildAjukanButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showFormAjukanBottomSheet(),
        icon: const Icon(Icons.add, color: Colors.white, size: 20),
        label: const Text(
          'Ajukan Kompen',
          style: TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _red,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildPengajuanCard(PengajuanKompen p) {
    final matkul = _getMatkul(p.idMataKuliah);
    final namaDosen = p.namaTujuan ?? '-';
    final sudahLengkap = p.isLengkap;
    final sudahAjukan = p.sudahAjukanTTD;

    final List<String> fieldKurang = [];
    if (p.totalJamKompen == null) fieldKurang.add('Durasi jam');
    if (p.deskripsiTugas == null || p.deskripsiTugas!.isEmpty)
      fieldKurang.add('Deskripsi');
    if (p.namaLokasi == null || p.namaLokasi!.isEmpty)
      fieldKurang.add('Lokasi');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(matkul,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _dark)),
                    const SizedBox(height: 2),
                    Text(namaDosen,
                        style: const TextStyle(fontSize: 12, color: _grey)),
                  ],
                ),
              ),
              _buildStatusBadge(p.status),
            ],
          ),
          const SizedBox(height: 10),
          if (fieldKurang.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              children: fieldKurang
                  .map((f) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFFCDD2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.close, size: 10, color: _red),
                            const SizedBox(width: 3),
                            Text(f,
                                style: const TextStyle(
                                    fontSize: 10, color: _red)),
                          ],
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              _chip(Icons.calendar_today_outlined,
                  _formatTanggal(p.tanggalPertemuan)),
              const SizedBox(width: 12),
              _chip(Icons.access_time_outlined,
                  p.totalJamKompen != null ? '${p.totalJamKompen} Jam' : '- Jam'),
            ],
          ),
          const SizedBox(height: 6),
          if (p.deskripsiTugas != null && p.deskripsiTugas!.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.description_outlined, size: 13, color: _grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    p.deskripsiTugas!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(fontSize: 11, color: _grey, height: 1.4),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFF0EBE0)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: (!sudahAjukan &&
                          (p.status == 'sedang_dikerjakan' ||
                              p.status == 'siap_diajukan'))
                      ? () => _showLengkapiBottomSheet(p)
                      : null,
                  icon: Icon(Icons.edit_outlined,
                      size: 15,
                      color: (!sudahAjukan &&
                              (p.status == 'sedang_dikerjakan' ||
                                  p.status == 'siap_diajukan'))
                          ? _red
                          : _grey),
                  label: Text(
                    'Lengkapi',
                    style: TextStyle(
                        fontSize: 13,
                        color: (!sudahAjukan &&
                                (p.status == 'sedang_dikerjakan' ||
                                    p.status == 'siap_diajukan'))
                            ? _red
                            : _grey,
                        fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: (!sudahAjukan &&
                                (p.status == 'sedang_dikerjakan' ||
                                    p.status == 'siap_diajukan'))
                            ? _red
                            : Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (sudahLengkap && !sudahAjukan)
                      ? () => _showAjukanTTDDialog(p, matkul, namaDosen)
                      : null,
                  icon: Icon(
                    (!sudahLengkap && !sudahAjukan)
                        ? Icons.lock_outline
                        : Icons.draw_outlined,
                    size: 15,
                    color:
                        (sudahLengkap && !sudahAjukan) ? Colors.white : _grey,
                  ),
                  label: Text(
                    'Ajukan TTD',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: (sudahLengkap && !sudahAjukan)
                          ? Colors.white
                          : _grey,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (sudahLengkap && !sudahAjukan)
                        ? _red
                        : const Color(0xFFE0E0E0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          if (p.status == 'pending') ...[
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFCC02)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.hourglass_empty,
                      size: 13, color: Color(0xFFF59E0B)),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Menunggu konfirmasi dosen/admin sebelum bisa dilengkapi',
                      style:
                          TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (!sudahLengkap && !sudahAjukan) ...[
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFCC02)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 13, color: Color(0xFFF59E0B)),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Lengkapi form dulu sebelum bisa mengajukan TTD',
                      style:
                          TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showFormAjukanBottomSheet() {
    // Reset state form setiap kali buka
    _selectedMK = null;
    _selectedTujuan = null;
    _selectedSemester = null;
    _selectedDosen = null;
    _tglCtrl.clear();
    _jamCtrl.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // ── KUNCI: StatefulBuilder agar if/else _selectedTujuan bisa rebuild
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Form Pengajuan Kompen',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _dark)),
                    const Text('Edit pengajuan form kompensasi kehadiran kamu',
                        style: TextStyle(fontSize: 12, color: _grey)),
                    const SizedBox(height: 16),

                    // ── Mata Kuliah
                    _fieldLabel('Mata Kuliah'),
                    const SizedBox(height: 6),
                    Consumer<PengajuanProvider>(
                      builder: (context, provider, child) {
                        return _buildDropdown(
                          hint: 'Cari mata kuliah...',
                          icon: Icons.search,
                          value: _selectedMK,
                          items: provider.mataKuliah
                              .map((mk) => mk.namaMk)
                              .toList(),
                          onChanged: (v) =>
                              setSheetState(() => _selectedMK = v),
                          errorMsg: 'Mata kuliah wajib dipilih',
                        );
                      },
                    ),
                    const SizedBox(height: 14),

                    // ── Tujuan Pengajuan
                    _fieldLabel('Tujuan Pengajuan'),
                    const SizedBox(height: 6),
                    _buildDropdown(
                      hint: 'Pilih tujuan pengajuan',
                      icon: Icons.send_outlined,
                      value: _selectedTujuan,
                      items: const ['Dosen', 'Admin'],
                      onChanged: (v) {
                        setSheetState(() {
                          _selectedTujuan = v;
                          _selectedDosen = null; // reset saat ganti tujuan
                        });
                      },
                      errorMsg: 'Tujuan pengajuan wajib dipilih',
                    ),
                    const SizedBox(height: 14),

                    // ── Kondisional: Dosen atau Admin
                    if (_selectedTujuan == 'Dosen') ...[
                      _fieldLabel('Nama Dosen yang Dituju'),
                      const SizedBox(height: 6),
                      Consumer<PengajuanProvider>(
                        builder: (context, provider, child) {
                          return _buildDropdown(
                            hint: 'Pilih dosen...',
                            icon: Icons.person_outline,
                            value: _selectedDosen,
                            items: provider.dosen
                                .map((d) => d.namaLengkap)
                                .toList(),
                            onChanged: (v) =>
                                setSheetState(() => _selectedDosen = v),
                            errorMsg: 'Dosen wajib dipilih',
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                    ] else if (_selectedTujuan == 'Admin') ...[
                      _fieldLabel('Admin Tujuan'),
                      const SizedBox(height: 6),
                      Consumer<PengajuanProvider>(
                        builder: (context, provider, child) {
                          return TextFormField(
                            initialValue: provider.admin?.nama ?? '',
                            readOnly: true,
                            style:
                                const TextStyle(fontSize: 13, color: _dark),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.admin_panel_settings_outlined,
                                size: 18,
                                color: _grey,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF0EBE3),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: _fieldBorder),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: _fieldBorder),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: _fieldBorder),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                    ],

                    // ── Semester
                    _fieldLabel('Semester'),
                    const SizedBox(height: 6),
                    _buildDropdown(
                      hint: 'Pilih semester',
                      icon: Icons.school_outlined,
                      value: _selectedSemester,
                      items: const ['1', '2', '3', '4', '5', '6', '7', '8'],
                      onChanged: (v) =>
                          setSheetState(() => _selectedSemester = v),
                      errorMsg: 'Semester wajib dipilih',
                    ),
                    const SizedBox(height: 14),

                    // ── Tanggal Pertemuan
                    _fieldLabel('Tanggal Pertemuan'),
                    const SizedBox(height: 6),
                    _buildDateField(onChanged: () => setSheetState(() {})),
                    const SizedBox(height: 14),

                    // ── Total Jam
                    _fieldLabel('Total Jam'),
                    const SizedBox(height: 6),
                    _buildTextField(
                      hint: 'Masukkan total jam...',
                      icon: Icons.access_time_outlined,
                      controller: _jamCtrl,
                      isNumber: true,
                      errorMsg: 'Total jam wajib diisi',
                    ),
                    const SizedBox(height: 14),

                    // ── Info belum bisa diisi
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFFCC02)),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline,
                              color: Color(0xFFF59E0B), size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Belum bisa diisi sekarang\nSilahkan kirim form pengajuan kompen terlebih dahulu. Deskripsi tugas & lokasi bisa dilengkapi setelah pengajuan diterima.',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF92400E),
                                  height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Deskripsi & Lokasi (disabled)
                    _fieldLabel('Deskripsi Tugas Kompen', disabled: true),
                    const SizedBox(height: 6),
                    _buildDisabledField('Tersedia nanti.'),
                    const SizedBox(height: 14),
                    _fieldLabel('Lokasi Pengerjaan', disabled: true),
                    const SizedBox(height: 6),
                    _buildDisabledField('Tersedia nanti.'),
                    const SizedBox(height: 20),

                    // ── Tombol Kirim
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _handleKirimForm(ctx),
                        icon: const Icon(Icons.upload_outlined,
                            color: Colors.white, size: 18),
                        label: const Text('Kirim Form',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLengkapiBottomSheet(PengajuanKompen p) {
    final matkul = _getMatkul(p.idMataKuliah);
    final deskripsiCtrl = TextEditingController(text: p.deskripsiTugas ?? '');
    final lokasiCtrl = TextEditingController(text: p.namaLokasi ?? '');
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Lengkapi Form — $matkul',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _dark)),
                  const Text(
                      'Isi detail pekerjaan setelah kompen selesai dikerjakan',
                      style: TextStyle(fontSize: 12, color: _grey)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Sekarang sudah bisa diisi',
                        style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 16),
                  _fieldLabel('Deskripsi Tugas Kompen'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: deskripsiCtrl,
                    maxLength: 255,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 13, color: _dark),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Deskripsi wajib diisi';
                      if (v.trim().length < 10)
                        return 'Deskripsi minimal 10 karakter';
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Contoh: Menyiapkan modul praktikum...',
                      hintStyle:
                          const TextStyle(fontSize: 13, color: _grey),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 40),
                        child: Icon(Icons.edit_outlined,
                            size: 18, color: _grey),
                      ),
                      filled: true,
                      fillColor: _fieldBg,
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 14),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: _fieldBorder)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: _fieldBorder)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: _red, width: 1.5)),
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Colors.redAccent)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _fieldLabel('Lokasi Pengerjaan'),
                  const SizedBox(height: 6),
                  StatefulBuilder(
                    builder: (ctx, setLocal) => GestureDetector(
                      onTap: () async {
                        final result =
                            await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MapPickerView()),
                        );
                        if (result != null) {
                          setState(() {
                            _selectedLat = result['lat'];
                            _selectedLng = result['lng'];
                            _selectedNamaLokasi = result['nama'];
                          });
                          setLocal(() {});
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _red),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                color: _red, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedNamaLokasi ??
                                        (p.namaLokasi != null &&
                                                p.namaLokasi!.isNotEmpty
                                            ? p.namaLokasi!
                                            : 'Tandai Lokasi Pengerjaan'),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: (_selectedNamaLokasi !=
                                                  null ||
                                              (p.namaLokasi != null &&
                                                  p.namaLokasi!.isNotEmpty))
                                          ? _dark
                                          : _red,
                                    ),
                                  ),
                                  Text(
                                    _selectedLat != null
                                        ? '${_selectedLat!.toStringAsFixed(4)}, ${_selectedLng!.toStringAsFixed(4)}'
                                        : 'Tap untuk membuka peta & memilih lokasi',
                                    style: const TextStyle(
                                        fontSize: 11, color: _grey),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                size: 14, color: _red),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleSimpanLengkapi(
                          ctx, p, editKey, deskripsiCtrl, lokasiCtrl),
                      icon: const Icon(Icons.upload_outlined,
                          color: Colors.white, size: 18),
                      label: const Text('Simpan Perubahan',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAjukanTTDDialog(
      PengajuanKompen p, String matkul, String namaDosen) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Ajukan Tanda Tangan Digital',
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 16, color: _dark)),
        content: Text(
          'Form kompen $matkul akan dikirim ke $namaDosen untuk ditandatangani secara digital.',
          style: const TextStyle(fontSize: 13, color: _grey, height: 1.5),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _red),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            child: const Text('Batal',
                style: TextStyle(color: _red, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context
                  .read<PengajuanProvider>()
                  .ajukanTTD(p.idPengajuan);
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: const Color(0xFF6A1B9A),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    content: const Row(children: [
                      Icon(Icons.draw_outlined, color: Colors.white, size: 18),
                      SizedBox(width: 10),
                      Text('Pengajuan TTD berhasil dikirim!',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ]),
                    duration: const Duration(seconds: 3),
                  ));
                  NavMahasiswa.handleBottomNav(
                      context, NavTab.tracking, NavTab.pengajuan);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Gagal mengajukan TTD, coba lagi'),
                    backgroundColor: _red,
                  ));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              elevation: 0,
            ),
            child: const Text('Kirim',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ── Kirim form pengajuan baru
  void _handleKirimForm(BuildContext ctx) async {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(ctx);

    print(_selectedMK);
    final idMahasiswa = await SessionManager.getIdMahasiswa();

    final provider = context.read<PengajuanProvider>();

    final mataKuliah = provider.mataKuliah.firstWhere(
      (mk) => mk.namaMk == _selectedMK,
    );
    print(idMahasiswa);
    print(_selectedMK);
    print(await SessionManager.getIdMahasiswa());
    print(_selectedMK);
    print(_selectedTujuan);
    print(_selectedSemester);
    print(_tglCtrl.text);
    print(_jamCtrl.text);

    final mataKuliahDipilih = provider.mataKuliah.firstWhere(
      (mk) => mk.namaMk == _selectedMK,
    );

    print(mataKuliahDipilih.idMataKuliah);

    int? idDosen;
    int? idAdmin;

    if (_selectedTujuan == 'Dosen') {
      final dosenDipilih = provider.dosen.firstWhere(
        (d) => d.namaLengkap == _selectedDosen,
      );
      idDosen = dosenDipilih.idDosen;
    }

    if (_selectedTujuan == 'Admin') {
      idAdmin = provider.admin?.idAdmin;
    }

    final success =
        await context.read<PengajuanProvider>().simpanPengajuan({
      'id_mahasiswa': idMahasiswa,
      'id_mata_kuliah': mataKuliah.idMataKuliah,
      'id_dosen': idDosen,
      'id_admin': idAdmin,
      'tujuan': _selectedTujuan!.toLowerCase(),
      'semester': _selectedSemester!,
      'tanggal_pertemuan': _tglCtrl.text,
      'total_jam_kompen': int.tryParse(_jamCtrl.text) ?? 0,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: success ? const Color(0xFF2E7D32) : _red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(children: [
          Icon(
            success ? Icons.check_circle_outline : Icons.error_outline,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            success
                ? 'Pengajuan berhasil dikirim!'
                : 'Gagal mengirim pengajuan, coba lagi',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ]),
        duration: const Duration(seconds: 3),
      ));

      if (success) {
        final idMahasiswa = await SessionManager.getIdMahasiswa();
        if (idMahasiswa != null && mounted) {
          context.read<PengajuanProvider>().getAllPengajuan(idMahasiswa);
        }
      }
    }
  }

  // ── Simpan lengkapi (deskripsi + lokasi)
  void _handleSimpanLengkapi(
    BuildContext ctx,
    PengajuanKompen p,
    GlobalKey<FormState> key,
    TextEditingController deskripsiCtrl,
    TextEditingController lokasiCtrl,
  ) async {
    if (!key.currentState!.validate()) return;
    if (_selectedLat == null || _selectedNamaLokasi == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pilih lokasi pengerjaan dulu'),
        backgroundColor: _red,
      ));
      return;
    }

    Navigator.pop(ctx);

    final success =
        await context.read<PengajuanProvider>().updateDeskripsiLokasi(
              p.idPengajuan,
              deskripsi: deskripsiCtrl.text.trim(),
              namaLokasi: _selectedNamaLokasi!,
              latitude: _selectedLat!,
              longitude: _selectedLng!,
            );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: success ? const Color(0xFF1565C0) : _red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          success ? 'Form berhasil dilengkapi!' : 'Gagal menyimpan, coba lagi',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ));

      if (success) {
        final idMahasiswa = await SessionManager.getIdMahasiswa();
        if (idMahasiswa != null && mounted) {
          context.read<PengajuanProvider>().getAllPengajuan(idMahasiswa);
        }
      }
    }
  }

  // ── Helpers UI
  Widget _fieldLabel(String t, {bool disabled = false}) => Text(
        t,
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: disabled ? _grey : _dark),
      );

  Widget _buildDropdown({
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    required String errorMsg,
  }) =>
      DropdownButtonFormField<String>(
        value: value,
        validator: (v) => (v == null || v.isEmpty) ? errorMsg : null,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 18, color: _grey),
          filled: true,
          fillColor: _fieldBg,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _fieldBorder)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _fieldBorder)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _red, width: 1.5)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent)),
        ),
        hint: Text(hint, style: const TextStyle(fontSize: 13, color: _grey)),
        items: items
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e,
                      style: const TextStyle(fontSize: 13, color: _dark)),
                ))
            .toList(),
        icon: const Icon(Icons.keyboard_arrow_down, color: _grey),
      );

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required String errorMsg,
    bool isNumber = false,
  }) =>
      TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontSize: 13, color: _dark),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return errorMsg;
          if (isNumber) {
            final jam = int.tryParse(v.trim());
            if (jam == null) return 'Harus berupa angka';
            if (jam <= 0) return 'Harus lebih dari 0';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: _grey),
          prefixIcon: Icon(icon, size: 18, color: _grey),
          filled: true,
          fillColor: _fieldBg,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _fieldBorder)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _fieldBorder)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _red, width: 1.5)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent)),
        ),
      );

  // onChanged ditambah agar StatefulBuilder di sheet bisa trigger rebuild saat tanggal dipilih
  Widget _buildDateField({VoidCallback? onChanged}) => TextFormField(
        controller: _tglCtrl,
        readOnly: true,
        validator: (v) => (v == null || v.trim().isEmpty)
            ? 'Tanggal pertemuan wajib diisi'
            : null,
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
            _tglCtrl.text =
                '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
            onChanged?.call();
          }
        },
        style: const TextStyle(fontSize: 13, color: _dark),
        decoration: InputDecoration(
          hintText: 'dd/mm/yyyy',
          hintStyle: const TextStyle(fontSize: 13, color: _grey),
          prefixIcon: const Icon(Icons.calendar_today_outlined,
              size: 18, color: _grey),
          suffixIcon: const Icon(Icons.keyboard_arrow_down, color: _grey),
          filled: true,
          fillColor: _fieldBg,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _fieldBorder)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _fieldBorder)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _red, width: 1.5)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent)),
        ),
      );

  Widget _buildDisabledField(String hint) => TextFormField(
        enabled: false,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: _grey),
          suffixIcon:
              const Icon(Icons.lock_outline, size: 18, color: _grey),
          filled: true,
          fillColor: const Color(0xFFF0EBE3),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _fieldBorder)),
          disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _fieldBorder)),
        ),
      );

  Widget _buildStatusBadge(String status) {
    late Color bg;
    late Color text;
    late String label;
    switch (status) {
      case 'pending':
        bg = const Color(0xFFFFF3CD);
        text = const Color(0xFF856404);
        label = 'Menunggu Konfirmasi';
        break;
      case 'sedang_dikerjakan':
        bg = const Color(0xFFFFEBEE);
        text = _red;
        label = 'Belum lengkap';
        break;
      case 'siap_diajukan':
        bg = const Color(0xFFE8F5E9);
        text = const Color(0xFF2E7D32);
        label = 'Siap diajukan';
        break;
      default:
        bg = const Color(0xFFF5F5F5);
        text = _grey;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: text)),
    );
  }

  Widget _chip(IconData icon, String label) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: _grey),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: _grey)),
      ]);

  Widget _buildEmptyState() => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(
            children: [
              Icon(Icons.inbox_outlined,
                  size: 56, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              const Text('Belum ada pengajuan',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _grey)),
              const SizedBox(height: 4),
              const Text('Tap tombol di atas untuk mengajukan kompen',
                  style: TextStyle(fontSize: 12, color: _grey)),
            ],
          ),
        ),
      );

  String _formatTanggal(DateTime? dt) {
    if (dt == null) return '-';
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${bulan[dt.month - 1]} ${dt.year}';
  }
}
