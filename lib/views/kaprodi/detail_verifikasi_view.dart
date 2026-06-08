import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/dosen_provider.dart';

// Model lokal untuk data yang ditampilkan di detail
// Nanti diganti dengan data dari API kalau endpoint sudah tersedia
class DetailVerifikasiData {
  final int idPengajuan;
  final String namaMahasiswa;
  final String nim;
  final String kelas;
  final String semester;
  final String mataKuliah;
  final String pekerjaan;
  final int jumlahJam;
  final String keterangan;
  final String tanggal;
  final String namaDosen;
  final String nipDosen;
  final String namaKaprodi;
  final String nipKaprodi;
  final bool sudahTtdDosen;
  final bool sudahTtdKaprodi;

  const DetailVerifikasiData({
    required this.idPengajuan,
    required this.namaMahasiswa,
    required this.nim,
    required this.kelas,
    required this.semester,
    required this.mataKuliah,
    required this.pekerjaan,
    required this.jumlahJam,
    required this.keterangan,
    required this.tanggal,
    required this.namaDosen,
    required this.nipDosen,
    required this.namaKaprodi,
    required this.nipKaprodi,
    required this.sudahTtdDosen,
    required this.sudahTtdKaprodi,
  });
}

class DetailVerifikasiView extends StatefulWidget {
  final DetailVerifikasiData data;

  const DetailVerifikasiView({super.key, required this.data});

  @override
  State<DetailVerifikasiView> createState() => _DetailVerifikasiViewState();
}

class _DetailVerifikasiViewState extends State<DetailVerifikasiView> {
  late bool _sudahTtdKaprodi;
  bool _isLoading = false;

  static const Color _primaryRed = Color(0xFFB71C1C);
  static const Color _cream = Color(0xFFF5EFE6);

  @override
  void initState() {
    super.initState();
    _sudahTtdKaprodi = widget.data.sudahTtdKaprodi;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildBeritaAcara(),
              ),
            ),
            _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBeritaAcara() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header institusi
          _buildHeader(),
          const Divider(thickness: 2, color: Colors.black, height: 0),
          const SizedBox(height: 2),
          const Divider(thickness: 0.5, color: Colors.black, height: 0),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul
                const Center(
                  child: Text(
                    'BERITA ACARA KOMPENSASI',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Info dosen pengajar
                _buildRow('Nama Pengajar', widget.data.namaDosen),
                _buildRow('NIP', widget.data.nipDosen),
                const SizedBox(height: 12),
                const Text(
                  'Memberikan rekomendasi kompensasi kepada:',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 12),

                // Info mahasiswa
                _buildRow('Nama Mahasiswa', widget.data.namaMahasiswa),
                _buildRow('NIM', widget.data.nim),
                _buildRow('Kelas', widget.data.kelas),
                _buildRow('Semester', widget.data.semester),
                _buildRow('Mata Kuliah', widget.data.mataKuliah),
                _buildRow('Pekerjaan', widget.data.pekerjaan),
                _buildRow('Jumlah Jam', _jamTerbilang(widget.data.jumlahJam)),
                _buildRow('Keterangan', widget.data.keterangan),
                const SizedBox(height: 20),

                // Tanggal
                Text(
                  'Malang, ${widget.data.tanggal}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 16),

                // TTD section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildTtdDosen()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTtdKaprodi()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: _primaryRed,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.school, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'POLITEKNIK NEGERI MALANG',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                ),
                Text(
                  'JURUSAN TEKNOLOGI INFORMASI',
                  style: TextStyle(fontSize: 9),
                ),
                Text(
                  'PROGRAM STUDI D-IV SISTEM INFORMASI BISNIS',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9),
                ),
                Text(
                  'Jl. Soekarno Hatta No.9 Malang 65141 · Telp. (0341) 404424',
                  style: TextStyle(fontSize: 8, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontSize: 11)),
          ),
          const Text(': ', style: TextStyle(fontSize: 11)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTtdDosen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Yang memberikan rekomendasi,',
          style: TextStyle(fontSize: 10),
        ),
        const SizedBox(height: 8),
        // QR dosen (selalu sudah TTD karena kaprodi TTD terakhir)
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(Icons.qr_code_2, size: 50, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Text(
          widget.data.namaDosen,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
        Text(
          'NIP. ${widget.data.nipDosen}',
          style: const TextStyle(fontSize: 9, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildTtdKaprodi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mengetahui, Ka. Program Studi',
          style: TextStyle(fontSize: 10),
        ),
        const SizedBox(height: 8),
        // QR kaprodi — tampil kalau sudah TTD, placeholder kalau belum
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
            color: _sudahTtdKaprodi ? null : Colors.grey.shade100,
          ),
          child: _sudahTtdKaprodi
              ? const Icon(Icons.qr_code_2, size: 50, color: Colors.black87)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_2, size: 30, color: Colors.grey.shade400),
                    Text(
                      'Belum\nditandatangani',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 7, color: Colors.grey.shade400),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.data.namaKaprodi,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
        Text(
          'NIP. ${widget.data.nipKaprodi}',
          style: const TextStyle(fontSize: 9, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Tutup',
                style: TextStyle(color: Colors.black54, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _sudahTtdKaprodi || _isLoading
                  ? null
                  : () => _konfirmasiTtd(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32), // hijau
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Tandatangani',
                      style: TextStyle(
                        color: _sudahTtdKaprodi
                            ? Colors.grey.shade500
                            : Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Dialog konfirmasi sebelum TTD
  void _konfirmasiTtd(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Tanda Tangan'),
        content: Text(
          'Yakin menandatangani berita acara kompensasi ${widget.data.namaMahasiswa}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _lakukanTtd(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Ya, Tandatangani',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _lakukanTtd(BuildContext context) async {
    setState(() => _isLoading = true);

    final provider = context.read<DosenProvider>();
    final success = await provider.melakukanTTD(widget.data.idPengajuan);

    setState(() => _isLoading = false);

    if (success) {
      setState(() => _sudahTtdKaprodi = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil ditandatangani!'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menandatangani, coba lagi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _jamTerbilang(int jam) {
    const terbilang = [
      '', 'Satu', 'Dua', 'Tiga', 'Empat', 'Lima',
      'Enam', 'Tujuh', 'Delapan', 'Sembilan', 'Sepuluh'
    ];
    if (jam <= 10) return '$jam (${terbilang[jam]}) Jam';
    return '$jam Jam';
  }
}
