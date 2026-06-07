import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';

const _red = Color(0xFFB71C1C);
const _cream = Color(0xFFF5EFE6);
const _dark = Color(0xFF2D2D2D);
const _grey = Color(0xFF9E9E9E);

// ── Enum varian halaman
enum DetailVerifikasiMode { verifikasi, pengajuan }

// ────────────────────────────────────────────────────────────
class KaprodiDetailVerifikasiScreen extends StatefulWidget {
  const KaprodiDetailVerifikasiScreen({
    super.key,
    required this.mode,
    required this.namaPengajar,
    required this.nip,
    required this.namaMahasiswa,
    required this.nim,
    required this.semester,
    required this.mataKuliah,
    required this.pekerjaan,
    required this.jumlahJam,
    required this.tanggal,
    required this.status,
    this.kelas,
    this.keterangan,
    this.onStatusChanged,
  });

  final DetailVerifikasiMode mode;
  final String namaPengajar;
  final String nip;
  final String namaMahasiswa;
  final String nim;
  final String semester;
  final String mataKuliah;
  final String pekerjaan;
  final String jumlahJam;
  final String tanggal;
  final String status;
  final String? kelas;
  final String? keterangan;

  /// Callback agar halaman sebelumnya bisa update state badge
  final void Function(String newStatus)? onStatusChanged;

  @override
  State<KaprodiDetailVerifikasiScreen> createState() =>
      _KaprodiDetailVerifikasiScreenState();
}

class _KaprodiDetailVerifikasiScreenState
    extends State<KaprodiDetailVerifikasiScreen> {
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.status;
  }

  bool get _sudahTTD => _status == 'sudah_ttd';

  void _tandatangani() {
    setState(() => _status = 'sudah_ttd');
    widget.onStatusChanged?.call('sudah_ttd');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Berhasil ditandatangani'),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String judul = widget.mode == DetailVerifikasiMode.verifikasi
        ? 'Verifikasi Kompen'
        : 'Pengajuan Kompen';

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
                children: [
                  // Judul
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        judul,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _dark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Isi form (scrollable)
                  Expanded(
                    child: ScrollConfiguration(
                      behavior: const ScrollBehavior()
                          .copyWith(overscroll: false),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        padding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: _buildFormCard(),
                      ),
                    ),
                  ),

                  // Tombol bawah
                  _buildBottomButtons(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildKopSurat(),
          const Divider(
              height: 1, thickness: 0.8, color: Color(0xFFE0E0E0)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormTitle('BERITA ACARA KOMPENSASI'),
                const SizedBox(height: 16),

                _buildRow('Nama Pengajar', widget.namaPengajar),
                _buildRow('NIP', widget.nip),
                const SizedBox(height: 8),
                const Text(
                  'Memberikan rekomendasi kompensasi kepada:',
                  style: TextStyle(fontSize: 12, color: _grey),
                ),
                const SizedBox(height: 8),

                _buildRow('Nama Mahasiswa', widget.namaMahasiswa),
                _buildRow('NIM', widget.nim),

                // Field khusus mode pengajuan
                if (widget.mode == DetailVerifikasiMode.pengajuan &&
                    widget.kelas != null)
                  _buildRow('Kelas', widget.kelas!),

                _buildRow('Semester', widget.semester),
                _buildRow('Mata Kuliah', widget.mataKuliah),
                _buildRow('Pekerjaan', widget.pekerjaan),
                _buildRow('Jumlah Jam', widget.jumlahJam),

                if (widget.mode == DetailVerifikasiMode.pengajuan &&
                    widget.keterangan != null)
                  _buildRow('Keterangan', widget.keterangan!),

                const SizedBox(height: 20),
                Text(
                  'Malang, ${widget.tanggal}',
                  style: const TextStyle(fontSize: 12, color: _dark),
                ),
                const SizedBox(height: 16),
                _buildSignatureRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKopSurat() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: _red,
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.school, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'POLITEKNIK NEGERI MALANG',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: _dark,
                      letterSpacing: 0.3),
                ),
                Text(
                  'JURUSAN TEKNOLOGI INFORMASI',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: _dark),
                ),
                Text(
                  'PROGRAM STUDI D-IV SISTEM INFORMASI BISNIS',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 8, color: _dark),
                ),
                SizedBox(height: 2),
                Text(
                  'Jl. Soekarno Hatta No.9 Malang 65141 · Telp. (0341) 404424',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 7.5, color: _grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormTitle(String title) {
    return Center(
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: _dark,
          letterSpacing: 0.5,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(fontSize: 12, color: _dark)),
          ),
          const Text(': ',
              style: TextStyle(fontSize: 12, color: _dark)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 12,
                  color: _dark,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSignatureColumn(
          title: 'Yang memberikan rekomendasi,',
          name: 'Budi Harjanta, S.T.,M.Kom',
          nip: 'NIP. 198305210085041003',
          showStamp: false,
        ),
        _buildSignatureColumn(
          title: 'Mengetahui, Ka. Program Studi',
          name: 'Hendra Pradibta, S.E., M.Sc.',
          nip: 'NIP. 198305210085041003',
          showStamp: _sudahTTD, // ← QR muncul setelah ditandatangani
        ),
      ],
    );
  }

  Widget _buildSignatureColumn({
    required String title,
    required String name,
    required String nip,
    required bool showStamp,
  }) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 9, color: _dark)),
          const SizedBox(height: 6),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(
                color: showStamp
                    ? Colors.transparent
                    : const Color(0xFFE0E0E0),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(6),
              color: showStamp
                  ? const Color(0xFFE8F5E9)
                  : Colors.transparent,
            ),
            child: showStamp
                ? const Icon(Icons.qr_code_2,
                    size: 50, color: Color(0xFF2E7D32))
                : null,
          ),
          const SizedBox(height: 6),
          Text(name,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _dark)),
          Text(nip,
              style: const TextStyle(fontSize: 8, color: _grey)),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      color: _cream,
      child: Row(
        children: [
          // Tutup
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _red),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Tutup',
                style: TextStyle(
                    color: _red,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Tandatangani
          Expanded(
            child: ElevatedButton(
              onPressed: _sudahTTD ? null : _tandatangani,
              style: ElevatedButton.styleFrom(
                backgroundColor: _sudahTTD ? Colors.grey.shade300 : _red,
                disabledBackgroundColor: Colors.grey.shade300,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                _sudahTTD ? 'Sudah Ditandatangani' : 'Tandatangani',
                style: TextStyle(
                  color: _sudahTTD ? Colors.grey.shade600 : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}