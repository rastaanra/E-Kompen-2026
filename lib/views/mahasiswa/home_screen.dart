import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../utils/nav_mahasiswa.dart';
import '../../providers/mahasiswa_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _primaryRed = Color(0xFFB71C1C);
  static const Color _backgroundCream = Color(0xFFF5EFE6);
  static const Color _cardBeige = Color(0xFFEDE0CC);
  static const Color _textDark = Color(0xFF2D2D2D);
  static const Color _textGrey = Color(0xFF9E9E9E);

  // ── Dummy data tagihan kompen per matkul
  // TODO: ganti dengan data dari API kalau endpoint sudah tersedia
  static const _tagihanList = [
    {
      'matkul': 'Basis Data',
      'dosen': 'Dr. Ahmad Fauzi, M.Kom',
      'sisaJam': 6,
      'totalJam': 12,
      'status': 'proses', // 'proses' | 'belum' | 'selesai'
    },
    {
      'matkul': 'Jaringan Komputer',
      'dosen': 'Ir. Budi Santoso, M.T',
      'sisaJam': 6,
      'totalJam': 6,
      'status': 'belum',
    },
    {
      'matkul': 'Pemrograman Web',
      'dosen': 'Siti Rahayu, S.Kom, M.T',
      'sisaJam': 0,
      'totalJam': 8,
      'status': 'selesai',
    },
  ];

  // TODO: ganti dengan data dari provider/API
  static const int _totalSisaKompen = 19;
  static const int _telahDiselesaikan = 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // TODO: uncomment kalau endpoint sudah ada
      // final provider = context.read<MahasiswaProvider>();
      // provider.getData(idPengguna);
    });
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
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreetingCard(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Kartu Total Sisa + Telah Diselesaikan
                          _buildSummaryCards(),
                          const SizedBox(height: 20),

                          // Tagihan Kompen Saya
                          const Text(
                            'Tagihan Kompen Saya',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: _textDark,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Warning dikali 2
                          _buildWarningBanner(),
                          const SizedBox(height: 12),

                          // List tagihan per matkul
                          ..._tagihanList.map((t) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildTagihanCard(t),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AppBottomNav(
            activeTab: NavTab.home,
            onTabSelected: (tab) =>
                NavMahasiswa.handleBottomNav(context, tab, NavTab.home),
          ),
        ],
      ),
    );
  }

  // Greeting + ilustrasi dokumen
  Widget _buildGreetingCard() {
    // TODO: ganti nama & NIM dari provider.mahasiswa
    return Consumer<MahasiswaProvider>(
      builder: (context, provider, _) {
        final nama = provider.mahasiswa?.nama ?? 'Mahasiswa';
        final nim = provider.mahasiswa?.nim ?? '-';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, $nama!',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Mahasiswa',
                      style: const TextStyle(fontSize: 14, color: _textGrey),
                    ),
                  ],
                ),
              ),
              _buildDocIllustration(),
            ],
          ),
        );
      },
    );
  }

  // Ilustrasi dokumen di pojok kanan greeting
  Widget _buildDocIllustration() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(183, 28, 28, 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        Positioned(top: -8, left: 6, child: _docIcon()),
        Positioned(top: 4, left: 28, child: _docIcon(shortLine: true)),
        Positioned(
          bottom: -6,
          right: -4,
          child: Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: _primaryRed,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 14),
          ),
        ),
      ],
    );
  }

  Widget _docIcon({bool shortLine = false}) {
    return Container(
      width: 52,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(7),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            5,
            (i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Container(
                height: 4,
                width: shortLine
                    ? (i == 0 ? 30.0 : i == 2 ? 20.0 : 24.0)
                    : (i == 0 ? 32.0 : i == 2 ? 24.0 : 28.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Kartu ringkasan: Total Sisa + Telah Diselesaikan
  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            label: 'Total Sisa Kompen',
            value: _totalSisaKompen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            label: 'Telah diselesaikan',
            value: _telahDiselesaikan,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({required String label, required int value}) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: _textGrey),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$value ',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: _primaryRed,
                  ),
                ),
                const TextSpan(
                  text: 'Jam',
                  style: TextStyle(
                    fontSize: 14,
                    color: _textGrey,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Warning banner dikali 2
  Widget _buildWarningBanner() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFCC02)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tagihan yang tidak diselesaikan semester ini akan dikali 2 di semester depan.',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF92400E),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Card tagihan per mata kuliah
  Widget _buildTagihanCard(Map<String, dynamic> t) {
    final int sisaJam = t['sisaJam'];
    final int totalJam = t['totalJam'];
    final String status = t['status'];
    final double progress = totalJam > 0
        ? ((totalJam - sisaJam) / totalJam).clamp(0.0, 1.0)
        : 1.0;
    final int persen = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: nama matkul + badge status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t['matkul'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.school_outlined,
                            size: 12, color: _textGrey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            t['dosen'],
                            style: const TextStyle(
                                fontSize: 12, color: _textGrey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(status),
            ],
          ),
          const SizedBox(height: 12),

          // Sisa jam
          Text(
            'Sisa: $sisaJam jam dari $totalJam jam',
            style: const TextStyle(fontSize: 12, color: _textGrey),
          ),
          const SizedBox(height: 6),

          // Progress bar + persentase
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE0E0E0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      status == 'selesai'
                          ? const Color(0xFF2E7D32)
                          : _primaryRed,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$persen%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Link ajukan kompen
          GestureDetector(
            onTap: () =>
                NavMahasiswa.handleBottomNav(context, NavTab.pengajuan, NavTab.home),
            child: const Text(
              'Ketuk untuk ajukan kompen',
              style: TextStyle(
                fontSize: 12,
                color: _primaryRed,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                decorationColor: _primaryRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    late Color bg;
    late Color text;
    late String label;

    switch (status) {
      case 'proses':
        bg = const Color(0xFFFFF3CD);
        text = const Color(0xFF856404);
        label = 'Proses pengerjaan';
        break;
      case 'belum':
        bg = const Color(0xFFFFEBEE);
        text = const Color(0xFFB71C1C);
        label = 'Belum pengerjaan';
        break;
      case 'selesai':
        bg = const Color(0xFFE8F5E9);
        text = const Color(0xFF2E7D32);
        label = 'Selesai pengerjaan';
        break;
      default:
        bg = const Color(0xFFF5F5F5);
        text = _textGrey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }
}