import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';
import '../../widgets/admin/app_bottom_nav_admin.dart';
import '../../utils/nav_admin.dart';
import '../../utils/session_manager.dart';
import '../../models/pengajuan_kompen.dart';
import '../../services/pengajuan_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

const _redV = Color(0xFFB71C1C);
const _creamV = Color(0xFFF5EFE6);
const _darkV = Color(0xFF2D2D2D);
const _greyV = Color(0xFF9E9E9E);
const _cardBgV = Color(0xFFFFFFFF);
const _cardBorderV = Color(0xFFEDE0CC);

class AdminVerifikasiScreen extends StatefulWidget {
  const AdminVerifikasiScreen({super.key});

  @override
  State<AdminVerifikasiScreen> createState() => _AdminVerifikasiScreenState();
}

class _AdminVerifikasiScreenState extends State<AdminVerifikasiScreen> {
  final PengajuanService _pengajuanService = PengajuanService();

  List<PengajuanKompen> _pengajuanList = [];
  bool _isLoading = true;

  String namaKaprodi = '';
  String nipKaprodi = '';

  String _selectedSemester = 'Semua Semester';
  String _selectedStatus = 'Semua Status';
  String _selectedUrutan = 'Terbaru';
  String _searchQuery = '';

  final List<String> _semesterOptions = [
    'Semua Semester',
    'Semester 1', 'Semester 2', 'Semester 3', 'Semester 4',
    'Semester 5', 'Semester 6', 'Semester 7', 'Semester 8',
  ];

  final List<String> _statusOptions = [
    'Semua Status',
    'Menunggu TTD',
    'Sudah TTD',
  ];

  final List<String> _urutanOptions = [
    'Terbaru',
    'Terlama',
    'Nama A-Z',
    'Jam Terbanyak',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final idAdmin = await SessionManager.getIdAdmin();
    if (idAdmin == null) {
      setState(() => _isLoading = false);
      return;
    }

    final data = await _pengajuanService.getPengajuanAdmin(idAdmin);
    final kaprodi = await _pengajuanService.getKaprodi();

    if (mounted) {
      setState(() {
        _pengajuanList = data;
        if (kaprodi != null) {
          namaKaprodi = kaprodi['nama'] ?? '';
          nipKaprodi = kaprodi['nip'] ?? '';
        }
        _isLoading = false;
      });
    }
  }

  // ── Filter + urutan ────────────────────────────────────────────────────────
  List<PengajuanKompen> get _filteredList {
    final relevant = ['menunggu_ttd_admin', 'menunggu_ttd_kaprodi', 'selesai'];

    var filtered = _pengajuanList.where((p) {
      if (!relevant.contains(p.status)) return false;

      final matchSemester = _selectedSemester == 'Semua Semester' ||
          'Semester ${p.semester}' == _selectedSemester;

      final matchStatus = _selectedStatus == 'Semua Status' ||
          (_selectedStatus == 'Menunggu TTD' &&
              p.status == 'menunggu_ttd_admin') ||
          (_selectedStatus == 'Sudah TTD' &&
              (p.status == 'menunggu_ttd_kaprodi' ||
                  p.status == 'selesai'));

      final q = _searchQuery.toLowerCase();
      final matchSearch = q.isEmpty ||
          (p.namaMahasiswa?.toLowerCase().contains(q) ?? false) ||
          (p.nim?.toLowerCase().contains(q) ?? false);

      return matchSemester && matchStatus && matchSearch;
    }).toList();

    switch (_selectedUrutan) {
      case 'Terlama':
        filtered.sort((a, b) =>
            (a.tanggalPertemuan ?? DateTime(0))
                .compareTo(b.tanggalPertemuan ?? DateTime(0)));
        break;
      case 'Nama A-Z':
        filtered.sort((a, b) =>
            (a.namaMahasiswa ?? '').compareTo(b.namaMahasiswa ?? ''));
        break;
      case 'Jam Terbanyak':
        filtered.sort((a, b) =>
            (b.totalJamKompen ?? 0).compareTo(a.totalJamKompen ?? 0));
        break;
      case 'Terbaru':
      default:
        filtered.sort((a, b) =>
            (b.tanggalPertemuan ?? DateTime(0))
                .compareTo(a.tanggalPertemuan ?? DateTime(0)));
        filtered.sort((a, b) {
          if (a.status == 'menunggu_ttd_admin' &&
              b.status != 'menunggu_ttd_admin') return -1;
          if (a.status != 'menunggu_ttd_admin' &&
              b.status == 'menunggu_ttd_admin') return 1;
          return 0;
        });
    }

    return filtered;
  }

  String _formatTanggal(DateTime? dt) {
    if (dt == null) return '-';
    const bulan = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${dt.day} ${bulan[dt.month]} ${dt.year}';
  }

  String _jamTerbilang(int jam) {
    const terbilang = [
      '', 'Satu', 'Dua', 'Tiga', 'Empat', 'Lima',
      'Enam', 'Tujuh', 'Delapan', 'Sembilan', 'Sepuluh'
    ];
    if (jam >= 1 && jam <= 10) return terbilang[jam];
    return '$jam';
  }

  // ── Bottom sheet detail / form TTD ────────────────────────────────────────
  void _showFormVerifikasi(PengajuanKompen p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        bool sudahTTD = p.status != 'menunggu_ttd_admin';
        String qrData = p.idPengajuan.toString();

        return StatefulBuilder(
          builder: (ctx, setLocal) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, scrollCtrl) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B0000), Color(0xFFB71C1C)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: _redV.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 52, height: 52,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.school,
                                    color: Colors.white, size: 28),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text('POLITEKNIK NEGERI MALANG',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white)),
                                    Text('JURUSAN TEKNOLOGI INFORMASI',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white)),
                                    Text(
                                        'PROGRAM STUDI D-IV SISTEM INFORMASI BISNIS',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white)),
                                        SizedBox(height: 2),
                                    Text(
                                        'Jl. Soekarno Hatta No.9 Malang 65141 · Telp. (0341) 404424',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 8,
                                            color: Colors.white70)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _creamV,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text('BERITA ACARA KOMPENSASI',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: _darkV,
                                    letterSpacing: 1)),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildFormRow('Nama Admin', p.namaTujuan ?? '-'),
                        const SizedBox(height: 8),
                        const Text(
                          'Memberikan rekomendasi kompensasi kepada:',
                          style: TextStyle(fontSize: 12, color: _darkV),
                        ),
                        const SizedBox(height: 8),
                        _buildFormRow('Nama Mahasiswa', p.namaMahasiswa ?? '-'),
                        _buildFormRow('NIM', p.nim ?? '-'),
                        _buildFormRow('Semester', 'Semester ${p.semester}'),
                        _buildFormRow('Mata Kuliah', p.namaMatkul ?? '-'),
                        _buildFormRow('Pekerjaan', p.deskripsiTugas ?? '-'),
                        _buildFormRow(
                          'Jumlah Jam',
                          '${p.totalJamKompen ?? 0} (${_jamTerbilang(p.totalJamKompen ?? 0)} Jam)',
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Malang, ${_formatTanggal(p.tanggalPertemuan)}',
                          style: const TextStyle(fontSize: 12, color: _darkV),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                      'Yang memberikan rekomendasi,',
                                      style: TextStyle(fontSize: 11, color: _darkV)),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 110,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black12),
                                      borderRadius: BorderRadius.circular(6),
                                      color: sudahTTD ? Colors.green[50] : null,
                                    ),
                                    child: Center(
                                      child: sudahTTD
                                          ? Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                QrImageView(
                                                  data: qrData,
                                                  version: QrVersions.auto,
                                                  size: 85,
                                                ),
                                                const SizedBox(height: 2),
                                                Icon(Icons.check_circle_outline,
                                                    color: Colors.green[600],
                                                    size: 14),
                                              ],
                                            )
                                          : const Text(
                                              'Belum\nditandatangani',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 9, color: _greyV),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    p.namaTujuan ?? '-',
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: _darkV),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // ── BOX TTD KAPRODI (FIX DISINI) ──────────────────
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                      'Mengetahui, Ka. Program Studi',
                                      style: TextStyle(fontSize: 11, color: _darkV)),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 110,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black12),
                                      borderRadius: BorderRadius.circular(6),
                                      color: p.status == 'selesai' ? Colors.green[50] : null,
                                    ),
                                    child: Center(
                                      child: p.status == 'selesai'
                                          ? Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                QrImageView(
                                                  // Menggunakan kode ttd kaprodi jika ada, jika null pakai idPengajuan
                                                  data: p.kodeTtdKaprodi ?? p.idPengajuan.toString(),
                                                  version: QrVersions.auto,
                                                  size: 85,
                                                ),
                                                const SizedBox(height: 2),
                                                Icon(Icons.check_circle_outline,
                                                    color: Colors.green[600], size: 14),
                                              ],
                                            )
                                          : const Text(
                                              'Belum\nditandatangani',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 9, color: _greyV),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(namaKaprodi,
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: _darkV)),
                                  Text('NIP. $nipKaprodi',
                                      style: const TextStyle(fontSize: 9, color: _greyV)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(ctx),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  foregroundColor: _redV,
                                  side: const BorderSide(color: _redV),
                                ),
                                child: const Text('Tutup'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: sudahTTD
                                    ? null
                                    : () async {
                                        final success =
                                            await _pengajuanService
                                                .ttdAdmin(p.idPengajuan);
                                        if (success) {
                                          await _loadData();
                                          if (!mounted) return;
                                          setLocal(() => sudahTTD = true);
                                          Navigator.pop(ctx);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text('Berhasil ditandatangani'),
                                              backgroundColor: _redV,
                                            ),
                                          );
                                        }
                                      },
                                icon: Icon(Icons.draw_outlined,
                                    size: 16,
                                    color: sudahTTD ? Colors.grey[500] : Colors.white),
                                label: Text(
                                  sudahTTD ? 'Sudah TTD' : 'Tandatangani',
                                  style: TextStyle(
                                      color: sudahTTD ? Colors.grey[500] : Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: sudahTTD ? Colors.grey[200] : _redV,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Navigator.canPop(context) ? const SizedBox() : const SizedBox(),
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontSize: 12, color: _greyV)),
          ),
          const Text(': ', style: TextStyle(fontSize: 12, color: _darkV)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _darkV)),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _redV,
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: _creamV,
                borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Verifikasi Kompen',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: _darkV)),
                        const SizedBox(height: 4),
                        const Text('Form penyelesaian kompen yang perlu ditandatangani',
                            style: TextStyle(fontSize: 13, color: _greyV)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdown(
                                value: _selectedSemester,
                                items: _semesterOptions,
                                onChanged: (val) =>
                                    setState(() => _selectedSemester = val!),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildDropdown(
                                value: _selectedStatus,
                                items: _statusOptions,
                                onChanged: (val) =>
                                    setState(() => _selectedStatus = val!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: _redV))
                        : _filteredList.isEmpty
                            ? _buildEmptyState()
                            : RefreshIndicator(
                                color: _redV,
                                onRefresh: _loadData,
                                child: ListView.builder(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 24),
                                  itemCount: _filteredList.length,
                                  itemBuilder: (context, index) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildCard(_filteredList[index]),
                                  ),
                                ),
                              ),
                  ),
                ],
              ),
            ),
          ),
          AppBottomNavAdmin(
            activeTab: NavTabAdmin.verifikasi,
            onTap: (tab) =>
                NavAdmin.handleBottomNav(context, tab, NavTabAdmin.verifikasi),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(PengajuanKompen p) {
    bool nunggu = p.status == 'menunggu_ttd_admin';
    return Container(
      decoration: BoxDecoration(
        color: _cardBgV,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorderV),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(p.namaMahasiswa ?? '-',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: _darkV)),
              Text(_formatTanggal(p.tanggalPertemuan),
                  style: const TextStyle(fontSize: 10, color: _greyV)),
            ],
          ),
          const SizedBox(height: 2),
          Text('NIM: ${p.nim ?? '-'}',
              style: const TextStyle(fontSize: 11, color: _greyV)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.menu_book_outlined, size: 13, color: _greyV),
                const SizedBox(width: 4),
                Text(p.deskripsiTugas ?? '-',
                    style: const TextStyle(fontSize: 12, color: _darkV)),
              ]),
              Row(children: [
                const Icon(Icons.school_outlined, size: 13, color: _greyV),
                const SizedBox(width: 4),
                Text('Semester ${p.semester ?? '-'}',
                    style: const TextStyle(fontSize: 11, color: _greyV)),
              ]),
            ],
          ),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.location_on_outlined, size: 13, color: _greyV),
            const SizedBox(width: 4),
            Expanded(
              child: Text(p.namaLokasi ?? '-',
                  style: const TextStyle(fontSize: 12, color: _darkV),
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.near_me_outlined, size: 13, color: _greyV),
            const SizedBox(width: 4),
            Text('${p.latitude}, ${p.longitude}',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _darkV)),
          ]),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: nunggu
                      ? const Color(0xFFFFF3CD)
                      : const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  nunggu ? 'Menunggu TTD' : 'Sudah TTD',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: nunggu
                        ? const Color(0xFF856404)
                        : const Color(0xFF065F46),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _showFormVerifikasi(p),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _redV.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Text('Detail',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _redV)),
                      SizedBox(width: 2),
                      Icon(Icons.chevron_right, size: 14, color: _redV),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _cardBorderV),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: _greyV, size: 16),
          style: const TextStyle(fontSize: 11, color: _darkV),
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e, style: const TextStyle(fontSize: 11)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined,
              size: 48, color: _greyV.withOpacity(0.5)),
          const SizedBox(height: 12),
          const Text('Tidak ada data verifikasi',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: _greyV)),
        ],
      ),
    );
  }
}