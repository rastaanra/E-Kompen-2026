import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';
import '../../widgets/admin/app_bottom_nav_admin.dart';
import '../../utils/nav_admin.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../utils/session_manager.dart';
import '../../models/pengajuan_kompen.dart';
import '../../services/pengajuan_service.dart';

const _red = Color(0xFFB71C1C);
const _cream = Color(0xFFF5EFE6);
const _dark = Color(0xFF2D2D2D);
const _grey = Color(0xFF9E9E9E);
const _cardBg = Color(0xFFFFFFFF);
const _cardBorder = Color(0xFFEDE0CC);

class _PengajuanItem {
  final String namaMahasiswa;
  final String nim;
  final String mataKuliah;
  final String semester;
  final String tanggal;
  final int jam;
  String status;

  _PengajuanItem({
    required this.namaMahasiswa,
    required this.nim,
    required this.mataKuliah,
    required this.semester,
    required this.tanggal,
    required this.jam,
    required this.status,
  });
}

class AdminPengajuanScreen extends StatefulWidget {
  const AdminPengajuanScreen({super.key});
  @override
  State<AdminPengajuanScreen> createState() => _AdminPengajuanScreenState();
  
}

class _AdminPengajuanScreenState extends State<AdminPengajuanScreen> {
  String _selectedSemester = 'Semua Semester';
  String _selectedStatus = 'Semua Status';

    @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final idAdmin = await SessionManager.getIdAdmin();

    if (idAdmin != null) {
      await context.read<AdminProvider>().getAllPengajuan(idAdmin);
    }
  }

  final List<String> _semesterOptions = [
    'Semua Semester',
    'Semester 1', 'Semester 2', 'Semester 3', 'Semester 4',
    'Semester 5', 'Semester 6', 'Semester 7', 'Semester 8',
  ];

  final List<String> _statusOptions = [
    'Semua Status',
    'Menunggu Persetujuan',
    'Disetujui',
  ];

List<PengajuanKompen> _getFilteredList(List<PengajuanKompen> data) {
  final filtered = data.where((p) {
      final matchSemester =
          _selectedSemester == 'Semua Semester' ||
          'Semester ${p.semester}' == _selectedSemester;

      final matchStatus =
          _selectedStatus == 'Semua Status' ||
          (_selectedStatus == 'Menunggu Persetujuan' && p.status == 'pending')||
          (_selectedStatus == 'Disetujui' &&
              (p.status == 'sedang_dikerjakan' ||
              p.status == 'siap_diajukan' ||
              p.status == 'menunggu_ttd_dosen' ||
              p.status == 'menunggu_ttd_kaprodi' ||
              p.status == 'selesai'));

      return matchSemester && matchStatus;
    }).toList();

    filtered.sort((a, b) {
      if (a.status == 'pending' &&
          b.status != 'pending') {
        return -1;
      }

      if (a.status != 'pending' &&
          b.status == 'pending') {
        return 1;
      }

      return 0;
    });

    return filtered;
  }

  void _showDetailPengajuan(PengajuanKompen p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        bool sudahDisetujui =
          p.status != 'pending';
        return StatefulBuilder(
          builder: (ctx, setLocal) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Informasi Pengajuan',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _dark)),
                const SizedBox(height: 16),

                // Card nama
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFF5EFE6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE8E8E8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.namaMahasiswa ?? '-',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _dark,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'NIM: ${p.nim}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: _grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                _buildInfoRow(
                  'Mata Kuliah',
                  p.namaMatkul ?? '-',
                ),
                _buildInfoRow('Semester',
                    p.semester.replaceAll('Semester ', '')),
                _buildInfoRow('Tanggal Pertemuan', p.tanggalPertemuan != null
                  ? '${p.tanggalPertemuan!.day}/${p.tanggalPertemuan!.month}/${p.tanggalPertemuan!.year}'
                  : '-'),
                _buildInfoRow('Total Jam Kompen', '${p.totalJamKompen ?? 0} Jam'),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          foregroundColor: _red,
                          side: const BorderSide(color: _red),
                        ),
                        child: const Text('Tutup'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                      onPressed: sudahDisetujui
                          ? null
                          : () async {
                              final success = await context
                                  .read<AdminProvider>()
                                  .konfirmasiPengajuan(p.idPengajuan);

                              if (success) {
                                await _loadData();

                                if (!mounted) return;

                                Navigator.pop(ctx);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Pengajuan berhasil disetujui'),
                                  ),
                                );
                              }
                            },
                        icon: Icon(Icons.check,
                            size: 16,
                            color: sudahDisetujui
                                ? Colors.grey[500]
                                : Colors.white),
                        label: Text('Setujui',
                            style: TextStyle(
                                color: sudahDisetujui
                                    ? Colors.grey[500]
                                    : Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: sudahDisetujui
                              ? Colors.grey[200]
                              : _red,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
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
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 13, color: _grey)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _dark)),
            ],
          ),
        ),
        Divider(height: 1, color: Colors.black.withOpacity(0.06)),
      ],
    );
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
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pengajuan Kompen',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: _dark)),
                        const SizedBox(height: 4),
                        const Text('Daftar pengajuan kompen dari mahasiswa',
                            style: TextStyle(fontSize: 13, color: _grey)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdown(
                                value: _selectedSemester,
                                items: _semesterOptions,
                                onChanged: (val) => setState(
                                    () => _selectedSemester = val!),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildDropdown(
                                value: _selectedStatus,
                                items: _statusOptions,
                                onChanged: (val) => setState(
                                    () => _selectedStatus = val!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  Expanded(
  child: context.watch<AdminProvider>().isLoading
      ? const Center(
          child: CircularProgressIndicator(),
        )
      : Builder(
          builder: (context) {
            final list = _getFilteredList(context.watch<AdminProvider>().listPengajuan);
            return list.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: list.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildCard(list[index]),
                    ),
                  );
          },
        ),
),
                ],
              ),
            ),
          ),
          AppBottomNavAdmin(
            activeTab: NavTabAdmin.pengajuan,
            onTap: (tab) => NavAdmin.handleBottomNav(
                context, tab, NavTabAdmin.pengajuan),
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
          icon: const Icon(Icons.keyboard_arrow_down,
              color: _grey, size: 18),
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

  Widget _buildCard(PengajuanKompen p) {
  return Container(
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
        // Nama + tanggal
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          Text(
            p.namaMahasiswa ?? '-',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _dark,
            ),
          ),
            Text(
            p.tanggalPertemuan != null
                ? '${p.tanggalPertemuan!.day}/${p.tanggalPertemuan!.month}/${p.tanggalPertemuan!.year}'
                : '-',
              style: const TextStyle(
                fontSize: 10,
                color: _grey,
              ),
            ),
          ],
        ),

        const SizedBox(height: 2),

        Text(
          'NIM: ${p.nim ?? '-'}',
          style: const TextStyle(
            fontSize: 11,
            color: _grey,
          ),
        ),

        const SizedBox(height: 10),

        // Mata kuliah + semester
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.menu_book_outlined,
                  size: 13,
                  color: _grey,
                ),
                const SizedBox(width: 4),
                Text(
                  p.namaMatkul ?? '-',
                  style: const TextStyle(
                    fontSize: 12,
                    color: _dark,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(
                  Icons.school_outlined,
                  size: 13,
                  color: _grey,
                ),
                const SizedBox(width: 4),
                Text(
                  'Semester ${p.semester}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: _grey,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 6),

        // Jam
        Row(
          children: [
            const Icon(
              Icons.access_time_outlined,
              size: 13,
              color: _grey,
            ),
            const SizedBox(width: 4),
            Text(
              '${p.totalJamKompen ?? 0} Jam',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _dark,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Status + Detail
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatusBadge(p.status),

            GestureDetector(
              onTap: () => _showDetailPengajuan(p),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Text(
                      'Detail',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _red,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right,
                      size: 14,
                      color: _red,
                    ),
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

Widget _buildStatusBadge(String status) {
  final bool disetujui = status != 'pending';

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: disetujui ? const Color(0xFFD1FAE5) : const Color(0xFFFFF3CD),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      disetujui ? 'Disetujui' : 'Menunggu Persetujuan',
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: disetujui ? const Color(0xFF065F46) : const Color(0xFF856404),
      ),
    ),
  );
}


  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined,
              size: 48, color: _grey.withOpacity(0.5)),
          const SizedBox(height: 12),
          const Text('Tidak ada pengajuan',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _grey)),
          const SizedBox(height: 4),
          const Text('Belum ada pengajuan yang sesuai filter',
              style: TextStyle(fontSize: 12, color: _grey)),
        ],
      ),
    );
  }
}