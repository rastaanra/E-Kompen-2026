import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../providers/admin_mahasiswa_provider.dart';
import '../../../models/mahasiswa.dart';
import 'tambah_mahasiswa_view.dart';
import 'edit_mahasiswa_view.dart';

class ListMahasiswaView extends StatefulWidget {
  const ListMahasiswaView({super.key});

  @override
  State<ListMahasiswaView> createState() => _ListMahasiswaViewState();
}

class _ListMahasiswaViewState extends State<ListMahasiswaView> {
  final TextEditingController _searchController = TextEditingController();
  final Color _primaryRed = const Color(0xFFB71C1C);
  final Color _lightRed = const Color(0xFFFFEBEE);

  final List<String> _prodiList = [
    'Semua Prodi',
    'D-IV Sistem Informasi Bisnis',
    'D-IV Teknik Informatika',
    'D-II Piranti Perangkat Lunak',
  ];

  final List<String> _angkatanList = [
    'Semua Angkatan',
    '24',
    '25',
    '23',
    '22',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminMahasiswaProvider>().getAll();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminMahasiswaProvider>(
      builder: (context, provider, _) {
        // Tampilkan snackbar jika ada pesan
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (provider.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(provider.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
            provider.clearMessages();
          }
          if (provider.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(provider.successMessage!),
                backgroundColor: Colors.green,
              ),
            );
            provider.clearMessages();
          }
        });

        return Column(
          children: [
            // Search bar + tombol upload
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => provider.cari(val),
                        decoration: InputDecoration(
                          hintText: 'Cari mahasiswa...',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Tombol Upload
                  GestureDetector(
                    onTap: () => _showImportBottomSheet(context, provider),
                    child: Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: _primaryRed,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.upload, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),

            // Dropdown filter prodi + angkatan
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  // Dropdown Prodi
                  Expanded(
                    child: _buildDropdown(
                      value: provider.filterProdi ?? 'Semua Prodi',
                      items: _prodiList,
                      onChanged: (val) => provider.setFilterProdi(
                        val == 'Semua Prodi' ? null : val,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Dropdown Angkatan
                  Expanded(
                    child: _buildDropdown(
                      value: provider.filterAngkatan ?? 'Semua Angkatan',
                      items: _angkatanList,
                      onChanged: (val) => provider.setFilterAngkatan(
                        val == 'Semua Angkatan' ? null : val,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Tombol Tambah
                  GestureDetector(
                    onTap: () => _navigateTambah(context),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: _primaryRed,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),

            // List mahasiswa
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFB71C1C)))
                  : provider.listMahasiswa.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          color: _primaryRed,
                          onRefresh: () => provider.getAll(),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                            itemCount: provider.listMahasiswa.length,
                            itemBuilder: (context, index) {
                              final mhs = provider.listMahasiswa[index];
                              return _buildMahasiswaCard(context, mhs, provider);
                            },
                          ),
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600, size: 18),
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildMahasiswaCard(
    BuildContext context,
    Mahasiswa mhs,
    AdminMahasiswaProvider provider,
  ) {
    // Ambil singkatan prodi
    final prodiSingkat = _singkatProdi(mhs.programStudi);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Info mahasiswa
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mhs.nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      mhs.nim,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                    Text(
                      ' • $prodiSingkat',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Badge terdaftar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: mhs.isRegistered
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    mhs.isRegistered ? 'Terdaftar' : 'Belum Terdaftar',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: mhs.isRegistered ? Colors.green.shade700 : Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tombol edit
          _buildIconButton(
            icon: Icons.edit,
            color: const Color(0xFFB71C1C),
            bgColor: const Color(0xFFFFEBEE),
            onTap: () => _navigateEdit(context, mhs),
          ),
          const SizedBox(width: 8),
          // Tombol hapus
          _buildIconButton(
            icon: Icons.delete_outline,
            color: const Color(0xFFB71C1C),
            bgColor: const Color(0xFFFFEBEE),
            onTap: () => _konfirmasiHapus(context, mhs, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'Belum ada data sesuai filter',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Bottom sheet import file
  void _showImportBottomSheet(BuildContext context, AdminMahasiswaProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Unggah File Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Pilih file Excel atau CSV untuk diimpor',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            // Area upload
            GestureDetector(
              onTap: () async {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['xlsx', 'xls', 'csv'],
                );
                if (result != null && result.files.first.path != null) {
                  Navigator.pop(context);
                  await provider.importFile(result.files.first.path!);
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFB71C1C),
                    style: BorderStyle.solid,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.upload_outlined, size: 40, color: const Color(0xFFB71C1C)),
                    const SizedBox(height: 10),
                    const Text(
                      'Ketuk untuk memilih file',
                      style: TextStyle(
                        color: Color(0xFFB71C1C),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Format: .xlsx, .csv, .xls\nMaks. 10 MB',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Batal', style: TextStyle(color: Colors.black54)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: null, // aktif setelah file dipilih
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB71C1C),
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Unggah Sekarang', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  // Dialog konfirmasi hapus
  void _konfirmasiHapus(
    BuildContext context,
    Mahasiswa mhs,
    AdminMahasiswaProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Mahasiswa'),
        content: Text('Yakin ingin menghapus data ${mhs.nama}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.hapus(mhs.idMahasiswa);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB71C1C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _navigateTambah(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TambahMahasiswaView()),
    ).then((_) => context.read<AdminMahasiswaProvider>().getAll());
  }

  void _navigateEdit(BuildContext context, Mahasiswa mhs) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditMahasiswaView(mahasiswa: mhs)),
    ).then((_) => context.read<AdminMahasiswaProvider>().getAll());
  }

  String _singkatProdi(String prodi) {
    if (prodi.contains('Sistem Informasi')) return 'SIB';
    if (prodi.contains('Teknik Informatika')) return 'TI';
    if (prodi.contains('Piranti')) return 'PPL';
    return prodi.length > 10 ? '${prodi.substring(0, 10)}...' : prodi;
  }
}
