import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../utils/nav_mahasiswa.dart';
import '../../providers/pengajuan_provider.dart';

class TrackingScreen extends StatefulWidget {
  final int idPengajuan;
  final String matkul;
  final String namaDosen;
  final int jamAlpha;
  final String status;
  final String? namaLokasi;
  final double? latitude;
  final double? longitude;
  final String? deskripsiTugas;

  const TrackingScreen({
    super.key,
    required this.idPengajuan,
    required this.matkul,
    required this.namaDosen,
    required this.jamAlpha,
    required this.status,
    this.namaLokasi,
    this.latitude,
    this.longitude,
    this.deskripsiTugas,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  static const Color _primaryRed = Color(0xFFB71C1C);
  static const Color _cream = Color(0xFFF5EFE6);
  static const Color _dark = Color(0xFF2D2D2D);
  static const Color _grey = Color(0xFF9E9E9E);

  // Dummy riwayat tracking
  // TODO: ganti dengan data dari PengajuanProvider.getRiwayat()
  List<Map<String, dynamic>> get _riwayatList {
    final bool isSelesai = widget.status == 'selesai';
    final bool isMenungguKaprodi = widget.status == 'menunggu_ttd_kaprodi';
    final bool isMenungguDosen = widget.status == 'menunggu_ttd_dosen';
    final bool isMenungguAdmin = widget.status == 'menunggu_ttd_admin';

    final List<Map<String, dynamic>> all = [
      if (isSelesai) ...[
        {
          'judul': 'Kompensasi Selesai! 🎉',
          'deskripsi':
              'Seluruh proses kompensasi telah selesai. Form digital dapat diakses pada Riwayat Kompensasi.',
          'waktu': '13 Apr · 15:00',
          'done': true,
          'highlight': true,
        },
        {
          'judul': 'Selesai & Tervalidasi',
          'deskripsi':
              'Pengajuan kompensasi telah divalidasi secara penuh oleh Kaprodi.',
          'waktu': '13 Apr · 15:00',
          'done': true,
        },
        {
          'judul': 'Validasi Kaprodi',
          'deskripsi':
              'Menunggu tanda tangan digital Kaprodi sebagai validasi akhir.',
          'waktu': '13 Apr · 14:30',
          'done': true,
        },
        {
          'judul': 'Jam Alpha Berkurang Otomatis',
          'deskripsi':
              'Sistem otomatis kurangi jam alpha matkul terkait.',
          'waktu': '13 Apr · 13:46',
          'done': true,
        },
        {
          'judul': 'TTD Digital Diterima',
          'deskripsi':
              'Form kompensasi digital telah ditandatangani.',
          'waktu': '13 Apr · 13:45',
          'done': true,
        },
        {
          'judul': widget.status.contains('admin')
              ? 'Menunggu TTD Admin'
              : 'Menunggu TTD Dosen',
          'deskripsi': widget.status.contains('admin')
              ? 'Admin telah menandatangani form kompensasi.'
              : 'Mahasiswa telah submit form digital. Menunggu tanda tangan dosen.',
          'waktu': '13 Apr · 11:00',
          'done': true,
        },
        {
          'judul': 'Sedang Dikerjakan',
          'deskripsi':
              'Sistem update status otomatis setelah konfirmasi.',
          'waktu': '13 Apr · 09:15',
          'done': true,
        },
        {
          'judul': 'Pengajuan Diterima',
          'deskripsi': 'Dosen & Admin telah konfirmasi pengajuan kompen.',
          'waktu': '13 Apr · 08:00',
          'done': true,
        },
      ] else ...[
        if (isMenungguKaprodi) ...[
          {
            'judul': 'Validasi Kaprodi',
            'deskripsi':
                'Menunggu tanda tangan digital Kaprodi sebagai validasi akhir.',
            'waktu': 'Sekarang',
            'done': false,
            'active': true,
          },
          {
            'judul': 'TTD Digital Diterima',
            'deskripsi':
                'Form kompensasi digital telah ditandatangani.',
            'waktu': '10 Apr · 13:45',
            'done': true,
          },
        ],
        if (isMenungguDosen) ...[
          {
            'judul': 'Menunggu TTD Dosen',
            'deskripsi':
                'Mahasiswa telah submit form digital. Menunggu tanda tangan dosen.',
            'waktu': 'Sekarang',
            'done': false,
            'active': true,
          },
        ],
        if (isMenungguAdmin) ...[
          {
            'judul': 'Menunggu TTD Admin',
            'deskripsi':
                'Mahasiswa telah submit form digital. Menunggu tanda tangan admin.',
            'waktu': 'Sekarang',
            'done': false,
            'active': true,
          },
        ],
        {
          'judul': 'Sedang Dikerjakan',
          'deskripsi':
              'Sistem update status otomatis setelah konfirmasi.',
          'waktu': '08 Apr · 09:15',
          'done': true,
        },
        {
          'judul': 'Pengajuan Diterima',
          'deskripsi':
              'Dosen & Admin telah konfirmasi pengajuan kompen.',
          'waktu': '08 Apr · 08:00',
          'done': true,
        },
      ],
    ];

    return all;
  }

  @override
  Widget build(BuildContext context) {
    final isSelesai = widget.status == 'selesai';

    return Scaffold(
      backgroundColor: _primaryRed,
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
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                children: [
                  // Card info pengajuan
                  _buildInfoCard(isSelesai),
                  const SizedBox(height: 20),

                  // Lokasi Pengerjaan (read-only)
                  if (widget.namaLokasi != null) ...[
                    _buildSectionTitle('LOKASI PENGERJAAN'),
                    const SizedBox(height: 10),
                    _buildLokasiCard(),
                    const SizedBox(height: 20),
                  ],

                  // Riwayat Tracking
                  _buildSectionTitle('RIWAYAT TRACKING'),
                  const SizedBox(height: 10),
                  _buildTimeline(),
                ],
              ),
            ),
          ),
          AppBottomNav(
            activeTab: NavTab.tracking,
            onTabSelected: (tab) => NavMahasiswa.handleBottomNav(
                context, tab, NavTab.tracking),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _grey,
          letterSpacing: 0.8,
        ),
      );

  // Card info pengajuan di atas
  Widget _buildInfoCard(bool isSelesai) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ikon dokumen
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelesai
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFCE8E8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.description_outlined,
              color:
                  isSelesai ? const Color(0xFF2E7D32) : _primaryRed,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.matkul} — ${widget.jamAlpha} Jam Alpha',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: _dark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.namaDosen,
                  style:
                      const TextStyle(fontSize: 12, color: _grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Badge status
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isSelesai
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isSelesai ? 'Selesai' : 'Berjalan',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelesai
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFF57F17),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Lokasi read-only
  Widget _buildLokasiCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header lokasi
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  color: _primaryRed, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.namaLokasi ?? 'Lokasi Pengerjaan',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: _dark,
                  ),
                ),
              ),
              // Badge read-only
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline, size: 10, color: _grey),
                    SizedBox(width: 3),
                    Text(
                      'Read only',
                      style: TextStyle(fontSize: 10, color: _grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Area peta (placeholder — sambung ke google maps / flutter_map)
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // TODO: ganti dengan GoogleMap atau FlutterMap widget
                // GoogleMap(
                //   initialCameraPosition: CameraPosition(
                //     target: LatLng(widget.latitude!, widget.longitude!),
                //     zoom: 16,
                //   ),
                //   markers: {
                //     Marker(
                //       markerId: const MarkerId('lokasi'),
                //       position: LatLng(widget.latitude!, widget.longitude!),
                //     ),
                //   },
                //   myLocationEnabled: false,
                //   zoomControlsEnabled: false,
                // ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map_outlined,
                          size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        'Peta Lokasi',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500),
                      ),
                      if (widget.latitude != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${widget.latitude!.toStringAsFixed(4)}, ${widget.longitude!.toStringAsFixed(4)}',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade400),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Info koordinat
          if (widget.latitude != null)
            Row(
              children: [
                const Icon(Icons.my_location,
                    size: 13, color: _grey),
                const SizedBox(width: 4),
                Text(
                  'Tap "Tandai Lokasi" untuk menampilkan posisi kamu sekarang',
                  style:
                      const TextStyle(fontSize: 11, color: _grey),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // Timeline riwayat
  Widget _buildTimeline() {
    final list = _riwayatList;

    return Column(
      children: List.generate(list.length, (index) {
        final item = list[index];
        final isFirst = index == 0;
        final isLast = index == list.length - 1;
        final isDone = item['done'] == true;
        final isHighlight = item['highlight'] == true;
        final isActive = item['active'] == true;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Garis + dot timeline
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    // Garis atas
                    if (!isFirst)
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Container(
                            width: 2,
                            color: isDone
                                ? _primaryRed
                                : Colors.grey.shade300,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 8),

                    // Dot
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isDone
                            ? _primaryRed
                            : isActive
                                ? const Color(0xFFFFF8E1)
                                : Colors.grey.shade200,
                        shape: BoxShape.circle,
                        border: isActive
                            ? Border.all(
                                color: const Color(0xFFF57F17),
                                width: 2)
                            : null,
                      ),
                      child: isDone
                          ? const Icon(Icons.check,
                              size: 13, color: Colors.white)
                          : isActive
                              ? Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF57F17),
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : null,
                    ),

                    // Garis bawah
                    if (!isLast)
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: Container(
                            width: 2,
                            color: isDone
                                ? _primaryRed
                                : Colors.grey.shade300,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 8),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Konten riwayat
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: isFirst ? 0 : 8,
                      bottom: isLast ? 0 : 8),
                  child: isHighlight
                      ? _buildHighlightCard(item)
                      : _buildTimelineCard(item, isDone, isActive),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // Card highlight (kompensasi selesai)
  Widget _buildHighlightCard(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFA5D6A7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['judul'],
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item['deskripsi'],
            style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF2E7D32),
                height: 1.4),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.access_time,
                  size: 12, color: Color(0xFF4CAF50)),
              const SizedBox(width: 4),
              Text(
                item['waktu'],
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF4CAF50)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Card timeline biasa
  Widget _buildTimelineCard(
      Map<String, dynamic> item, bool isDone, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isActive
            ? Border.all(color: const Color(0xFFFFCC02))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['judul'],
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: isDone ? _dark : isActive ? const Color(0xFFF57F17) : _grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item['deskripsi'],
            style: TextStyle(
              fontSize: 12,
              color: isDone ? _grey : isActive ? const Color(0xFF92400E) : Colors.grey.shade400,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 12,
                color: isActive
                    ? const Color(0xFFF59E0B)
                    : Colors.grey.shade400,
              ),
              const SizedBox(width: 4),
              Text(
                item['waktu'],
                style: TextStyle(
                  fontSize: 11,
                  color: isActive
                      ? const Color(0xFFF59E0B)
                      : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}