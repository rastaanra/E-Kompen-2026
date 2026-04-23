import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';
import '../../widgets/dosen/app_bottom_nav_dosen.dart';
import '../../utils/nav_dosen.dart';

const _red = Color(0xFFB71C1C);
const _cream = Color(0xFFF5EFE6);
const _dark = Color(0xFF2D2D2D);
const _grey = Color(0xFF9E9E9E);
const _cardBg = Color(0xFFFFFFFF);
const _cardBorder = Color(0xFFEDE0CC);

// ── Model pengajuan mahasiswa
class _PengajuanMahasiswa {
  final String namaMahasiswa;
  final String nim;
  final String mataKuliah;
  final String semester;
  final String tanggal;
  final int jam;
  final String status; // 'menunggu' | 'disetujui' | 'ditolak'

  const _PengajuanMahasiswa({
    required this.namaMahasiswa,
    required this.nim,
    required this.mataKuliah,
    required this.semester,
    required this.tanggal,
    required this.jam,
    required this.status,
  });
}

// ── Dummy data
final _dummyList = [
  const _PengajuanMahasiswa(
    namaMahasiswa: 'Seli Permata',
    nim: '244107060021',
    mataKuliah: 'Basis Data',
    semester: 'Semester 4',
    tanggal: '8 Apr 2024',
    jam: 3,
    status: 'menunggu',
  ),
  const _PengajuanMahasiswa(
    namaMahasiswa: 'Andi Budiman',
    nim: '244107060034',
    mataKuliah: 'Kalkulus',
    semester: 'Semester 4',
    tanggal: '6 Apr 2024',
    jam: 2,
    status: 'disetujui',
  ),
  const _PengajuanMahasiswa(
    namaMahasiswa: 'Rina Lestari',
    nim: '244107060047',
    mataKuliah: 'Jarkom Komputer II',
    semester: 'Semester 4',
    tanggal: '4 Apr 2024',
    jam: 4,
    status: 'ditolak',
  ),
  const _PengajuanMahasiswa(
    namaMahasiswa: 'Budi Prasetyo',
    nim: '244107060055',
    mataKuliah: 'Basis Data',
    semester: 'Semester 2',
    tanggal: '2 Apr 2024',
    jam: 2,
    status: 'menunggu',
  ),
];

// ────────────────────────────────────────────
class DosenPengajuanScreen extends StatefulWidget {
  const DosenPengajuanScreen({super.key});

  @override
  State createState() => _DosenPengajuanScreenState();
}

class _DosenPengajuanScreenState extends State {
  String _selectedSemester = 'Semester ini';
  String _selectedStatus = 'Semua Status';

  final List _semesterOptions = [
    'Semester ini',
    'Semester 4',
    'Semester 2',
  ];

  final List _statusOptions = [
    'Semua Status',
    'Menunggu',
    'Disetujui',
    'Ditolak',
  ];

  List<_PengajuanMahasiswa> get _filteredList {
    return _dummyList.where((p) {
      final matchSemester = _selectedSemester == 'Semester ini' ||
          p.semester == _selectedSemester;
      final matchStatus = _selectedStatus == 'Semua Status' ||
          p.status == _selectedStatus.toLowerCase();
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
                      // Judul
                      const Text(
                        'Pengajuan Kompen',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: _dark),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Daftar pengajuan kompen dari mahasiswa',
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

                      // List atau empty state
                      if (_filteredList.isEmpty)
                        _buildEmptyState()
                      else
                        ..._filteredList.map((p) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildCard(p),
                            )),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AppBottomNavDosen(
            activeTab: NavTabDosen.pengajuan,
            onTabSelected: (tab) =>
                NavDosen.handleBottomNav(context, tab, NavTabDosen.pengajuan),
          ),
        ],
      ),
    );
  }

  // ── Dropdown filter
  Widget _buildDropdown({
    required String value,
    required List items,
    required ValueChanged onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _cardBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: _grey, size: 18),
          style: const TextStyle(fontSize: 12, color: _dark),
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e,
                        style:
                            const TextStyle(fontSize: 12, color: _dark)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ── Card pengajuan mahasiswa
  Widget _buildCard(_PengajuanMahasiswa p) {
    final initials = p.namaMahasiswa
        .split(' ')
        .take(2)
        .map((e) => e[0].toUpperCase())
        .join();

    return GestureDetector(
      onTap: () {
        // TODO: navigasi ke halaman detail pengajuan
      },
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
            // Baris atas: avatar + nama + NIM + tanggal
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
                            p.tanggal,
                            style: const TextStyle(
                                fontSize: 10, color: _grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p.nim,
                        style:
                            const TextStyle(fontSize: 11, color: _grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Baris tengah: matkul + semester
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.menu_book_outlined,
                      size: 13, color: _grey),
                  const SizedBox(width: 4),
                  Text(p.mataKuliah,
                      style:
                          const TextStyle(fontSize: 12, color: _dark)),
                ]),
                Row(children: [
                  const Icon(Icons.school_outlined,
                      size: 13, color: _grey),
                  const SizedBox(width: 4),
                  Text(p.semester,
                      style:
                          const TextStyle(fontSize: 11, color: _grey)),
                ]),
              ],
            ),
            const SizedBox(height: 10),

            // Baris bawah: status badge + jam
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

  // ── Status badge
  Widget _buildStatusBadge(String status) {
    Color bg;
    Color textColor;
    String label;

    switch (status) {
      case 'disetujui':
        bg = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF065F46);
        label = 'Disetujui';
        break;
      case 'ditolak':
        bg = const Color(0xFFFEE2E2);
        textColor = const Color(0xFF991B1B);
        label = 'Ditolak';
        break;
      default:
        bg = const Color(0xFFFFF3CD);
        textColor = const Color(0xFF856404);
        label = 'Menunggu';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: textColor),
      ),
    );
  }

  // ── Empty state
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: _grey.withOpacity(0.5)),
            const SizedBox(height: 12),
            const Text(
              'Tidak ada pengajuan',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _grey),
            ),
            const SizedBox(height: 4),
            const Text(
              'Belum ada pengajuan yang sesuai filter',
              style: TextStyle(fontSize: 12, color: _grey),
            ),
          ],
        ),
      ),
    );
  }
}
