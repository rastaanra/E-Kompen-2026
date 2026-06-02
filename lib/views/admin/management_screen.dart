import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';
import '../../widgets/admin/app_bottom_nav_admin.dart';
import '../../utils/nav_admin.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/api_service.dart';
import '../../models/dosen.dart';
import '../../services/dosen_service.dart';

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

  Future<void> _loadDosen() async {
  try {
    final data = await _dosenService.getAllDosen();
      print('JUMLAH DOSEN: ${data.length}');
      setState(() {
        _dosenList = data;
      });
    } catch (e) {
      print(e);
      debugPrint(e.toString());
    }
  }

  List<Map<String, dynamic>> _mahasiswa = [];

  Future<void> _loadMahasiswa() async {
  try {
    final result = await ApiService.get('mahasiswa');

    if (result['success']) {
      setState(() {
        _mahasiswa = List<Map<String, dynamic>>.from(
          result['data'].map(
            (e) => {
              'id': e['id_mahasiswa'],
              'nama': e['nama_lengkap'],
              'nim': e['nim'],
              'prodi': e['program_studi'],
              'status': e['is_registered'],
            },
          ),
        );
      });
    }
  } catch (e) {
    print(e);
  }
}

  @override
  void initState() {
    super.initState();

    _activeTab = widget.initialTab;

    _loadDosen();
    _loadMahasiswa();
  }

  final _searchMhsController = TextEditingController();
  final _searchDosenController = TextEditingController();
  final _searchAbsensiController = TextEditingController();
  String _searchMhs = '';
  String _searchDosen = '';
  String _searchAbsensi = '';

  // ── DUMMY DATA MAHASISWA
  final List<Map<String, dynamic>> _dummyMahasiswa = [
    {'nama': 'Sally Savista', 'nim': '244107060064', 'prodi': 'TI', 'status': true},
    {'nama': 'Michael Jordan', 'nim': '244107060065', 'prodi': 'TI', 'status': true},
    {'nama': 'Asep Maulana', 'nim': '254107060099', 'prodi': 'SIB', 'status': false},
    {'nama': 'Budi Santoso', 'nim': '254107060100', 'prodi': 'SIB', 'status': true},
  ];


  // ── DUMMY DATA ABSENSI
  final List<Map<String, dynamic>> _dummyAbsensi = [
    {
      'nama': 'Sally Savista',
      'nim': '244107060064',
      'prodi': 'TI',
      'detail': [
        {'matkul': 'Basis Data', 'tanggal': '2026-05-12', 'alpha': 2, 'izin': 0, 'sakit': 1},
        {'matkul': 'Pemrograman Mobile', 'tanggal': '2026-05-15', 'alpha': 3, 'izin': 1, 'sakit': 0},
        {'matkul': 'Jaringan Komputer', 'tanggal': '2026-05-18', 'alpha': 1, 'izin': 0, 'sakit': 2},
      ],
    },
    {
      'nama': 'Michael Jordan',
      'nim': '244107060065',
      'prodi': 'TI',
      'detail': [
        {'matkul': 'Basis Data', 'tanggal': '2026-05-12', 'alpha': 0, 'izin': 1, 'sakit': 0},
        {'matkul': 'Pemrograman Mobile', 'tanggal': '2026-05-15', 'alpha': 2, 'izin': 0, 'sakit': 1},
        {'matkul': 'Workshop Mobile', 'tanggal': '2026-05-20', 'alpha': 1, 'izin': 2, 'sakit': 0},
      ],
    },
    {
      'nama': 'Asep Maulana',
      'nim': '254107060099',
      'prodi': 'SIB',
      'detail': [
        {'matkul': 'Manajemen Proyek', 'tanggal': '2026-05-11', 'alpha': 4, 'izin': 0, 'sakit': 0},
        {'matkul': 'Analisis Bisnis', 'tanggal': '2026-05-14', 'alpha': 1, 'izin': 1, 'sakit': 1},
        {'matkul': 'Data Warehouse', 'tanggal': '2026-05-16', 'alpha': 0, 'izin': 2, 'sakit': 0},
      ],
    },
    {
      'nama': 'Budi Santoso',
      'nim': '254107060100',
      'prodi': 'SIB',
      'detail': [
        {'matkul': 'Business Intelligence', 'tanggal': '2026-05-10', 'alpha': 0, 'izin': 0, 'sakit': 3},
        {'matkul': 'ERP', 'tanggal': '2026-05-13', 'alpha': 2, 'izin': 1, 'sakit': 0},
        {'matkul': 'Data Mining', 'tanggal': '2026-05-17', 'alpha': 1, 'izin': 0, 'sakit': 1},
      ],
    },
  ];

  String _selectedProdi = 'Semua Prodi';
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

  int _angkatanFromNim(String nim) {
    if (nim.length >= 2) {
      return int.tryParse(nim.substring(0, 2)) ?? 99;
    }
    return 99;
  }

  List<Map<String, dynamic>> get _filteredMahasiswa {
    final list = _mahasiswa.where((m) {
      final matchSearch = _searchMhs.isEmpty ||
          m['nama'].toLowerCase().contains(_searchMhs.toLowerCase()) ||
          m['nim'].contains(_searchMhs);
      final matchProdi = _selectedProdi == 'Semua Prodi' ||
          (_selectedProdi == 'D-IV Teknik Informatika' && m['prodi'] == 'TI') ||
          (_selectedProdi == 'D-IV Sistem Informasi Bisnis' && m['prodi'] == 'SIB');
      final matchAngkatan = _selectedAngkatan == 'Semua Angkatan' ||
          m['nim'].startsWith(_selectedAngkatan.substring(2));
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
            d.namaLengkap
                .toLowerCase()
                .contains(_searchDosen.toLowerCase()) ||
            d.nip.contains(_searchDosen))
        .map((d) => {
              'id_dosen': d.idDosen,
              'nama': d.namaLengkap,
              'nip': d.nip,
              'status': d.isRegistered,
              'is_kaprodi': d.isKaprodi,
            })
        .toList();

        filtered.sort((a, b) {
      if ((a['is_kaprodi'] as bool) &&
          !(b['is_kaprodi'] as bool)) {
        return -1;
      }

      if (!(a['is_kaprodi'] as bool) &&
          (b['is_kaprodi'] as bool)) {
        return 1;
      }

      return (a['nama'] as String)
          .compareTo(b['nama'] as String);
    });

    return filtered;
  }

  List<Map<String, dynamic>> get _filteredAbsensi {
    final list = _dummyAbsensi.where((m) {
      final matchSearch = _searchAbsensi.isEmpty ||
          m['nama'].toLowerCase().contains(_searchAbsensi.toLowerCase()) ||
          m['nim'].contains(_searchAbsensi);
      final matchProdi = _selectedProdi == 'Semua Prodi' ||
          (_selectedProdi == 'D-IV Teknik Informatika' && m['prodi'] == 'TI') ||
          (_selectedProdi == 'D-IV Sistem Informasi Bisnis' && m['prodi'] == 'SIB');
      final matchAngkatan = _selectedAngkatan == 'Semua Angkatan' ||
          m['nim'].startsWith(_selectedAngkatan.substring(2));
      return matchSearch && matchProdi && matchAngkatan;
    }).toList();

    list.sort((a, b) {
      final aA = _angkatanFromNim(a['nim'] as String);
      final bA = _angkatanFromNim(b['nim'] as String);
      if (aA != bA) return aA.compareTo(bA);
      return (a['nim'] as String).compareTo(a['nim'] as String);
    });

    return list;
  }

  void _showImportSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {

          return Padding(
            padding: EdgeInsets.only(
              left: 20, right: 20, top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
            ),
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
                const Text('Unggah File Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                const Text('Pilih file Excel atau CSV untuk diimpor', style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                  final result =
                      await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: [
                      'xlsx',
                      'xls',
                      'csv',
                    ],
                  );

                  if (result != null) {

                    final file = result.files.single;

                    print('FILE DIPILIH');
                    print(file.name);
                    print(file.path);

                    setLocal(() {

                      fileName = file.name;
                      filePath = file.path;

                      final sizeInMB =
                          file.size / (1024 * 1024);

                      fileTooLarge =
                          sizeInMB > 10;

                    });
                    } else {

                      print('TIDAK ADA FILE DIPILIH');

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
                        width: 1.5,
                      ),
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
                                  color: fileTooLarge ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.table_chart, color: fileTooLarge ? Colors.red : Colors.green, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(fileName!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  Text(
                                    fileTooLarge ? '12.4 MB • Microsoft Excel' : '142 KB • Microsoft Excel',
                                    style: TextStyle(fontSize: 11, color: fileTooLarge ? Colors.red : const Color(0xFF9E9E9E)),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () => setLocal(() {
                                  fileName = null;
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
                              Text('Ketuk untuk memilih file', style: TextStyle(fontWeight: FontWeight.w600, color: _primaryRed.withOpacity(0.8))),
                              const SizedBox(height: 4),
                              const Text('Format: .xlsx, .csv, .xls', style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                              const Text('Maks. 10 MB', style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
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
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.red, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text('File terlalu besar! Maksimal ukuran file adalah 10 MB.', style: TextStyle(fontSize: 12, color: Colors.red)),
                        ),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (filePath != null && !fileTooLarge)
                        ? () async {
                          print('TOMBOL UNGGAH DIKLIK');
                          print(filePath);
                          print('SEBELUM UPLOAD');
                            try {
                              // nanti upload ke endpoint import di sini
                              String endpoint = '';
                                switch (_activeTab) {
                                  case 0:
                                    endpoint = 'mahasiswa/import';
                                    break;

                                  case 1:
                                    endpoint = 'dosen/import';
                                    break;

                                  case 2:
                                    endpoint = 'absensi/import';
                                    break;
                                }
                                print('_activeTab = $_activeTab');
                                print('endpoint = $endpoint');
                                print('filePath = $filePath');

                                final result =
                                    await ApiService.uploadFile(
                                  endpoint,
                                  filePath!,
                                );
                                print('HASIL API: $result');

                                if (result == 200) {
                                  await _loadDosen();

                                  Navigator.pop(ctx);

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Import berhasil',
                                      ),
                                    ),
                                  );

                                } else {

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Import gagal ($result)',
                                      ),
                                    ),
                                  );
                                }

                            } catch (e) {

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString(),
                                  ),
                                ),
                              );
                            }

                          }
                        : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryRed,
                          disabledBackgroundColor: _primaryRed.withOpacity(0.4),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Unggah Sekarang', style: TextStyle(color: Colors.white)),
                        
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showTambahMahasiswaSheet() {
    final nimCtrl = TextEditingController();
    final namaCtrl = TextEditingController();
    String selectedProdi = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tambah Mahasiswa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  GestureDetector(onTap: () => Navigator.pop(ctx), child: const Icon(Icons.close)),
                ],
              ),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: const Color(0xFFF5EFE6), borderRadius: BorderRadius.circular(10)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedProdi.isEmpty ? null : selectedProdi,
                    hint: const Text('Pilih Program Studi', style: TextStyle(fontSize: 13, color: Colors.black38)),
                    isExpanded: true,
                    items: _prodiList.skip(1).map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setLocal(() => selectedProdi = val!),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              _buildSheetButtons(() => Navigator.pop(ctx), () => Navigator.pop(ctx)),
            ],
          ),
        ),
      ),
    );
  }

  void _showTambahAbsensiSheet() {
    final namaCtrl = TextEditingController();
    final nimCtrl = TextEditingController();
    final matkulCtrl = TextEditingController();
    final alphaCtrl = TextEditingController(text: '0');
    final izinCtrl = TextEditingController(text: '0');
    final sakitCtrl = TextEditingController(text: '0');
    String selectedProdi = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tambah Data Absensi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  GestureDetector(onTap: () => Navigator.pop(ctx), child: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Nama', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _buildTextField(namaCtrl, 'Masukkan Nama', TextInputType.text),
              const SizedBox(height: 16),
              const Text('NIM', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _buildTextField(nimCtrl, 'Masukkan NIM', TextInputType.number),
              const SizedBox(height: 16),
              const Text('Program Studi', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: const Color(0xFFF5EFE6), borderRadius: BorderRadius.circular(10)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedProdi.isEmpty ? null : selectedProdi,
                    hint: const Text('Pilih Program Studi', style: TextStyle(fontSize: 13, color: Colors.black38)),
                    isExpanded: true,
                    items: _prodiList.skip(1).map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setLocal(() => selectedProdi = val!),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Mata Kuliah', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _buildTextField(matkulCtrl, 'Masukkan Mata Kuliah'),
              const SizedBox(height: 16),
              const Text('Jumlah Ketidakhadiran', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildAbsensiInput(alphaCtrl, 'Alpha', Colors.red)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildAbsensiInput(izinCtrl, 'Izin', Colors.blue)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildAbsensiInput(sakitCtrl, 'Sakit', Colors.orange)),
                ],
              ),
              const SizedBox(height: 28),
              _buildSheetButtons(
                () => Navigator.pop(ctx),
                () {
                  final nama = namaCtrl.text.trim();
                  final nim = nimCtrl.text.trim();
                  final prodi = selectedProdi.isEmpty ? 'TI' : (selectedProdi == 'D-IV Teknik Informatika' ? 'TI' : selectedProdi == 'D-IV Sistem Informasi Bisnis' ? 'SIB' : 'PPL');
                  if (nim.isNotEmpty) {
                    setState(() {
                      final existing = _dummyAbsensi.indexWhere((e) => e['nim'] == nim);
                      if (existing != -1) {
                        _dummyAbsensi[existing]['detail'].add({
                          'matkul': matkulCtrl.text,
                          'tanggal': '2026-06-01',
                          'alpha': int.tryParse(alphaCtrl.text) ?? 0,
                          'izin': int.tryParse(izinCtrl.text) ?? 0,
                          'sakit': int.tryParse(sakitCtrl.text) ?? 0,
                        });
                      } else {
                        _dummyAbsensi.add({
                          'nama': nama,
                          'nim': nim,
                          'prodi': prodi,
                          'detail': [
                            {
                              'matkul': matkulCtrl.text,
                              'tanggal': '2026-06-01',
                              'alpha': int.tryParse(alphaCtrl.text) ?? 0,
                              'izin': int.tryParse(izinCtrl.text) ?? 0,
                              'sakit': int.tryParse(sakitCtrl.text) ?? 0,
                            }
                          ]
                        });
                      }
                    });
                  }
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditMahasiswaSheet(Map<String, dynamic> item) {
    final namaCtrl = TextEditingController(text: item['nama']);
    String selectedProdi = item['prodi'] == 'TI' ? 'D-IV Teknik Informatika' : item['prodi'] == 'SIB' ? 'D-IV Sistem Informasi Bisnis' : 'D-II Piranti Perangkat Lunak';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Edit Mahasiswa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  GestureDetector(onTap: () => Navigator.pop(ctx), child: const Icon(Icons.close)),
                ],
              ),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: const Color(0xFFF5EFE6), borderRadius: BorderRadius.circular(10)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedProdi.isEmpty ? null : selectedProdi,
                    hint: const Text('Pilih Program Studi', style: TextStyle(fontSize: 13, color: Colors.black38)),
                    isExpanded: true,
                    items: _prodiList.skip(1).map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setLocal(() => selectedProdi = val!),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              _buildSheetButtons(() => Navigator.pop(ctx), () => Navigator.pop(ctx), isEdit: true),
            ],
          ),
        ),
      ),
    );
  }

  void _showTambahDosenSheet() {
    final nipCtrl = TextEditingController();
    final namaCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tambah Dosen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                GestureDetector(onTap: () => Navigator.pop(ctx), child: const Icon(Icons.close)),
              ],
            ),
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
              final result = await ApiService.post(
                'dosen',
                {
                  'nip': nipCtrl.text,
                  'nama_lengkap': namaCtrl.text,
                },
              );

              if (result['success'] == true) {

                await _loadDosen();

                Navigator.pop(ctx);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Dosen berhasil ditambahkan'),
                  ),
                );

              } else {

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result['message'] ?? 'Gagal menambah dosen',
                    ),
                  ),
                );

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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Edit Dosen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                GestureDetector(onTap: () => Navigator.pop(ctx), child: const Icon(Icons.close)),
              ],
            ),
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

              final result = await ApiService.put(
                'dosen/${item['id_dosen']}',
                {
                  'nama_lengkap': namaCtrl.text,
                },
              );

              if (result['success'] == true) {

                await _loadDosen();

                Navigator.pop(ctx);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data dosen berhasil diubah'),
                  ),
                );

              } else {

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result['message'] ?? 'Gagal mengubah data',
                    ),
                  ),
                );

              }

            },
            isEdit: true,
          ),
          ],
        ),
      ),
    );
  }

  void _showDetailAbsensiSheet(Map<String, dynamic> item) {
    // Membuat salinan data detail agar perubahan sementara tidak merusak state utama sebelum disimpan
    final List<Map<String, dynamic>> detailAbsensi = List<Map<String, dynamic>>.from(
      (item['detail'] as List).map((e) => Map<String, dynamic>.from(e)),
    );

    // List controller untuk menyimpan input data Alpha, Izin, Sakit per baris matkul
    List<TextEditingController> alphaControllers = [];
    List<TextEditingController> izinControllers = [];
    List<TextEditingController> sakitControllers = [];

    for (var row in detailAbsensi) {
      alphaControllers.add(TextEditingController(text: '${row['alpha']}'));
      izinControllers.add(TextEditingController(text: '${row['izin']}'));
      sakitControllers.add(TextEditingController(text: '${row['sakit']}'));
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        bool isEdit = false;
        return StatefulBuilder(
          builder: (ctx2, setLocal) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: _primaryRed.withOpacity(0.15),
                          child: Text(
                            item['nama'].split(' ').take(2).map((e) => e[0]).join().toUpperCase(),
                            style: const TextStyle(color: _primaryRed, fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['nama'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                              Text('${item['nim']} · ${item['prodi']} · Semester 4', style: const TextStyle(fontSize: 11, color: _textGrey)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.06), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.close, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('DETAIL ABSENSI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(color: _primaryRed, borderRadius: BorderRadius.circular(8)),
                          child: const Row(
                            children: [
                              Expanded(flex: 3, child: Text('Matkul · Tanggal', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))),
                              Expanded(child: Text('A', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
                              Expanded(child: Text('I', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
                              Expanded(child: Text('S', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
                              Expanded(child: Text('Edit', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
                            ],
                          ),
                        ),
                        ...List.generate(detailAbsensi.length, (index) {
                          final row = detailAbsensi[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.06)))),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Matkul di-lock berupa text sesuai permintaan kamu
                                      Text(row['matkul'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                      Text(row['tanggal'] ?? '', style: const TextStyle(fontSize: 10, color: _textGrey)),
                                    ],
                                  ),
                                ),
                                // Input Alpha
                                Expanded(
                                  child: isEdit
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: TextField(
                                            controller: alphaControllers[index],
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.red),
                                            decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 4)),
                                          ),
                                        )
                                      : Text('${row['alpha']}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.red)),
                                ),
                                // Input Izin
                                Expanded(
                                  child: isEdit
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: TextField(
                                            controller: izinControllers[index],
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.blue),
                                            decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 4)),
                                          ),
                                        )
                                      : Text('${row['izin']}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.blue)),
                                ),
                                // Input Sakit
                                Expanded(
                                  child: isEdit
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: TextField(
                                            controller: sakitControllers[index],
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.orange),
                                            decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 4)),
                                          ),
                                        )
                                      : Text('${row['sakit']}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.orange)),
                                ),
                                Expanded(
                                  child: Center(
                                    child: GestureDetector(
                                      onTap: () => setLocal(() => isEdit = true),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(color: _primaryRed.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                        child: const Icon(Icons.edit_outlined, size: 14, color: _primaryRed),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 12),
                        const Row(
                          children: [
                            Text('A = Alpha  ', style: TextStyle(fontSize: 11, color: _textGrey)),
                            Text('I = Izin  ', style: TextStyle(fontSize: 11, color: _textGrey)),
                            Text('S = Sakit', style: TextStyle(fontSize: 11, color: _textGrey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Simpan hasil edit ke state data utama absensi
                              setState(() {
                                for (int i = 0; i < item['detail'].length; i++) {
                                  item['detail'][i]['alpha'] = int.tryParse(alphaControllers[i].text) ?? 0;
                                  item['detail'][i]['izin'] = int.tryParse(izinControllers[i].text) ?? 0;
                                  item['detail'][i]['sakit'] = int.tryParse(sakitControllers[i].text) ?? 0;
                                }
                              });
                              Navigator.pop(ctx);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryRed,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Simpan Perubahan', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showHapusDialog(Map<String, dynamic> item) { 
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Menghapus Data', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Yakin menghapus data ini?', textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              foregroundColor: _primaryRed,
              side: const BorderSide(color: _primaryRed),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () async {

            final result = await ApiService.delete(
              'dosen/${item['id_dosen']}',
            );

            if (result['success'] == true) {

              await _loadDosen();

              Navigator.pop(ctx);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dosen berhasil dihapus'),
                ),
              );

            } else {

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    result['message'] ?? 'Gagal menghapus dosen',
                  ),
                ),
              );

            }
          },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            child: const Text('Ya', style: TextStyle(color: Colors.white)),
          ),
        ],
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
              const Text('Ganti Kaprodi', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
              const SizedBox(height: 18),
              const Text('Kaprodi hanya boleh satu dosen.\nYakin ingin mengganti Kaprodi?', textAlign: TextAlign.center, style: TextStyle(fontSize: 15)),
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Tidak'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                      final success = await _dosenService.setKaprodi(
                        dosen['id_dosen'],
                      );

                      Navigator.pop(ctx);

                      if (success) {
                        await _loadDosen();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Kaprodi berhasil diperbarui'),
                          ),
                        );
                      }
                    },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryRed,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
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
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Management Kompen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _textDark)),
                        const SizedBox(height: 2),
                        const Text('Pengelolaan data', style: TextStyle(fontSize: 13, color: _textGrey)),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group, size: 56, color: _textGrey.withOpacity(0.4)),
          const SizedBox(height: 12),
          Text('Pilih tab terlebih dahulu', style: TextStyle(fontSize: 14, color: _textGrey)),
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
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isActive ? Colors.white : _textDark)),
        ),
      ),
    );
  }

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
                  onChanged: (val) => setState(() => _searchMhs = val),
                ),
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
              Expanded(child: _buildDropdown(_prodiList, _selectedProdi, (val) => setState(() => _selectedProdi = val!))),
              const SizedBox(width: 8),
              Expanded(child: _buildDropdown(_angkatanList, _selectedAngkatan, (val) => setState(() => _selectedAngkatan = val!))),
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
          child: _filteredMahasiswa.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.manage_accounts, size: 48, color: _textGrey.withOpacity(0.4)),
                      const SizedBox(height: 8),
                      Text('Belum ada data sesuai filter', style: TextStyle(color: _textGrey)),
                    ],
                  ),
                )
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['nama'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _textDark)),
                Text('NIM: ${item['nim']} • ${item['prodi']}', style: const TextStyle(fontSize: 12, color: _textGrey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: terdaftar ? Colors.green.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              terdaftar ? 'Terdaftar' : 'Belum Terdaftar',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: terdaftar ? Colors.green[700] : Colors.grey[600]),
            ),
          ),
          const SizedBox(width: 8),
          _buildActionBtn(Icons.edit_outlined, _primaryRed, () => _showEditMahasiswaSheet(item)),
          const SizedBox(width: 6),
          _buildActionBtn(
            Icons.delete_outline,
            Colors.red,
            () => _showHapusDialog(item),
          ),
        ],
      ),
    );
  }

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
                  onChanged: (val) => setState(() => _searchDosen = val),
                ),
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
          child: _filteredDosen.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.manage_accounts, size: 48, color: _textGrey.withOpacity(0.4)),
                      const SizedBox(height: 8),
                      Text('Belum ada data sesuai filter', style: TextStyle(color: _textGrey)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: _filteredDosen.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _buildDosenCard(_filteredDosen[i], i),
                ),
        ),
      ],
    );
  }

  Widget _buildDosenCard(Map<String, dynamic> item, int index) {
    final bool terdaftar = item['status'] as bool;
    final bool isKaprodi = item['is_kaprodi'] as bool;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['nama'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _textDark)),
                    Text('NIP: ${item['nip']}', style: const TextStyle(fontSize: 12, color: _textGrey)),
                  ],
                ),
              ),
              _buildActionBtn(Icons.edit_outlined, _primaryRed, () => _showEditDosenSheet(item)),
              const SizedBox(width: 6),
             _buildActionBtn(
              Icons.delete_outline,
              Colors.red,
              () => _showHapusDialog(item),
            ),
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
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  terdaftar ? 'Terdaftar' : 'Belum Terdaftar',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: terdaftar ? Colors.green[700] : Colors.grey[600]),
                ),
              ),
              Row(
                children: [
                  Text('Kaprodi', style: TextStyle(fontSize: 12, fontWeight: isKaprodi ? FontWeight.w700 : FontWeight.w400, color: isKaprodi ? _primaryRed : _textGrey)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () { if (!isKaprodi) _showKaprodiDialog(item); },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48, height: 28,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: isKaprodi ? _primaryRed.withOpacity(0.3) : Colors.grey.withOpacity(0.25),
                        border: Border.all(color: isKaprodi ? _primaryRed.withOpacity(0.4) : Colors.grey.withOpacity(0.4)),
                      ),
                      child: Align(
                        alignment: isKaprodi ? Alignment.centerRight : Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Container(
                            width: 22, height: 22,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: isKaprodi ? _primaryRed : Colors.grey[500]),
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
                  onChanged: (val) => setState(() => _searchAbsensi = val),
                ),
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
              Expanded(child: _buildDropdown(_prodiList, _selectedProdi, (val) => setState(() => _selectedProdi = val!))),
              const SizedBox(width: 8),
              Expanded(child: _buildDropdown(_angkatanList, _selectedAngkatan, (val) => setState(() => _selectedAngkatan = val!))),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _showTambahAbsensiSheet,
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
          child: _filteredAbsensi.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.manage_accounts, size: 48, color: _textGrey.withOpacity(0.4)),
                      const SizedBox(height: 8),
                      Text('Belum ada data sesuai filter', style: TextStyle(color: _textGrey)),
                    ],
                  ),
                )
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
    final List<Map<String, dynamic>> detail = item['detail'];
    final int totalAlpha = detail.fold(0, (sum, e) => sum + (e['alpha'] as int));
    final int totalIzin = detail.fold(0, (sum, e) => sum + (e['izin'] as int));
    final int totalSakit = detail.fold(0, (sum, e) => sum + (e['sakit'] as int));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['nama'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _textDark)),
                Text('NIM: ${item['nim']} • ${item['prodi']}', style: const TextStyle(fontSize: 12, color: _textGrey)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildAbsensiChip('A', totalAlpha, Colors.red),
                    const SizedBox(width: 12),
                    _buildAbsensiChip('I', totalIzin, Colors.blue),
                    const SizedBox(width: 12),
                    _buildAbsensiChip('S', totalSakit, Colors.orange),
                  ],
                ),
              ],
            ),
          ),
          _buildActionBtn(Icons.search, _primaryRed, () => _showDetailAbsensiSheet(item)),
          const SizedBox(width: 6),
         _buildActionBtn(
          Icons.delete_outline,
          Colors.red,
          () => _showHapusDialog(item),
        ),
        ],
      ),
    );
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black12)),
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
  }

  Widget _buildActionBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  Widget _buildAbsensiChip(String label, int value, Color color) {
    return Text('$label = $value', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color));
  }

  Widget _buildDropdown(List<String> items, String value, void Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black12)),
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
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, [TextInputType type = TextInputType.text]) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Colors.black38),
        filled: true,
        fillColor: const Color(0xFFF5EFE6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildReadOnlyField(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey[300]!)),
      child: Row(
        children: [
          Expanded(child: Text(value, style: TextStyle(fontSize: 13, color: Colors.grey[600]))),
          Icon(Icons.lock_outline, size: 16, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildAbsensiInput(TextEditingController ctrl, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: _textGrey)),
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w700, color: color),
          decoration: InputDecoration(
            filled: true,
            fillColor: color.withOpacity(0.06),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: color.withOpacity(0.3))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: color.withOpacity(0.3))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: color)),
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(color: _primaryRed, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildSheetButtons(VoidCallback onBatal, VoidCallback onSimpan, {bool isEdit = false}) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onBatal,
            style: OutlinedButton.styleFrom(
              foregroundColor: _primaryRed,
              side: const BorderSide(color: _primaryRed),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(isEdit ? 'Simpan Perubahan' : 'Simpan', style: const TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}