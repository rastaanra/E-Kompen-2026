import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';
import '../../widgets/admin/app_bottom_nav_admin.dart';
import '../../utils/nav_admin.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../utils/session_manager.dart';
import '../../models/pengajuan_kompen.dart';

const _red = Color(0xFFB71C1C);
const _cream = Color(0xFFF5EFE6);
const _dark = Color(0xFF2D2D2D);
const _grey = Color(0xFF9E9E9E);
const _cardBg = Color(0xFFFFFFFF);
const _cardBorder = Color(0xFFEDE0CC);

class AdminPengajuanScreen extends StatefulWidget {
  const AdminPengajuanScreen({super.key});
  @override
  State<AdminPengajuanScreen> createState() => _AdminPengajuanScreenState();
}

class _AdminPengajuanScreenState extends State<AdminPengajuanScreen> {
  String _selectedSemester = 'Semua Semester';
  String _selectedStatus = 'Semua Status';
  String _selectedUrutan = 'Terbaru';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final idAdmin = await SessionManager.getIdAdmin();
    if (idAdmin != null && mounted) {
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

  final List<String> _urutanOptions = [
    'Terbaru',
    'Terlama',
    'Nama A-Z',
    'Jam Terbanyak',
  ];

  List<PengajuanKompen> get _filteredList {
    final data = context.watch<AdminProvider>().listPengajuan;

    var filtered = data.where((p) {
      // Filter semester
      final matchSemester = _selectedSemester == 'Semua Semester' ||
          p.semester == _selectedSemester.replaceAll('Semester ', '');

      // Filter status
      final matchStatus = _selectedStatus == 'Semua Status' ||
          (_selectedStatus == 'Menunggu Persetujuan' && p.status == 'pending') ||
          (_selectedStatus == 'Disetujui' && p.status == 'sedang_dikerjakan');

      // Search nama / NIM
      final q = _searchQuery.toLowerCase();
      final matchSearch = q.isEmpty ||
          (p.namaMahasiswa?.toLowerCase().contains(q) ?? false) ||
          (p.nim?.toLowerCase().contains(q) ?? false);

      return matchSemester && matchStatus && matchSearch;
    }).toList();

    // Urutan
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
        // Pending tetap di atas
        filtered.sort((a, b) {
          if (a.status == 'pending' && b.status != 'pending') return -1;
          if (a.status != 'pending' && b.status == 'pending') return 1;
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

  void _showDetailPengajuan(PengajuanKompen p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        bool sudahDisetujui = p.status == 'sedang_dikerjakan';
        return StatefulBuilder(
          builder: (ctx, setLocal) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.75,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, scrollCtrl) => Column(
              children: [
                // Handle
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
                        const Text(
                          'Detail Pengajuan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _dark,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Badge status
                        _buildStatusBadge(p.status),
                        const SizedBox(height: 16),

                        // Card mahasiswa
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _cream,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _cardBorder),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: _red,
                                child: Text(
                                  (p.namaMahasiswa ?? '-')
                                      .split(' ')
                                      .take(2)
                                      .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
                                      .join(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.namaMahasiswa ?? '-',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: _dark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'NIM: ${p.nim ?? '-'}',
                                      style: const TextStyle(
                                          fontSize: 12, color: _grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Informasi detail
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _cardBorder),
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow(Icons.menu_book_outlined, 'Mata Kuliah',
                                  p.namaMatkul ?? '-'),
                              _buildInfoRow(Icons.school_outlined, 'Semester',
                                  'Semester ${p.semester}'),
                              _buildInfoRow(Icons.calendar_today_outlined,
                                  'Tanggal Pertemuan', _formatTanggal(p.tanggalPertemuan)),
                              _buildInfoRow(Icons.access_time_outlined,
                                  'Total Jam Kompen', '${p.totalJamKompen ?? 0} Jam'),
                              if (p.deskripsiTugas != null &&
                                  p.deskripsiTugas!.isNotEmpty)
                                _buildInfoRow(Icons.assignment_outlined,
                                    'Deskripsi Tugas', p.deskripsiTugas!,
                                    isLast: true),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Tombol
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(ctx),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
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
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Pengajuan berhasil disetujui'),
                                              backgroundColor: _red,
                                            ),
                                          );
                                        }
                                      },
                                icon: Icon(Icons.check,
                                    size: 16,
                                    color: sudahDisetujui
                                        ? Colors.grey[500]
                                        : Colors.white),
                                label: Text(
                                  sudahDisetujui ? 'Sudah Disetujui' : 'Setujui',
                                  style: TextStyle(
                                      color: sudahDisetujui
                                          ? Colors.grey[500]
                                          : Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      sudahDisetujui ? Colors.grey[200] : _red,
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

  Widget _buildInfoRow(IconData icon, String label, String value,
      {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 16, color: _red),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: Text(label,
                    style: const TextStyle(fontSize: 12, color: _grey)),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  value,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _dark),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 1, color: Colors.black.withOpacity(0.05)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AdminProvider>().isLoading;
    final total = _filteredList.length;
    final pending =
        _filteredList.where((p) => p.status == 'pending').length;

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Judul + badge pending
                        Row(
                          children: [
                            const Expanded(
                              child: Text('Pengajuan Kompen',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: _dark)),
                            ),
                            if (pending > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _red,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$pending Menunggu',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$total pengajuan ditemukan',
                          style:
                              const TextStyle(fontSize: 12, color: _grey),
                        ),
                        const SizedBox(height: 14),

                        // Search bar
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _cardBorder),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (v) =>
                                setState(() => _searchQuery = v),
                            style: const TextStyle(
                                fontSize: 13, color: _dark),
                            decoration: InputDecoration(
                              hintText: 'Cari nama mahasiswa atau NIM...',
                              hintStyle: const TextStyle(
                                  fontSize: 13, color: _grey),
                              prefixIcon: const Icon(Icons.search,
                                  color: _grey, size: 20),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? GestureDetector(
                                      onTap: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                      child: const Icon(Icons.close,
                                          color: _grey, size: 18),
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Filter row
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
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildDropdown(
                                value: _selectedStatus,
                                items: _statusOptions,
                                onChanged: (val) =>
                                    setState(() => _selectedStatus = val!),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildDropdown(
                                value: _selectedUrutan,
                                items: _urutanOptions,
                                onChanged: (val) =>
                                    setState(() => _selectedUrutan = val!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  // List
                  Expanded(
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: _red))
                        : _filteredList.isEmpty
                            ? _buildEmptyState()
                            : RefreshIndicator(
                                color: _red,
                                onRefresh: _loadData,
                                child: ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 0, 16, 24),
                                  itemCount: _filteredList.length,
                                  itemBuilder: (context, index) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 12),
                                    child:
                                        _buildCard(_filteredList[index]),
                                  ),
                                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _cardBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: _grey, size: 16),
          style: const TextStyle(fontSize: 11, color: _dark),
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child:
                        Text(e, style: const TextStyle(fontSize: 11, color: _dark)),
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
              Expanded(
                child: Text(
                  p.namaMahasiswa ?? '-',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: _dark),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _formatTanggal(p.tanggalPertemuan),
                style: const TextStyle(fontSize: 10, color: _grey),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text('NIM: ${p.nim ?? '-'}',
              style: const TextStyle(fontSize: 11, color: _grey)),
          const SizedBox(height: 10),

          // Matkul + semester
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.menu_book_outlined, size: 13, color: _grey),
                const SizedBox(width: 4),
                Text(p.namaMatkul ?? '-',
                    style: const TextStyle(fontSize: 12, color: _dark)),
              ]),
              Row(children: [
                const Icon(Icons.school_outlined, size: 13, color: _grey),
                const SizedBox(width: 4),
                Text('Semester ${p.semester}',
                    style: const TextStyle(fontSize: 11, color: _grey)),
              ]),
            ],
          ),
          const SizedBox(height: 6),

          // Jam
          Row(children: [
            const Icon(Icons.access_time_outlined, size: 13, color: _grey),
            const SizedBox(width: 4),
            Text('${p.totalJamKompen ?? 0} Jam',
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700, color: _dark)),
          ]),
          const SizedBox(height: 10),

          // Status + Detail
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusBadge(p.status),
              GestureDetector(
                onTap: () => _showDetailPengajuan(p),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Text('Detail',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _red)),
                      SizedBox(width: 2),
                      Icon(Icons.chevron_right, size: 14, color: _red),
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
    Color bg;
    Color textColor;
    String label;

    switch (status) {
      case 'sedang_dikerjakan':
        bg = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF065F46);
        label = 'Disetujui';
        break;
      case 'pending':
      default:
        bg = const Color(0xFFFFF3CD);
        textColor = const Color(0xFF856404);
        label = 'Menunggu Persetujuan';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: textColor)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: _grey.withOpacity(0.5)),
          const SizedBox(height: 12),
          const Text('Tidak ada pengajuan',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: _grey)),
          const SizedBox(height: 4),
          const Text('Belum ada pengajuan yang sesuai filter',
              style: TextStyle(fontSize: 12, color: _grey)),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _selectedSemester = 'Semua Semester';
                _selectedStatus = 'Semua Status';
                _selectedUrutan = 'Terbaru';
                _searchQuery = '';
                _searchController.clear();
              });
            },
            icon: const Icon(Icons.refresh, color: _red, size: 16),
            label: const Text('Reset Filter',
                style: TextStyle(color: _red, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}