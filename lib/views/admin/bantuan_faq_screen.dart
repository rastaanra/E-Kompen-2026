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

  // ─── DATA PANDUAN ──────────────────────────────────────────────────────────
  final List<_GuideItem> _panduan = [
    _GuideItem(
      icon: Icons.upload_file_outlined,
      title: 'Import Data Absensi Mahasiswa',
      steps: [
        'Siapkan file CSV absensi sesuai format yang ditentukan (NIM, Tanggal, Status).',
        'Buka menu Home atau Management, lalu pilih "Import Absensi".',
        'Tekan tombol pilih file dan pilih file CSV dari perangkat kamu.',
        'Sistem akan memvalidasi format file secara otomatis.',
        'Tekan "Upload" dan tunggu hingga muncul notifikasi berhasil.',
        'Data absensi akan langsung tersimpan dan bisa dilihat pada daftar mahasiswa.',
      ],
    ),
    _GuideItem(
      icon: Icons.manage_accounts_outlined,
      title: 'Mengubah Data AIS (Akademik Informasi Sistem)',
      steps: [
        'Buka menu Management dari halaman utama.',
        'Pilih tab "Mahasiswa" atau "Dosen" sesuai data yang ingin diubah.',
        'Cari nama atau NIM/NIP menggunakan kolom pencarian.',
        'Ketuk nama yang ingin diubah, lalu pilih ikon edit (pensil).',
        'Ubah data yang diperlukan, lalu tekan "Simpan".',
        'Sistem akan memperbarui data AIS secara langsung.',
      ],
    ),
    _GuideItem(
      icon: Icons.verified_user_outlined,
      title: 'Verifikasi Pengajuan Kompensasi',
      steps: [
        'Buka menu Pengajuan dari bottom navigation.',
        'Lihat daftar pengajuan yang masuk dari mahasiswa.',
        'Ketuk pengajuan untuk melihat detail tugas kompensasi.',
        'Periksa kelengkapan dokumen dan bukti pengajuan.',
        'Tekan "Konfirmasi" jika pengajuan sesuai, atau "Tolak" jika tidak memenuhi syarat.',
        'Status pengajuan akan diperbarui dan mahasiswa menerima notifikasi.',
      ],
    ),
    _GuideItem(
      icon: Icons.edit_document,
      title: 'Tanda Tangan Digital (TTD)',
      steps: [
        'Setelah mengkonfirmasi pengajuan, buka detail pengajuan tersebut.',
        'Gulir ke bawah hingga bagian "Tanda Tangan".',
        'Tekan tombol "Tandatangani" untuk memberikan TTD digital.',
        'Sistem akan menyimpan TTD beserta timestamp secara otomatis.',
        'Dokumen siap diunduh oleh mahasiswa setelah semua pihak menandatangani.',
      ],
    ),
    _GuideItem(
      icon: Icons.people_alt_outlined,
      title: 'Mengatur Role Kaprodi',
      steps: [
        'Buka menu Management, lalu pilih tab "Dosen".',
        'Cari dosen yang akan dijadikan Kaprodi.',
        'Ketuk nama dosen, lalu aktifkan toggle "Jadikan Kaprodi".',
        'Konfirmasi perubahan pada dialog yang muncul.',
        'Dosen tersebut akan mendapatkan akses menu Kaprodi secara otomatis.',
      ],
    ),
  ];

  // ─── DATA FAQ ──────────────────────────────────────────────────────────────
  final List<_FaqItem> _faq = [
    _FaqItem(
      question: 'Format CSV absensi seperti apa yang diterima sistem?',
      answer:
          'File CSV harus memiliki kolom: NIM, Nama, Tanggal (YYYY-MM-DD), dan Status (H/A/S/I). '
          'Pastikan tidak ada baris header ganda dan gunakan encoding UTF-8.',
    ),
    _FaqItem(
      question: 'Apakah data AIS yang sudah diubah bisa dikembalikan?',
      answer:
          'Perubahan data AIS bersifat permanen. Pastikan data yang dimasukkan sudah benar '
          'sebelum menekan tombol Simpan. Hubungi superadmin jika terjadi kesalahan kritis.',
    ),
    _FaqItem(
      question: 'Mengapa pengajuan tidak muncul di daftar saya?',
      answer:
          'Pengajuan hanya muncul jika sudah diajukan oleh mahasiswa dan ditugaskan ke admin. '
          'Coba refresh halaman atau periksa koneksi internet kamu.',
    ),
    _FaqItem(
      question: 'Berapa batas ukuran file CSV yang bisa diupload?',
      answer:
          'Ukuran maksimal file CSV yang dapat diupload adalah 5 MB. '
          'Jika data terlalu besar, pecah menjadi beberapa file per kelas atau per periode.',
    ),
    _FaqItem(
      question: 'Apa yang terjadi jika saya lupa password?',
      answer:
          'Gunakan fitur "Ubah Password" di halaman Profil. Kamu perlu memasukkan password lama terlebih dahulu. '
          'Jika benar-benar lupa, hubungi superadmin untuk reset manual.',
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
                          _buildTab(0, 'Panduan Penggunaan',
                              Icons.menu_book_outlined),
                          _buildTab(1, 'FAQ', Icons.help_outline),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Konten
                  Expanded(
                    child: _activeSection == 0
                        ? _buildPanduan()
                        : _buildFaq(),
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
                  fontWeight:
                      isActive ? FontWeight.w700 : FontWeight.w400,
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
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 4),
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
                              decoration: BoxDecoration(
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