import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_mahasiswa_provider.dart';
import '../../../models/mahasiswa.dart';

class EditMahasiswaView extends StatefulWidget {
  final Mahasiswa mahasiswa;

  const EditMahasiswaView({super.key, required this.mahasiswa});

  @override
  State<EditMahasiswaView> createState() => _EditMahasiswaViewState();
}

class _EditMahasiswaViewState extends State<EditMahasiswaView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaController;
  final Color _primaryRed = const Color(0xFFB71C1C);

  final List<String> _prodiList = [
    'D-IV Sistem Informasi Bisnis',
    'D-IV Teknik Informatika',
    'D-II Piranti Perangkat Lunak',
  ];
  late String? _selectedProdi;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.mahasiswa.nama);
    // Cek apakah prodi mahasiswa ada di list, kalau tidak set null
    _selectedProdi = _prodiList.contains(widget.mahasiswa.programStudi)
        ? widget.mahasiswa.programStudi
        : null;
  }

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: _primaryRed,
        foregroundColor: Colors.white,
        title: const Text(
          'Edit Mahasiswa',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: Consumer<AdminMahasiswaProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // NIM (read-only)
                  _buildLabel('NIM'),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.mahasiswa.nim,
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                          ),
                        ),
                        Icon(Icons.lock_outline, size: 16, color: Colors.grey.shade400),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'NIM tidak dapat diubah',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Field Nama
                  _buildLabel('Nama Lengkap'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _namaController,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Nama tidak boleh kosong';
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Masukkan nama lengkap',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _primaryRed),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dropdown Program Studi
                  _buildLabel('Program Studi'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedProdi,
                        isExpanded: true,
                        hint: Text(
                          'Pilih program studi',
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        ),
                        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
                        items: _prodiList
                            .map((prodi) => DropdownMenuItem(
                                  value: prodi,
                                  child: Text(prodi, style: const TextStyle(fontSize: 14)),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedProdi = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Tombol Simpan
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: provider.isLoading ? null : () => _simpan(provider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryRed,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: provider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Simpan Perubahan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Future<void> _simpan(AdminMahasiswaProvider provider) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProdi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih program studi terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await provider.edit(
      widget.mahasiswa.idMahasiswa,
      _namaController.text.trim(),
      _selectedProdi!,
    );

    if (success && mounted) {
      Navigator.pop(context);
    } else if (mounted && provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage!), backgroundColor: Colors.red),
      );
      provider.clearMessages();
    }
  }
}
