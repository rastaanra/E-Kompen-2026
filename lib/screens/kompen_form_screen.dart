import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';

class KompenFormScreen extends StatefulWidget {
  const KompenFormScreen({super.key});

  @override
  State<KompenFormScreen> createState() => _KompenFormScreenState();
}

class _KompenFormScreenState extends State<KompenFormScreen> {
  String _selectedMatkul = 'Basis Data';
  DateTime _selectedDate = DateTime(2024, 4, 22);
  String _selectedJenis = 'kelas';
  final TextEditingController _alasanController = TextEditingController(
    text: 'Sakit demam dan sudah mengunjungi dokter.',
  );

  final List<String> _matkulList = [
    'Basis Data',
    'Kalkulus',
    'Jaringan Komputer II',
    'Pemrograman Mobile',
  ];

  @override
  void dispose() {
    _alasanController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2025),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppTheme.primaryRed),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    const days = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(
        title: const Text('Form Pengajuan'),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Isi Form Pengajuan Kompen',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Isi form di bawah ini untuk mengajukan\nizin kompensasi ketidakhadiran.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppTheme.textGrey,
              ),
            ),
            const SizedBox(height: 24),

            // Informasi Kompen
            _buildSectionLabel('Informasi Kompen'),
            const SizedBox(height: 8),
            _buildDropdownField(),
            const SizedBox(height: 16),

            // Tanggal Tidak Hadir
            _buildSectionLabel('Tanggal Tidak Hadir'),
            const SizedBox(height: 8),
            _buildDateField(),
            const SizedBox(height: 16),

            // Jenis Pengajuan
            _buildSectionLabel('Pengajuan kompen untuk'),
            const SizedBox(height: 8),
            _buildRadioOption(
              label: 'Mengikuti kelas pengganti',
              value: 'kelas',
            ),
            const SizedBox(height: 4),
            _buildRadioOption(
              label: 'Mengikuti ujian susulan',
              value: 'ujian',
            ),
            const SizedBox(height: 16),

            // Alasan
            _buildSectionLabel('Alasan Kompen'),
            const SizedBox(height: 8),
            _buildTextArea(),
            const SizedBox(height: 32),

            // Submit Button
            PrimaryButton(
              label: 'Kirim Pengajuan',
              onPressed: _submitForm,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: AppTheme.textDark,
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedMatkul,
          isExpanded: true,
          icon: const Icon(Icons.chevron_right, color: AppTheme.textGrey),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: AppTheme.textDark,
          ),
          items: _matkulList
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedMatkul = val);
          },
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDate(_selectedDate),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppTheme.textDark,
              ),
            ),
            const Icon(Icons.calendar_today_outlined,
                size: 18, color: AppTheme.textGrey),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption({required String label, required String value}) {
    final bool isSelected = _selectedJenis == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedJenis = value),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppTheme.primaryRed : AppTheme.textGrey,
                width: 2,
              ),
              color: isSelected ? AppTheme.primaryRed : Colors.transparent,
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: isSelected ? AppTheme.textDark : AppTheme.textGrey,
              fontWeight:
                  isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextArea() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _alasanController,
        maxLines: 5,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: AppTheme.textDark,
        ),
        decoration: InputDecoration(
          hintText: 'Tuliskan alasan tidak hadir...',
          hintStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: AppTheme.textGrey,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  void _submitForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Pengajuan Dikirim!',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryRed,
          ),
        ),
        content: const Text(
          'Pengajuan kompen kamu berhasil dikirim. Tunggu konfirmasi dari dosen.',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'OK',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: AppTheme.primaryRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}