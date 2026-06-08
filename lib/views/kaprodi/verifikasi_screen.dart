import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';
import '../../widgets/kaprodi/app_bottom_nav_kaprodi.dart';
import '../../utils/nav_kaprodi.dart';
import 'detail_verifikasi_view.dart';

const _red = Color(0xFFB71C1C);
const _cream = Color(0xFFF5EFE6);
const _dark = Color(0xFF2D2D2D);
const _grey = Color(0xFF9E9E9E);
const _cardBg = Color(0xFFFFFFFF);
const _cardBorder = Color(0xFFEDE0CC);

// ── Model lokal untuk list verifikasi
// Nanti diganti data dari API kalau endpoint sudah tersedia
class _FormPenyelesaian {
  final int idPengajuan;
  final String namaMahasiswa;
  final String nim;
  final String kelas;
  final String mataKuliah;
  final String semester;
  final String jenisPekerjaan;
  final String keterangan;
  final String tanggalSelesai;
  final int jam;
  final String status; // 'menunggu_ttd' | 'sudah_ttd'
  final String namaDosen;
  final String nipDosen;
  final String namaKaprodi;
  final String nipKaprodi;
  final bool sudahTtdDosen;
  final bool sudahTtdKaprodi;

  const _FormPenyelesaian({
    required this.idPengajuan,
    required this.namaMahasiswa,
    required this.nim,
    required this.kelas,
    required this.mataKuliah,
    required this.semester,
    required this.jenisPekerjaan,
    required this.keterangan,
    required this.tanggalSelesai,
    required this.jam,
    required this.status,
    required this.namaDosen,
    required this.nipDosen,
    required this.namaKaprodi,
    required this.nipKaprodi,
    required this.sudahTtdDosen,
    required this.sudahTtdKaprodi,
  });
}

// ── Dummy data
final _dummyVerifikasi = [
  const _FormPenyelesaian(
    idPengajuan: 1,
    namaMahasiswa: 'Seli Permata',
    nim: '244107060021',
    kelas: '2 SIB',
    mataKuliah: 'Basis Data',
    semester: 'Semester 4',
    jenisPekerjaan: 'Membantu laboran',
    keterangan: '',
    tanggalSelesai: '10 Apr 2024',
    jam: 3,
    status: 'menunggu_ttd',
    namaDosen: 'Budi Harjanta, S.T.,M.Kom',
    nipDosen: '196305210086041003',
    namaKaprodi: 'Hendra Pradibta, S.E., M.Sc.',
    nipKaprodi: '198305210086041003',
    sudahTtdDosen: true,
    sudahTtdKaprodi: false,
  ),
  const _FormPenyelesaian(
    idPengajuan: 2,
    namaMahasiswa: 'Budi Prasetyo',
    nim: '244107060055',
    kelas: '2 SIB',
    mataKuliah: 'Basis Data',
    semester: 'Semester 2',
    jenisPekerjaan: 'Menyiapkan modul praktikum',
    keterangan: '',
    tanggalSelesai: '8 Apr 2024',
    jam: 2,
    status: 'sudah_ttd',
    namaDosen: 'Budi Harjanta, S.T.,M.Kom',
    nipDosen: '196305210086041003',
    namaKaprodi: 'Hendra Pradibta, S.E., M.Sc.',
    nipKaprodi: '198305210086041003',
    sudahTtdDosen: true,
    sudahTtdKaprodi: true,
  ),
  const _FormPenyelesaian(
    idPengajuan: 3,
    namaMahasiswa: 'Andi Budiman',
    nim: '244107060034',
    kelas: '4 TI',
    mataKuliah: 'Kalkulus',
    semester: 'Semester 4',
    jenisPekerjaan: 'Mengoreksi tugas mahasiswa',
    keterangan: '',
    tanggalSelesai: '6 Apr 2024',
    jam: 2,
    status: 'menunggu_ttd',
    namaDosen: 'Budi Harjanta, S.T.,M.Kom',
    nipDosen: '196305210086041003',
    namaKaprodi: 'Hendra Pradibta, S.E., M.Sc.',
    nipKaprodi: '198305210086041003',
    sudahTtdDosen: true,
    sudahTtdKaprodi: false,
  ),
];

// ────────────────────────────────────────────
class KaprodiVerifikasiScreen extends StatefulWidget {
  const KaprodiVerifikasiScreen({super.key});

  @override
  State<KaprodiVerifikasiScreen> createState() =>
      _KaprodiVerifikasiScreenState();
}

class _KaprodiVerifikasiScreenState extends State<KaprodiVerifikasiScreen> {
  String _selectedSemester = 'Semua Semester';
  String _selectedStatus = 'Semua Status';

  final List<String> _semesterOptions = [
    'Semua Semester',
    'Semester 4',
    'Semester 2',
  ];

  final List<String> _statusOptions = [
    'Semua Status',
    'Menunggu TTD',
    'Sudah TTD',
  ];

  List<_FormPenyelesaian> get _filteredList {
    return _dummyVerifikasi.where((p) {
      final matchSemester = _selectedSemester == 'Semua Semester' ||
          p.semester == _selectedSemester;
      final matchStatus = _selectedStatus == 'Semua Status' ||
          (_selectedStatus == 'Menunggu TTD' && p.status == 'menunggu_ttd') ||
          (_selectedStatus == 'Sudah TTD' && p.status == 'sudah_ttd');
      return matchSemester && matchStatus;
    }).toList();
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
                behavior:
                    const ScrollBehavior().copyWith(overscroll: false),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Verifikasi Kompen',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: _dark),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Form penyelesaian kompen yang perlu ditandatangani',
                        style: TextStyle(fontSize: 13, color: _grey),
                      ),
                      const SizedBox(height: 16),

                      // Filter row
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

                      if (_filteredList.isEmpty)
                        _buildEmptyState()
                      else
                        ..._filteredList.map((p) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildCard(context, p),
                            )),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AppBottomNavKaprodi(
            activeTab: NavTabKaprodi.verifikasi,
            onTabSelected: (tab) => NavKaprodi.handleBottomNav(
                context, tab, NavTabKaprodi.verifikasi),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _cardBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: _grey, size: 18),
          style: const TextStyle(fontSize: 12, color: _dark),
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e,
                        style: const TextStyle(fontSize: 12, color: _dark)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, _FormPenyelesaian p) {
    final initials = p.namaMahasiswa
        .split(' ')
        .take(2)
        .map((e) => e[0].toUpperCase())
        .join();

    return GestureDetector(
      onTap: () => _navigateToDetail(context, p),
      child: Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cardBorder),
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
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFCEBEB),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFA32D2D)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            p.namaMahasiswa,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _dark),
                          ),
                          Text(
                            p.tanggalSelesai,
                            style: const TextStyle(fontSize: 10, color: _grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(p.nim,
                          style: const TextStyle(fontSize: 11, color: _grey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.menu_book_outlined, size: 13, color: _grey),
                  const SizedBox(width: 4),
                  Text(p.mataKuliah,
                      style: const TextStyle(fontSize: 12, color: _dark)),
                ]),
                Row(children: [
                  const Icon(Icons.school_outlined, size: 13, color: _grey),
                  const SizedBox(width: 4),
                  Text(p.semester,
                      style: const TextStyle(fontSize: 11, color: _grey)),
                ]),
              ],
            ),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.work_outline, size: 13, color: _grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  p.jenisPekerjaan,
                  style: const TextStyle(fontSize: 12, color: _dark),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusBadge(p.status),
                Row(children: [
                  const Icon(Icons.access_time_outlined,
                      size: 13, color: _grey),
                  const SizedBox(width: 4),
                  Text(
                    '${p.jam} Jam',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _dark),
                  ),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, _FormPenyelesaian p) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailVerifikasiView(
          data: DetailVerifikasiData(
            idPengajuan: p.idPengajuan,
            namaMahasiswa: p.namaMahasiswa,
            nim: p.nim,
            kelas: p.kelas,
            semester: p.semester,
            mataKuliah: p.mataKuliah,
            pekerjaan: p.jenisPekerjaan,
            jumlahJam: p.jam,
            keterangan: p.keterangan,
            tanggal: p.tanggalSelesai,
            namaDosen: p.namaDosen,
            nipDosen: p.nipDosen,
            namaKaprodi: p.namaKaprodi,
            nipKaprodi: p.nipKaprodi,
            sudahTtdDosen: p.sudahTtdDosen,
            sudahTtdKaprodi: p.sudahTtdKaprodi,
          ),
        ),
      ),
    ).then((_) => setState(() {})); // refresh list setelah balik
  }

  Widget _buildStatusBadge(String status) {
    final bool menunggu = status == 'menunggu_ttd';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: menunggu ? const Color(0xFFFFF3CD) : const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        menunggu ? 'Menunggu TTD' : 'Sudah TTD',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color:
              menunggu ? const Color(0xFF856404) : const Color(0xFF065F46),
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
            Icon(Icons.draw_outlined, size: 48, color: _grey.withOpacity(0.5)),
            const SizedBox(height: 12),
            const Text(
              'Tidak ada form penyelesaian',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: _grey),
            ),
            const SizedBox(height: 4),
            const Text(
              'Belum ada form yang sesuai filter',
              style: TextStyle(fontSize: 12, color: _grey),
            ),
          ],
        ),
      ),
    );
  }
}
