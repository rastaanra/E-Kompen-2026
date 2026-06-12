import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';

class BantuanFaqScreen extends StatefulWidget {
  const BantuanFaqScreen({super.key});

  @override
  State<BantuanFaqScreen> createState() => _BantuanFaqScreenState();
}

class _BantuanFaqScreenState extends State<BantuanFaqScreen> {
  static const Color _primaryRed = Color(0xFFB71C1C);
  static const Color _backgroundCream = Color(0xFFF5EFE6);
  static const Color _textDark = Color(0xFF2D2D2D);
  static const Color _textGrey = Color(0xFF9E9E9E);

  int _activeSection = 0; // 0 = Panduan, 1 = FAQ

  // ─── DATA PANDUAN ───────────────────────────────────────────────────────────
  final List<_GuideItem> _panduan = [
    _GuideItem(
      icon: Icons.assignment_outlined,
      title: 'Mengajukan Kompensasi (Kompen)',
      steps: [
        'Buka menu Pengajuan dari halaman utama.',
        'Tekan tombol "+" atau "Ajukan Kompen" untuk membuat pengajuan baru.',
        'Pilih jenis tugas kompensasi yang tersedia dari daftar.',
        'Isi detail pengajuan: tanggal, deskripsi, dan lampirkan bukti jika diperlukan.',
        'Tekan "Kirim" dan tunggu konfirmasi dari dosen atau admin.',
        'Status pengajuan bisa dipantau di halaman Pengajuan.',
      ],
    ),
    _GuideItem(
      icon: Icons.track_changes_outlined,
      title: 'Memantau Status Pengajuan',
      steps: [
        'Buka menu Pengajuan dari bottom navigation.',
        'Lihat daftar pengajuan yang sudah kamu buat.',
        'Status "Menunggu" berarti pengajuan masih diproses.',
        'Status "Disetujui" berarti pengajuan berhasil dikonfirmasi.',
        'Status "Ditolak" berarti pengajuan tidak memenuhi syarat — kamu bisa melihat alasannya.',
        'Tekan pengajuan untuk melihat detail lengkap dan catatan dari admin.',
      ],
    ),
    _GuideItem(
      icon: Icons.how_to_reg_outlined,
      title: 'Absensi & Riwayat Kehadiran',
      steps: [
        'Buka menu Verifikasi atau Home untuk melihat riwayat absensi.',
        'Cari tanggal atau mata kuliah yang ingin dilihat.',
        'Status kehadiran ditampilkan dengan kode: H (Hadir), A (Alpha), I (Izin), S (Sakit).',
        'Alpha (A) adalah yang memerlukan kompensasi — pastikan segera diajukan.',
        'Jika ada kesalahan data absensi, hubungi admin atau dosen yang bersangkutan.',
      ],
    ),
    _GuideItem(
      icon: Icons.edit_outlined,
      title: 'Mengubah Data Profil',
      steps: [
        'Buka menu Profil dari bottom navigation.',
        'Tekan ikon edit (pensil) di pojok kanan kartu profil.',
        'Ubah nama lengkap sesuai kebutuhan.',
        'NIM, program studi, dan email tidak dapat diubah sendiri — hubungi admin.',
        'Tekan "Simpan Perubahan" untuk menyimpan.',
      ],
    ),
    _GuideItem(
      icon: Icons.photo_camera_outlined,
      title: 'Mengganti Foto Profil',
      steps: [
        'Buka menu Profil, lalu tekan ikon kamera di foto profil.',
        'Pilih "Ambil Foto dari Kamera" atau "Pilih dari Galeri".',
        'Pastikan foto yang dipilih jelas dan sesuai.',
        'Sistem akan mengupload foto secara otomatis.',
        'Foto baru akan langsung tampil di profil setelah berhasil diupload.',
      ],
    ),
  ];

  // ─── DATA FAQ ───────────────────────────────────────────────────────────────
  final List<_FaqItem> _faq = [
    _FaqItem(
      question: 'Berapa batas alpha yang bisa dikompensasi?',
      answer:
          'Batas alpha yang dapat dikompensasi sesuai dengan kebijakan program studi masing-masing. '
          'Silakan konfirmasi ke dosen wali atau admin untuk informasi batas toleransi alpha di prodimu.',
    ),
    _FaqItem(
      question: 'Berapa lama pengajuan kompen diproses?',
      answer:
          'Pengajuan kompensasi biasanya diproses dalam 1–3 hari kerja oleh admin atau dosen. '
          'Jika lebih dari itu belum ada respons, kamu bisa menghubungi admin secara langsung.',
    ),
    _FaqItem(
      question: 'Apa yang harus dilakukan jika pengajuan ditolak?',
      answer:
          'Buka detail pengajuan yang ditolak untuk melihat alasan penolakannya. '
          'Perbaiki sesuai catatan dari admin, lalu buat pengajuan baru dengan data yang sudah diperbaiki.',
    ),
    _FaqItem(
      question: 'Apakah data absensi bisa diubah sendiri oleh mahasiswa?',
      answer:
          'Tidak. Data absensi hanya bisa diubah oleh admin atau dosen yang bersangkutan. '
          'Jika ada kesalahan, segera laporkan ke admin dengan bukti kehadiran yang valid.',
    ),
    _FaqItem(
      question: 'Apa yang harus dilakukan jika lupa password?',
      answer:
          'Kamu bisa menggunakan fitur "Ubah Password" di halaman Profil dengan memasukkan password lama. '
          'Jika benar-benar lupa, hubungi admin untuk melakukan reset password secara manual.',
    ),
    _FaqItem(
      question: 'Apakah pengajuan kompen bisa dibatalkan?',
      answer:
          'Pengajuan yang masih berstatus "Menunggu" bisa dibatalkan dari halaman detail pengajuan. '
          'Pengajuan yang sudah disetujui tidak bisa dibatalkan — hubungi admin jika ada kekeliruan.',
    ),
  ];

  final List<int> _expandedFaq = [];

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
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back_ios,
                              color: _primaryRed, size: 20),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Bantuan & FAQ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tab Panduan / FAQ
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          _buildTab(0, 'Panduan Penggunaan', Icons.menu_book_outlined),
                          _buildTab(1, 'FAQ', Icons.help_outline),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Konten
                  Expanded(
                    child: _activeSection == 0 ? _buildPanduan() : _buildFaq(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label, IconData icon) {
    final isActive = _activeSection == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeSection = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? _primaryRed : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: isActive ? Colors.white : _textGrey),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive ? Colors.white : _textGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPanduan() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      itemCount: _panduan.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final item = _panduan[i];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primaryRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: _primaryRed, size: 20),
              ),
              title: Text(
                item.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
              iconColor: _primaryRed,
              collapsedIconColor: _textGrey,
              children: [
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    children: List.generate(item.steps.length, (si) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: _primaryRed,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${si + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item.steps[si],
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: _textDark,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFaq() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      itemCount: _faq.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final item = _faq[i];
        final isExpanded = _expandedFaq.contains(i);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedFaq.remove(i);
              } else {
                _expandedFaq.add(i);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                ),
              ],
              border: isExpanded
                  ? Border.all(color: _primaryRed.withOpacity(0.3))
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _primaryRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Q',
                        style: TextStyle(
                          color: _primaryRed,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.question,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _textDark,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: _textGrey,
                      size: 20,
                    ),
                  ],
                ),
                if (isExpanded) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'A',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.answer,
                          style: const TextStyle(
                            fontSize: 13,
                            color: _textDark,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Model lokal ──────────────────────────────────────────────────────────────

class _GuideItem {
  final IconData icon;
  final String title;
  final List<String> steps;
  const _GuideItem({
    required this.icon,
    required this.title,
    required this.steps,
  });
}

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});
}