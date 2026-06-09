import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';
import '../../widgets/admin/app_bottom_nav_admin.dart';
import '../../utils/nav_admin.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/api_service.dart';
import '../../models/dosen.dart';
import '../../services/dosen_service.dart';
import '../../utils/session_manager.dart';

class AdminManagementScreen extends StatefulWidget {
  final int initialTab;
  const AdminManagementScreen({super.key, this.initialTab = -1});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  static const Color _primaryRed = Color(0xFFB71C1C);
  static const Color _backgroundCream = Color(0xFFF5EFE6);
  static const Color _textDark = Color(0xFF2D2D2D);
  static const Color _textGrey = Color(0xFF9E9E9E);

  late int _activeTab;
  String? fileName;
  String? filePath;
  bool fileTooLarge = false;

  final DosenService _dosenService = DosenService();
  List<Dosen> _dosenList = [];
  List<Map<String, dynamic>> _mahasiswa = [];
  List<Map<String, dynamic>> _absensi = [];

  bool _isLoadingMhs = false;
  bool _isLoadingDosen = false;
  bool _isLoadingAbsensi = false;

  // ── SEARCH & FILTER ─────────────────────────────────────────────────────────
  final _searchMhsController    = TextEditingController();
  final _searchDosenController  = TextEditingController();
  final _searchAbsensiController = TextEditingController();
  String _searchMhs    = '';
  String _searchDosen  = '';
  String _searchAbsensi = '';

  String _selectedProdi    = 'Semua Prodi';
  String _selectedAngkatan = 'Semua Angkatan';

  final List<String> _prodiList = [
    'Semua Prodi',
    'D-IV Sistem Informasi Bisnis',
    'D-IV Teknik Informatika',
    'D-II Piranti Perangkat Lunak',
  ];

  final List<String> _angkatanList = [
    'Semua Angkatan', '2022', '2023', '2024', '2025',
  ];

  // ── LOAD DATA ────────────────────────────────────────────────────────────────
  Future<void> _loadDosen() async {
    setState(() => _isLoadingDosen = true);
    try {
      final data = await _dosenService.getAllDosen();
      setState(() => _dosenList = data);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() => _isLoadingDosen = false);
    }
  }

  Future<void> _loadMahasiswa() async {
    setState(() => _isLoadingMhs = true);
    try {
      final result = await ApiService.get('mahasiswa');
      if (result['success'] == true) {
        setState(() {
          _mahasiswa = List<Map<String, dynamic>>.from(
            result['data'].map((e) => {
              'id':        e['id_mahasiswa'],
              'nama':      e['nama_lengkap'],
              'nim':       e['nim'],
              'prodi':     e['program_studi'] ?? '',   // nama lengkap dari DB
              'prodiShort': _prodiShort(e['program_studi'] ?? ''),
              'status':    e['is_registered'] == 1,
            }),
          );
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() => _isLoadingMhs = false);
    }
  }

  Future<void> _loadAbsensi() async {
    setState(() => _isLoadingAbsensi = true);
    try {
      final result = await ApiService.get('absensi');
      if (result['success'] == true) {
        setState(() {
          _absensi = List<Map<String, dynamic>>.from(
            result['data'].map((e) => {
              'id_mahasiswa': e['id_mahasiswa'],
              'nama':       e['nama_lengkap'],
              'nim':        e['nim'],
              'prodi':      e['program_studi'] ?? '',
              'prodiShort': _prodiShort(e['program_studi'] ?? ''),
              'alpha':      e['total_alpha'] ?? 0,
              'izin':       e['total_izin']  ?? 0,
              'sakit':      e['total_sakit'] ?? 0,
            }),
          );
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() => _isLoadingAbsensi = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
    _loadDosen();
    _loadMahasiswa();
    _loadAbsensi();
  }

  // ── FILTERED LISTS ───────────────────────────────────────────────────────────
  int _angkatanFromNim(String nim) {
    if (nim.length >= 2) return int.tryParse(nim.substring(0, 2)) ?? 99;
    return 99;
  }

  // DB menyimpan nama lengkap, bukan kode singkat
  // Jadi _prodiCode sebenarnya mengembalikan nama lengkap untuk dikirim ke API
  String _prodiCode(String fullName) => fullName; // kirim apa adanya ke API

  // Untuk display singkat di card
  String _prodiShort(String fullName) {
    if (fullName.contains('Teknik Informatika')) return 'TI';
    if (fullName.contains('Sistem Informasi Bisnis')) return 'SIB';
    if (fullName.contains('Piranti')) return 'PPL';
    return fullName;
  }

  List<Map<String, dynamic>> get _filteredMahasiswa {
    final list = _mahasiswa.where((m) {
      final matchSearch = _searchMhs.isEmpty ||
          (m['nama'] as String).toLowerCase().contains(_searchMhs.toLowerCase()) ||
          (m['nim'] as String).contains(_searchMhs);
      // prodi di DB adalah nama lengkap persis, e.g. 'D-IV Sistem Informasi Bisnis'
      final matchProdi = _selectedProdi == 'Semua Prodi' ||
          (m['prodi'] as String).trim() == _selectedProdi.trim();
      // NIM: 244107060064 → 2 digit pertama = '24' = angkatan 2024
      // _selectedAngkatan = '2024' → ambil 2 digit terakhir = '24'
      final angkatanPrefix = _selectedAngkatan == 'Semua Angkatan'
          ? null
          : _selectedAngkatan.substring(_selectedAngkatan.length - 2);
      final matchAngkatan = angkatanPrefix == null ||
          (m['nim'] as String).startsWith(angkatanPrefix);
      return matchSearch && matchProdi && matchAngkatan;
    }).toList();

    list.sort((a, b) {
      final aA = _angkatanFromNim(a['nim'] as String);
      final bA = _angkatanFromNim(b['nim'] as String);
      if (aA != bA) return bA.compareTo(aA);
      return (b['nim'] as String).compareTo(a['nim'] as String);
    });
    return list;
  }

  List<Map<String, dynamic>> get _filteredDosen {
    final filtered = _dosenList
        .where((d) =>
            _searchDosen.isEmpty ||
            d.namaLengkap.toLowerCase().contains(_searchDosen.toLowerCase()) ||
            d.nip.contains(_searchDosen))
        .map((d) => {
              'id_dosen':   d.idDosen,
              'nama':       d.namaLengkap,
              'nip':        d.nip,
              'status':     d.isRegistered,
              'is_kaprodi': d.isKaprodi,
            })
        .toList();

    filtered.sort((a, b) {
      if ((a['is_kaprodi'] as bool) && !(b['is_kaprodi'] as bool)) return -1;
      if (!(a['is_kaprodi'] as bool) && (b['is_kaprodi'] as bool)) return 1;
      return (a['nama'] as String).compareTo(b['nama'] as String);
    });
    return filtered;
  }

  List<Map<String, dynamic>> get _filteredAbsensi {
    final list = _absensi.where((m) {
      final matchSearch = _searchAbsensi.isEmpty ||
          (m['nama'] as String).toLowerCase().contains(_searchAbsensi.toLowerCase()) ||
          (m['nim'] as String).contains(_searchAbsensi);
      final matchProdi = _selectedProdi == 'Semua Prodi' ||
          (m['prodi'] as String).trim() == _selectedProdi.trim();
      final angkatanPrefix = _selectedAngkatan == 'Semua Angkatan'
          ? null
          : _selectedAngkatan.substring(_selectedAngkatan.length - 2);
      final matchAngkatan = angkatanPrefix == null ||
          (m['nim'] as String).startsWith(angkatanPrefix);
      return matchSearch && matchProdi && matchAngkatan;
    }).toList();

    list.sort((a, b) {
      final aA = _angkatanFromNim(a['nim'] as String);
      final bA = _angkatanFromNim(b['nim'] as String);
      if (aA != bA) return aA.compareTo(bA);
      return (a['nim'] as String).compareTo(b['nim'] as String);
    });
    return list;
  }

  // ── SNACKBAR ─────────────────────────────────────────────────────────────────
  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red[700] : Colors.green[700],
    ));
  }

  // ════════════════════════════════════════════════════════════════════════════
  // MAHASISWA SHEETS
  // ════════════════════════════════════════════════════════════════════════════
  void _showTambahMahasiswaSheet() {
    final nimCtrl  = TextEditingController();
    final namaCtrl = TextEditingController();
    String selectedProdi = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          bool isSaving = false;
          return Padding(
            padding: EdgeInsets.only(
                left: 20, right: 20, top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sheetHeader('Tambah Mahasiswa', ctx),
                const SizedBox(height: 20),
                const Text('NIM', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _buildTextField(nimCtrl, 'Masukkan NIM', TextInputType.number),
                const SizedBox(height: 16),
                const Text('Nama Lengkap', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _buildTextField(namaCtrl, 'Masukkan nama mahasiswa'),
                const SizedBox(height: 16),
                const Text('Program Studi', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _buildProdiDropdown(selectedProdi, (val) => setLocal(() => selectedProdi = val!)),
                const SizedBox(height: 28),
 _buildSheetButtons(
  () => Navigator.pop(ctx),
  () async {
    if (nimCtrl.text.trim().isEmpty || namaCtrl.text.trim().isEmpty || selectedProdi.isEmpty) {
      _showSnack('Semua field harus diisi', isError: true);
      return;
    }
    setLocal(() => isSaving = true);
    final body = {
      'nim':           nimCtrl.text.trim(),
      'nama_lengkap':  namaCtrl.text.trim(),
      'program_studi': _prodiCode(selectedProdi),
    };
    debugPrint('POST mahasiswa body: $body');
    final result = await ApiService.post('mahasiswa', body);
    debugPrint('POST mahasiswa result: $result');
    setLocal(() => isSaving = false);
    if (result['success'] == true) {
      await _loadMahasiswa();    // ← load dulu
      if (ctx.mounted) Navigator.pop(ctx);  // ← baru pop
  _showSnack('Mahasiswa berhasil ditambahkan');
    } else {
      _showSnack(result['message'] ?? 'Gagal menambah mahasiswa', isError: true);
    }
  },
),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditMahasiswaSheet(Map<String, dynamic> item) {
    final namaCtrl = TextEditingController(text: item['nama']);
    String selectedProdi = item['prodi'] as String; // sudah nama lengkap dari DB

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: EdgeInsets.only(
              left: 20, right: 20, top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sheetHeader('Edit Mahasiswa', ctx),
              const SizedBox(height: 20),
              const Text('NIM', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _buildReadOnlyField(item['nim']),
              const SizedBox(height: 16),
              const Text('Nama Lengkap', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _buildTextField(namaCtrl, 'Masukkan nama mahasiswa'),
              const SizedBox(height: 16),
              const Text('Program Studi', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _buildProdiDropdown(selectedProdi, (val) => setLocal(() => selectedProdi = val!)),
              const SizedBox(height: 28),
              _buildSheetButtons(
                () => Navigator.pop(ctx),
                () async {
                  final result = await ApiService.put('mahasiswa/${item['id']}', {
                    'nama_lengkap':  namaCtrl.text.trim(),
                    'program_studi': _prodiCode(selectedProdi),
                  });
                  if (result['success'] == true) {
                    await _loadMahasiswa();
                    Navigator.pop(ctx);
                    _showSnack('Data mahasiswa berhasil diubah');
                  } else {
                    _showSnack(result['message'] ?? 'Gagal mengubah data', isError: true);
                  }
                },
                isEdit: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHapusMahasiswaDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => _hapusDialog(
        ctx,
        'Yakin menghapus data mahasiswa\n"${item['nama']}"?',
        () async {
          final result = await ApiService.delete('mahasiswa/${item['id']}');
          if (result['success'] == true) {
            await _loadMahasiswa();
            Navigator.pop(ctx);
            _showSnack('Mahasiswa berhasil dihapus');
          } else {
            Navigator.pop(ctx);
            _showSnack(result['message'] ?? 'Gagal menghapus mahasiswa', isError: true);
          }
        },
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // ABSENSI SHEETS
  // ════════════════════════════════════════════════════════════════════════════

  void _showDetailAbsensiSheet(Map<String, dynamic> item) async {
    List<Map<String, dynamic>> detail = [];
    bool isLoading = true;
    bool isEdit = false;
    List<TextEditingController> jamCtrl = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setLocal) {
          if (isLoading && detail.isEmpty) {
            ApiService.get('absensi/mahasiswa/${item['id_mahasiswa']}').then((result) {
              if (result['success'] == true) {
                final raw = List<Map<String, dynamic>>.from(result['data']);
                final jc = raw.map((r) => TextEditingController(text: '${r['jml_jam'] ?? 0}')).toList();
                setLocal(() {
                  detail    = raw;
                  jamCtrl   = jc;
                  isLoading = false;
                });
              } else {
                setLocal(() => isLoading = false);
              }
            });
          }

          // Warna berdasarkan status absensi
          Color statusColor(String? status) {
            switch (status) {
              case 'alpha': return Colors.red;
              case 'izin':  return Colors.blue;
              case 'sakit': return Colors.orange;
              default:      return Colors.grey;
            }
          }

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                _dragHandle(),
                const SizedBox(height: 12),
                // Header nama
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: _primaryRed.withOpacity(0.15),
                        child: Text(
                          (item['nama'] as String).split(' ').take(2).map((e) => e[0]).join().toUpperCase(),
                          style: const TextStyle(color: _primaryRed, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['nama'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            Text('${item['nim']} · ${item['prodiShort'] ?? item['prodi']}',
                                style: const TextStyle(fontSize: 11, color: _textGrey)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.close, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(color: _primaryRed),
                      )
                    : detail.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(32),
                            child: Text('Tidak ada data absensi',
                                style: TextStyle(color: _textGrey)),
                          )
                        : Flexible(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('DETAIL ABSENSI',
                                      style: TextStyle(
                                          fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                                  const SizedBox(height: 8),
                                  // Header tabel
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                        color: _primaryRed, borderRadius: BorderRadius.circular(8)),
                                    child: const Row(
                                      children: [
                                        Expanded(flex: 3, child: Text('Mata Kuliah',
                                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))),
                                        Expanded(child: Text('Status',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
                                        Expanded(child: Text('Jam',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
                                        SizedBox(width: 32),
                                      ],
                                    ),
                                  ),
                                  ...List.generate(detail.length, (index) {
                                    final row    = detail[index];
                                    final status = row['status'] as String?;
                                    final color  = statusColor(status);
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(color: Colors.black.withOpacity(0.06)))),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(row['nama_matkul'] ?? '-',
                                                    style: const TextStyle(
                                                        fontSize: 12, fontWeight: FontWeight.w500)),
                                                if (row['tanggal'] != null)
                                                  Text('${row['tanggal']}',
                                                      style: const TextStyle(fontSize: 10, color: _textGrey)),
                                              ],
                                            ),
                                          ),
                                          // Status badge
                                          Expanded(
                                            child: Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 4),
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                              decoration: BoxDecoration(
                                                  color: color.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8)),
                                              child: Text(
                                                status ?? '-',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color: color),
                                              ),
                                            ),
                                          ),
                                          // Jam (editable)
                                          Expanded(
                                            child: isEdit
                                                ? Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                    child: TextField(
                                                      controller: jamCtrl[index],
                                                      keyboardType: TextInputType.number,
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w700,
                                                          color: color),
                                                      decoration: const InputDecoration(
                                                          isDense: true,
                                                          contentPadding:
                                                              EdgeInsets.symmetric(vertical: 4)),
                                                    ),
                                                  )
                                                : Text('${row['jml_jam'] ?? 0}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w700,
                                                        color: color)),
                                          ),
                                          // Edit icon
                                          GestureDetector(
                                            onTap: () => setLocal(() => isEdit = true),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                  color: _primaryRed.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(6)),
                                              child: const Icon(Icons.edit_outlined,
                                                  size: 14, color: _primaryRed),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 8),
                                  const Row(children: [
                                    Text('Jam = jumlah jam ketidakhadiran',
                                        style: TextStyle(fontSize: 11, color: _textGrey)),
                                  ]),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),
                // Tombol bawah
                if (!isLoading && detail.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              if (isEdit) {
                                setLocal(() => isEdit = false);
                              } else {
                                Navigator.pop(ctx);
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _primaryRed,
                              side: const BorderSide(color: _primaryRed),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(isEdit ? 'Batal Edit' : 'Tutup'),
                          ),
                        ),
                        if (isEdit) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                bool allOk = true;
                                for (int i = 0; i < detail.length; i++) {
                                  final idAbsensi = detail[i]['id_absensi'];
                                  if (idAbsensi == null) continue;
                                  // API hanya terima jml_jam
                                  final result = await ApiService.put(
                                    'absensi/$idAbsensi',
                                    {'jml_jam': int.tryParse(jamCtrl[i].text) ?? 0},
                                  );
                                  if (result['success'] != true) allOk = false;
                                }
                                setLocal(() => isEdit = false);
                                await _loadAbsensi();
                                Navigator.pop(ctx);
                                _showSnack(
                                  allOk ? 'Absensi berhasil diperbarui' : 'Sebagian data gagal disimpan',
                                  isError: !allOk,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryRed,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
  void _showHapusAbsensiDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => _hapusDialog(
        ctx,
        'Yakin menghapus seluruh data absensi\n"${item['nama']}"?',
        () async {
          final result = await ApiService.delete('absensi/mahasiswa/${item['id_mahasiswa']}');
          if (result['success'] == true) {
            await _loadAbsensi();
            Navigator.pop(ctx);
            _showSnack('Data absensi berhasil dihapus');
          } else {
            Navigator.pop(ctx);
            _showSnack(result['message'] ?? 'Gagal menghapus absensi', isError: true);
          }
        },
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // DOSEN SHEETS  (sama seperti sebelumnya, sudah jalan)
  // ════════════════════════════════════════════════════════════════════════════
  void _showTambahDosenSheet() {
    final nipCtrl  = TextEditingController();
    final namaCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sheetHeader('Tambah Dosen', ctx),
            const SizedBox(height: 20),
            const Text('NIP', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _buildTextField(nipCtrl, 'Masukkan NIP', TextInputType.number),
            const SizedBox(height: 16),
            const Text('Nama Lengkap', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _buildTextField(namaCtrl, 'Masukkan nama lengkap dosen'),
            const SizedBox(height: 28),
            _buildSheetButtons(
              () => Navigator.pop(ctx),
              () async {
                final result = await ApiService.post('dosen', {
                  'nip':         nipCtrl.text.trim(),
                  'nama_lengkap': namaCtrl.text.trim(),
                });
                if (result['success'] == true) {
                  await _loadDosen();
                  Navigator.pop(ctx);
                  _showSnack('Dosen berhasil ditambahkan');
                } else {
                  _showSnack(result['message'] ?? 'Gagal menambah dosen', isError: true);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDosenSheet(Map<String, dynamic> item) {
    final namaCtrl = TextEditingController(text: item['nama']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sheetHeader('Edit Dosen', ctx),
            const SizedBox(height: 20),
            const Text('NIP', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _buildReadOnlyField(item['nip']),
            const SizedBox(height: 16),
            const Text('Nama Lengkap', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _buildTextField(namaCtrl, 'Masukkan nama lengkap dosen'),
            const SizedBox(height: 28),
            _buildSheetButtons(
              () => Navigator.pop(ctx),
              () async {
                final result = await ApiService.put('dosen/${item['id_dosen']}', {
                  'nama_lengkap': namaCtrl.text.trim(),
                });
                if (result['success'] == true) {
                  await _loadDosen();
                  Navigator.pop(ctx);
                  _showSnack('Data dosen berhasil diubah');
                } else {
                  _showSnack(result['message'] ?? 'Gagal mengubah data', isError: true);
                }
              },
              isEdit: true,
            ),
          ],
        ),
      ),
    );
  }

  void _showHapusDosenDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => _hapusDialog(
        ctx,
        'Yakin menghapus data dosen\n"${item['nama']}"?',
        () async {
          final result = await ApiService.delete('dosen/${item['id_dosen']}');
          if (result['success'] == true) {
            await _loadDosen();
            Navigator.pop(ctx);
            _showSnack('Dosen berhasil dihapus');
          } else {
            Navigator.pop(ctx);
            _showSnack(result['message'] ?? 'Gagal menghapus dosen', isError: true);
          }
        },
      ),
    );
  }

  void _showKaprodiDialog(Map<String, dynamic> dosen) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFFFCEEEE),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ganti Kaprodi',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              const Text('Kaprodi hanya boleh satu dosen.\nYakin ingin mengganti Kaprodi?',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: _primaryRed,
                          side: const BorderSide(color: _primaryRed),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text('Tidak'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final success = await _dosenService.setKaprodi(dosen['id_dosen']);
                        Navigator.pop(ctx);
                        if (success) {
                          await _loadDosen();
                          _showSnack('Kaprodi berhasil diperbarui');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryRed,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text('Ya', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── IMPORT SHEET ─────────────────────────────────────────────────────────────
  void _showImportSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: EdgeInsets.only(
              left: 20, right: 20, top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dragHandle(),
              const SizedBox(height: 16),
              const Text('Unggah File Data',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              const Text('Pilih file Excel atau CSV untuk diimpor',
                  style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['xlsx', 'xls', 'csv']);
                  if (result != null) {
                    final file = result.files.single;
                    setLocal(() {
                      fileName     = file.name;
                      filePath     = file.path;
                      fileTooLarge = file.size / (1024 * 1024) > 10;
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: fileTooLarge
                            ? Colors.red
                            : fileName != null
                                ? _primaryRed
                                : Colors.red.withOpacity(0.4),
                        width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                    color: fileTooLarge
                        ? Colors.red.withOpacity(0.05)
                        : fileName != null
                            ? _primaryRed.withOpacity(0.04)
                            : Colors.transparent,
                  ),
                  child: fileName != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: fileTooLarge
                                      ? Colors.red.withOpacity(0.1)
                                      : Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Icon(Icons.table_chart,
                                  color: fileTooLarge ? Colors.red : Colors.green, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(fileName!,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                Text(fileTooLarge ? 'File terlalu besar' : 'Siap diunggah',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: fileTooLarge ? Colors.red : const Color(0xFF9E9E9E))),
                              ],
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () => setLocal(() {
                                fileName     = null;
                                fileTooLarge = false;
                              }),
                              child: const Icon(Icons.close, size: 18, color: Colors.black45),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Icon(Icons.upload_outlined, size: 36, color: _primaryRed.withOpacity(0.6)),
                            const SizedBox(height: 8),
                            Text('Ketuk untuk memilih file',
                                style: TextStyle(fontWeight: FontWeight.w600, color: _primaryRed.withOpacity(0.8))),
                            const SizedBox(height: 4),
                            const Text('Format: .xlsx, .csv, .xls',
                                style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                            const Text('Maks. 10 MB',
                                style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                          ],
                        ),
                ),
              ),
              if (fileTooLarge) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3))),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                          child: Text('File terlalu besar! Maksimal 10 MB.',
                              style: TextStyle(fontSize: 12, color: Colors.red))),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (filePath != null && !fileTooLarge)
                          ? () async {
                              String endpoint = '';
                              switch (_activeTab) {
                                case 0: endpoint = 'mahasiswa/import'; break;
                                case 1: endpoint = 'dosen/import'; break;
                                case 2: endpoint = 'absensi/import'; break;
                              }
                              var result;
                              if (_activeTab == 2) {
                                final idAdmin = await SessionManager.getIdAdmin();
                                result = await ApiService.uploadFile(endpoint, filePath!,
                                    fields: {'id_admin': idAdmin.toString()});
                              } else {
                                result = await ApiService.uploadFile(endpoint, filePath!);
                              }
                              if (result == 200) {
                                switch (_activeTab) {
                                  case 0: await _loadMahasiswa(); break;
                                  case 1: await _loadDosen(); break;
                                  case 2: await _loadAbsensi(); break;
                                }
                                Navigator.pop(ctx);
                                _showSnack('Import berhasil');
                              } else {
                                _showSnack('Import gagal (kode: $result)', isError: true);
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryRed,
                          disabledBackgroundColor: _primaryRed.withOpacity(0.4),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Unggah Sekarang', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryRed,
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: _backgroundCream,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35), topRight: Radius.circular(35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Management Kompen',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _textDark)),
                        const SizedBox(height: 2),
                        const Text('Pengelolaan data',
                            style: TextStyle(fontSize: 13, color: _textGrey)),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _buildTabButton('Mahasiswa', 0),
                            const SizedBox(width: 8),
                            _buildTabButton('Dosen', 1),
                            const SizedBox(width: 8),
                            _buildTabButton('Absensi', 2),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _activeTab == -1
                        ? _buildEmptyState()
                        : _activeTab == 0
                            ? _buildMahasiswaTab()
                            : _activeTab == 1
                                ? _buildDosenTab()
                                : _buildAbsensiTab(),
                  ),
                ],
              ),
            ),
          ),
          AppBottomNavAdmin(
            activeTab: NavTabAdmin.management,
            onTap: (tab) => NavAdmin.handleBottomNav(context, tab, NavTabAdmin.management),
          ),
        ],
      ),
    );
  }

  // ── TABS ─────────────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group, size: 56, color: _textGrey.withOpacity(0.4)),
          const SizedBox(height: 12),
          const Text('Pilih tab terlebih dahulu', style: TextStyle(fontSize: 14, color: _textGrey)),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final bool isActive = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? _primaryRed : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isActive ? _primaryRed : Colors.black12),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : _textDark)),
        ),
      ),
    );
  }

  // ── TAB MAHASISWA ─────────────────────────────────────────────────────────────
  Widget _buildMahasiswaTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Row(
            children: [
              Expanded(
                child: _buildSearchField(
                    controller: _searchMhsController,
                    hint: 'Cari mahasiswa...',
                    onChanged: (val) => setState(() => _searchMhs = val)),
              ),
              const SizedBox(width: 8),
              _buildIconButton(Icons.upload_outlined, _showImportSheet),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Row(
            children: [
              Expanded(child: _buildDropdown(_prodiList, _selectedProdi,
                  (val) => setState(() => _selectedProdi = val!))),
              const SizedBox(width: 8),
              Expanded(child: _buildDropdown(_angkatanList, _selectedAngkatan,
                  (val) => setState(() => _selectedAngkatan = val!))),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _showTambahMahasiswaSheet,
                child: Container(
                  width: 38, height: 38,
                  decoration: const BoxDecoration(color: _primaryRed, shape: BoxShape.circle),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoadingMhs
              ? const Center(child: CircularProgressIndicator(color: _primaryRed))
              : _filteredMahasiswa.isEmpty
                  ? _buildEmptyFilter('Tidak ada mahasiswa sesuai filter')
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: _filteredMahasiswa.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _buildMahasiswaCard(_filteredMahasiswa[i]),
                    ),
        ),
      ],
    );
  }

  Widget _buildMahasiswaCard(Map<String, dynamic> item) {
  final bool terdaftar = item['status'] as bool;
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)]),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item['nama'],
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _textDark)),
              Text(
                'NIM: ${item['nim']} • ${item['prodiShort'] ?? item['prodi']}',
                style: const TextStyle(fontSize: 12, color: _textGrey),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: terdaftar ? Colors.green.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(
                  terdaftar ? 'Terdaftar' : 'Belum Terdaftar',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: terdaftar ? Colors.green[700] : Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _buildActionBtn(Icons.edit_outlined, _primaryRed, () => _showEditMahasiswaSheet(item)),
        const SizedBox(width: 6),
        _buildActionBtn(Icons.delete_outline, Colors.red, () => _showHapusMahasiswaDialog(item)),
      ],
    ),
  );
}

  // ── TAB DOSEN ─────────────────────────────────────────────────────────────────
  Widget _buildDosenTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Row(
            children: [
              Expanded(
                child: _buildSearchField(
                    controller: _searchDosenController,
                    hint: 'Cari dosen...',
                    onChanged: (val) => setState(() => _searchDosen = val)),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _showTambahDosenSheet,
                child: Container(
                  width: 38, height: 38,
                  decoration: const BoxDecoration(color: _primaryRed, shape: BoxShape.circle),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 8),
              _buildIconButton(Icons.upload_outlined, _showImportSheet),
            ],
          ),
        ),
        Expanded(
          child: _isLoadingDosen
              ? const Center(child: CircularProgressIndicator(color: _primaryRed))
              : _filteredDosen.isEmpty
                  ? _buildEmptyFilter('Belum ada data dosen')
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: _filteredDosen.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _buildDosenCard(_filteredDosen[i]),
                    ),
        ),
      ],
    );
  }

  Widget _buildDosenCard(Map<String, dynamic> item) {
    final bool terdaftar = item['status'] as bool;
    final bool isKaprodi = item['is_kaprodi'] as bool;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['nama'],
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _textDark)),
                    Text('NIP: ${item['nip']}',
                        style: const TextStyle(fontSize: 12, color: _textGrey)),
                  ],
                ),
              ),
              _buildActionBtn(Icons.edit_outlined, _primaryRed, () => _showEditDosenSheet(item)),
              const SizedBox(width: 6),
              _buildActionBtn(Icons.delete_outline, Colors.red, () => _showHapusDosenDialog(item)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: terdaftar ? Colors.green.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(
                  terdaftar ? 'Terdaftar' : 'Belum Terdaftar',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: terdaftar ? Colors.green[700] : Colors.grey[600]),
                ),
              ),
              Row(
                children: [
                  Text('Kaprodi',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: isKaprodi ? FontWeight.w700 : FontWeight.w400,
                          color: isKaprodi ? _primaryRed : _textGrey)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () { if (!isKaprodi) _showKaprodiDialog(item); },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48, height: 28,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: isKaprodi ? _primaryRed.withOpacity(0.3) : Colors.grey.withOpacity(0.25),
                          border: Border.all(
                              color: isKaprodi ? _primaryRed.withOpacity(0.4) : Colors.grey.withOpacity(0.4))),
                      child: Align(
                        alignment: isKaprodi ? Alignment.centerRight : Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Container(
                            width: 22, height: 22,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isKaprodi ? _primaryRed : Colors.grey[500]),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── TAB ABSENSI ───────────────────────────────────────────────────────────────
  Widget _buildAbsensiTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Row(
            children: [
              Expanded(
                child: _buildSearchField(
                    controller: _searchAbsensiController,
                    hint: 'Cari mahasiswa...',
                    onChanged: (val) => setState(() => _searchAbsensi = val)),
              ),
              const SizedBox(width: 8),
              _buildIconButton(Icons.upload_outlined, _showImportSheet),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Row(
            children: [
              Expanded(child: _buildDropdown(_prodiList, _selectedProdi,
                  (val) => setState(() => _selectedProdi = val!))),
              const SizedBox(width: 8),
              Expanded(child: _buildDropdown(_angkatanList, _selectedAngkatan,
                  (val) => setState(() => _selectedAngkatan = val!))),
            ],
          ),
        ),
        Expanded(
          child: _isLoadingAbsensi
              ? const Center(child: CircularProgressIndicator(color: _primaryRed))
              : _filteredAbsensi.isEmpty
                  ? _buildEmptyFilter('Tidak ada data absensi sesuai filter')
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: _filteredAbsensi.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _buildAbsensiCard(_filteredAbsensi[i]),
                    ),
        ),
      ],
    );
  }

  Widget _buildAbsensiCard(Map<String, dynamic> item) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)]),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item['nama'],
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _textDark)),
              Text(
                'NIM: ${item['nim']} • ${item['prodiShort'] ?? item['prodi']}',
                style: const TextStyle(fontSize: 12, color: _textGrey),
              ), // ← INI YANG KURANG
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildAbsensiChip('A', item['alpha'] ?? 0, Colors.red),
                  const SizedBox(width: 12),
                  _buildAbsensiChip('I', item['izin'] ?? 0, Colors.blue),
                  const SizedBox(width: 12),
                  _buildAbsensiChip('S', item['sakit'] ?? 0, Colors.orange),
                ],
              ),
            ],
          ),
        ),
        _buildActionBtn(Icons.search, _primaryRed, () => _showDetailAbsensiSheet(item)),
        const SizedBox(width: 6),
        _buildActionBtn(Icons.delete_outline, Colors.red, () => _showHapusAbsensiDialog(item)),
      ],
    ),
  );
}

  // ════════════════════════════════════════════════════════════════════════════
  // REUSABLE WIDGETS
  // ════════════════════════════════════════════════════════════════════════════
  Widget _dragHandle() => Center(
        child: Container(
          width: 40, height: 4,
          decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)),
        ),
      );

  Widget _sheetHeader(String title, BuildContext ctx) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          GestureDetector(onTap: () => Navigator.pop(ctx), child: const Icon(Icons.close)),
        ],
      );

  Widget _hapusDialog(BuildContext ctx, String msg, VoidCallback onYa) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Data', textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(msg, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
                foregroundColor: _primaryRed,
                side: const BorderSide(color: _primaryRed),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10)),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: onYa,
            style: ElevatedButton.styleFrom(
                backgroundColor: _primaryRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10)),
            child: const Text('Ya', style: TextStyle(color: Colors.white)),
          ),
        ],
      );

  Widget _buildEmptyFilter(String msg) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.manage_accounts, size: 48, color: _textGrey.withOpacity(0.4)),
            const SizedBox(height: 8),
            Text(msg, style: const TextStyle(color: _textGrey)),
          ],
        ),
      );

  Widget _buildSearchField({
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChanged,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black12)),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: Colors.black38),
            prefixIcon: const Icon(Icons.search, size: 18, color: Colors.black38),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      );

  Widget _buildDropdown(List<String> items, String value, void Function(String?) onChanged) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black12)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down, size: 18),
            style: const TextStyle(fontSize: 13, color: Color(0xFF2D2D2D)),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onChanged,
          ),
        ),
      );

  Widget _buildProdiDropdown(String selectedProdi, void Function(String?) onChanged) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
            color: const Color(0xFFF5EFE6), borderRadius: BorderRadius.circular(10)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedProdi.isEmpty ? null : selectedProdi,
            hint: const Text('Pilih Program Studi',
                style: TextStyle(fontSize: 13, color: Colors.black38)),
            isExpanded: true,
            items: _prodiList
                .skip(1)
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      );

  Widget _buildTextField(TextEditingController ctrl, String hint,
          [TextInputType type = TextInputType.text]) =>
      TextField(
        controller: ctrl,
        keyboardType: type,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: Colors.black38),
          filled: true,
          fillColor: const Color(0xFFF5EFE6),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      );

  Widget _buildReadOnlyField(String value) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300]!)),
        child: Row(
          children: [
            Expanded(child: Text(value, style: TextStyle(fontSize: 13, color: Colors.grey[600]))),
            Icon(Icons.lock_outline, size: 16, color: Colors.grey[400]),
          ],
        ),
      );

  Widget _buildActionBtn(IconData icon, Color color, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: color),
        ),
      );

  Widget _buildAbsensiChip(String label, int value, Color color) =>
      Text('$label = $value',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color));

  Widget _buildIconButton(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42, height: 42,
          decoration: BoxDecoration(color: _primaryRed, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      );

  Widget _buildSheetButtons(VoidCallback onBatal, VoidCallback onSimpan,
      {bool isEdit = false}) =>
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onBatal,
              style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryRed,
                  side: const BorderSide(color: _primaryRed),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Batal'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: onSimpan,
              style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryRed,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text(isEdit ? 'Simpan Perubahan' : 'Simpan',
                  style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      );

  // ── HELPERS ───────────────────────────────────────────────────────────────────
}