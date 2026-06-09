import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';
import '../../widgets/admin/app_bottom_nav_admin.dart';
import '../../utils/nav_admin.dart';
import 'package:provider/provider.dart';
import '../../providers/pengajuan_provider.dart';
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

class _FormPenyelesaian {
  final String namaMahasiswa;
  final String nim;
  final String mataKuliah;
  final String semester;
  final String jenisPekerjaan;
  final String tanggalSelesai;
  final int jam;
  String status;

  _FormPenyelesaian({
    required this.namaMahasiswa,
    required this.nim,
    required this.mataKuliah,
    required this.semester,
    required this.jenisPekerjaan,
    required this.tanggalSelesai,
    required this.jam,
    required this.status,
  });
}

class AdminVerifikasiScreen extends StatefulWidget {
  const AdminVerifikasiScreen({super.key});

  @override
  State<AdminVerifikasiScreen> createState() => _AdminVerifikasiScreenState();
}

class _AdminVerifikasiScreenState extends State<AdminVerifikasiScreen> {
  String namaKaprodi = '';
  String nipKaprodi = '';

bool _isInitialized = false;
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  final PengajuanService _pengajuanService = PengajuanService();
List<PengajuanKompen> _pengajuanList = [];

Future<void> _loadData() async {
  final idAdmin = await SessionManager.getIdAdmin();

  print("ID ADMIN = $idAdmin");

  if (idAdmin == null) return;

  final data = await _pengajuanService.getPengajuanAdmin(idAdmin);

  final kaprodi = await _pengajuanService.getKaprodi();

  print("JUMLAH DATA = ${data.length}");

  setState(() {
    _pengajuanList = data;

    if (kaprodi != null) {
      namaKaprodi = kaprodi['nama'];
      nipKaprodi = kaprodi['nip'];
    }
  });
}
  String _selectedSemester = 'Semua Semester';
  String _selectedStatus = 'Semua Status';

  final List<String> _semesterOptions = [
    'Semua Semester',
    'Semester 1', 'Semester 2', 'Semester 3', 'Semester 4',
    'Semester 5', 'Semester 6', 'Semester 7', 'Semester 8',
  ];

  final List<String> _statusOptions = [
    'Semua Status', 'Menunggu TTD', 'Sudah TTD',
  ];


  List<PengajuanKompen> get _filteredList {
    final data =
        context.read<PengajuanProvider>().pengajuanAdmin;

    final filtered = data.where((p) {

      final semesterText = 'Semester ${p.semester}';

      final matchSemester =
          _selectedSemester == 'Semua Semester' ||
          semesterText == _selectedSemester;

      final matchStatus =
          _selectedStatus == 'Semua Status' ||
          (_selectedStatus == 'Menunggu TTD' &&
              p.status == 'menunggu_ttd_admin') ||
          (_selectedStatus == 'Sudah TTD' &&
              p.status ==  'menunggu_ttd_kaprodi' ||
                p.status == 'selesai');

      return matchSemester && matchStatus;
    }).toList();

    filtered.sort((a, b) {
      if (a.status == 'menunggu_ttd_admin' &&
          b.status != 'menunggu_ttd_admin') {
        return -1;
      }

      if (a.status != 'menunggu_ttd_admin' &&
          b.status == 'menunggu_ttd_admin') {
        return 1;
      }

      return 0;
    });

    return filtered;
  }

  void _showFormVerifikasi(PengajuanKompen p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        bool sudahTTD = p.status == 'menunggu_ttd_kaprodi';
        return StatefulBuilder(
          builder: (ctx, setLocal) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, scrollCtrl) => Column(
              children: [
                // Handle bar
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

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // Kop surat
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
            child: const Icon(Icons.school, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('POLITEKNIK NEGERI MALANG',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
                Text('JURUSAN TEKNOLOGI INFORMASI',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                Text('PROGRAM STUDI D-IV SISTEM INFORMASI BISNIS',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
                SizedBox(height: 2),
                Text('Jl. Soekarno Hatta No.9 Malang 65141 · Telp. (0341) 404424',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 8, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    ),
    const SizedBox(height: 16),
    Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFE6),
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

                        // Info pengajar
                        _buildFormRow('Nama Admin', p.namaTujuan ?? '-'),
                        const SizedBox(height: 12),
                        const Text(
                          'Memberikan rekomendasi kompensasi kepada:',
                          style: TextStyle(fontSize: 12, color: _darkV),
                        ),
                        const SizedBox(height: 8),

                        // Info mahasiswa
                        _buildFormRow('Nama Mahasiswa', p.namaMahasiswa ?? '-'),
                        _buildFormRow('NIM',p.nim ?? '-'),
                        _buildFormRow('Semester',
                            p.semester.replaceAll('Semester ', 'Semester ')),
                        _buildFormRow('Mata Kuliah', p.namaMatkul ?? '-'),
                        _buildFormRow('Pekerjaan',p.deskripsiTugas ?? '-' ),
                        _buildFormRow('Jumlah Jam',
                            '${p.totalJamKompen ?? 0} (${_jamTerbilang(p.totalJamKompen ?? 0)} Jam)'),
                        const SizedBox(height: 16),

                        // Tanggal
                        Text('Malang, ${p.tanggalPertemuan?.toString().split(' ')[0] ?? '-'}',
                            style: const TextStyle(fontSize: 12, color: _darkV)),
                        const SizedBox(height: 16),

                        // TTD section
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Kiri - Dosen
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Yang memberikan rekomendasi,',
                                      style: TextStyle(fontSize: 11, color: _darkV)),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 110,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Center(
                                      child: sudahTTD
                                      
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      QrImageView(
                                        data: p.kodeTtdTujuan ?? '',
                                        version: QrVersions.auto,
                                        size: 100,
                                      ),

                                    ],
                                  )
                                            
                                          : Text('Belum\nditandatangani',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 9,
                                                  color: _greyV)),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    p.namaTujuan ?? '-',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: _darkV,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Kanan - Kaprodi
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Mengetahui, Ka. Program Studi',
                                      style: TextStyle(fontSize: 11, color: _darkV)),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 110,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Center(
                                      child: Text('Belum\nditandatangani',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 9, color: _greyV)),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                  namaKaprodi,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: _darkV,
                                  ),),
                                 Text(
                                  'NIP. $nipKaprodi',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: _greyV,
                                  ),
                                ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Tombol
                        // SESUDAH — disamain gaya dengan pengajuan
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
      await PengajuanService().ttdAdmin(p.idPengajuan);
      if (success) {
        await _loadData(); // refresh data terbaru

        setLocal(() => sudahTTD = true);

        Navigator.pop(ctx);
      }
    },
        icon: Icon(Icons.check,
            size: 16,
            color: sudahTTD ? Colors.grey[500] : Colors.white),
        label: Text('Tandatangani',
            style: TextStyle(
                color: sudahTTD ? Colors.grey[500] : Colors.white)),
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

Widget _buildFormRow(String label, String value, {bool isAlt = false}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(
      color: isAlt ? const Color(0xFFF5EFE6) : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(label,
              style: const TextStyle(fontSize: 12, color: _greyV)),
        ),
        const Text(': ', style: TextStyle(fontSize: 12, color: _darkV)),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: _darkV)),
        ),
      ],
    ),
  );
}

  String _jamTerbilang(int jam) {
    const terbilang = ['', 'Satu', 'Dua', 'Tiga', 'Empat', 'Lima',
        'Enam', 'Tujuh', 'Delapan', 'Sembilan', 'Sepuluh'];
    if (jam <= 10) return terbilang[jam];
    return '$jam';
  }

  @override
  Widget build(BuildContext context) {
      if (!_isInitialized) {
    _isInitialized = true;

    Future.microtask(() async {
      final idAdmin = await SessionManager.getIdAdmin();

      if (idAdmin != null && mounted) {
        context
            .read<PengajuanProvider>()
            .getPengajuanAdmin(idAdmin);
      }
    });
  }
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
                        const Text(
                            'Form penyelesaian kompen yang perlu ditandatangani',
                            style: TextStyle(fontSize: 13, color: _greyV)),
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
                    child: _filteredList.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            itemCount: _filteredList.length,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildCard(_filteredList[index]),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          AppBottomNavAdmin(
            activeTab: NavTabAdmin.verifikasi,
            onTap: (tab) => NavAdmin.handleBottomNav(
                context, tab, NavTabAdmin.verifikasi),
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
        border: Border.all(color: _cardBorderV),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: _greyV, size: 18),
          style: const TextStyle(fontSize: 12, color: _darkV),
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e,
                        style:
                            const TextStyle(fontSize: 12, color: _darkV)),
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
          // Nama + tanggal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(p.namaMahasiswa ?? '-',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _darkV)),
              Text(p.tanggalPertemuan?.toString().split(' ')[0] ?? '-',
                  style: const TextStyle(fontSize: 10, color: _greyV)),
            ],
          ),
          const SizedBox(height: 2),
          Text('NIM: ${p.nim}',
              style: const TextStyle(fontSize: 11, color: _greyV)),
          const SizedBox(height: 10),

          // Matkul + semester
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.menu_book_outlined,
                    size: 13, color: _greyV),
                const SizedBox(width: 4),
                Text(p.deskripsiTugas ?? '-',
                    style:
                        const TextStyle(fontSize: 12, color: _darkV)),
              ]),
              Row(children: [
                const Icon(Icons.school_outlined,
                    size: 13, color: _greyV),
                const SizedBox(width: 4),
                Text(p.semester,
                    style:
                        const TextStyle(fontSize: 11, color: _greyV)),
              ]),
            ],
          ),
          const SizedBox(height: 6),

          // Nama Lokasi
          Row(children: [
            const Icon(Icons.location_on_outlined ,
                size: 13, color: _greyV),
            const SizedBox(width: 4),
            Expanded(
              child: Text(p.namaLokasi ?? '-',
                  style: const TextStyle(fontSize: 12, color: _darkV),
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
          const SizedBox(height: 6),

          // Titik koordinat
          Row(children: [
            const Icon(Icons.near_me_outlined,
                size: 13, color: _greyV),
            const SizedBox(width: 4),
            Text('${p.latitude}, ${p.longitude}',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _darkV)),
          ]),
          const SizedBox(height: 10),

          // Status + Detail
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusBadge(p.status),
              GestureDetector(
                onTap: () => _showFormVerifikasi(p),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
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

  Widget _buildStatusBadge(String status) {
    final bool menunggu = status == 'menunggu_ttd_admin';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: menunggu
            ? const Color(0xFFFFF3CD)
            : const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        menunggu ? 'Menunggu TTD' : 'Sudah TTD',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: menunggu
              ? const Color(0xFF856404)
              : const Color(0xFF065F46),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.draw_outlined,
              size: 48, color: _greyV.withOpacity(0.5)),
          const SizedBox(height: 12),
          const Text('Tidak ada form penyelesaian',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _greyV)),
          const SizedBox(height: 4),
          const Text('Belum ada form yang sesuai filter',
              style: TextStyle(fontSize: 12, color: _greyV)),
        ],
      ),
    );
  }
}