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

  // ─── DATA PANDUAN DOSEN ──────────────────────────────────────────────────────
  final List<_GuideItem> _panduan = [
    _GuideItem(
      icon: Icons.check_circle_outline,
      title: 'Verifikasi Pengajuan Kompen',
      steps: [
        'Buka menu Verifikasi dari navigasi bawah.',
        'Lihat daftar mahasiswa yang mengajukan form penyelesaian kompen.',
        'Klik pada detail pengajuan untuk melihat bukti dan deskripsi pekerjaan.',
        'Tekan tombol \"Setujui\" atau \"Tolak\" sesuai hasil validasi pekerjaan.',
        'Setelah disetujui, status akan berubah menjadi \"Sudah TTD Dosen\".',
      ],
    ),
    _GuideItem(
      icon: Icons.history_edu_outlined,
      title: 'Melihat Riwayat Pengajuan',
      steps: [
        'Masuk ke menu Pengajuan.',
        'Gunakan filter semester atau status untuk mencari data spesifik.',
        'Anda dapat memantau progres mahasiswa yang berada di bawah bimbingan kompen Anda.',
      ],
    ),
  ];

  // ─── DATA FAQ DOSEN ──────────────────────────────────────────────────────────
  final List<_FaqItem> _faq = [
    _FaqItem(
      question: 'Bagaimana jika mahasiswa salah mengunggah bukti?',
      answer: 'Anda dapat menolak pengajuan tersebut dan memberikan catatan pada kolom keterangan agar mahasiswa mengunggah ulang bukti yang benar.',
    ),
    _FaqItem(
      question: 'Apakah saya bisa membatalkan verifikasi?',
      answer: 'Jika pengajuan sudah disetujui, perubahan status harus melalui koordinasi dengan admin prodi terkait.',
    ),
    _FaqItem(
      question: 'Bagaimana cara melihat total kompen yang sudah diverifikasi?',
      answer: 'Total verifikasi yang Anda lakukan akan terakumulasi secara otomatis di dashboard Home.',
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