import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/app_header.dart';
import '../widgets/app_bottom_nav.dart';
import 'login/login_screen.dart';
import '../utils/nav_mahasiswa.dart';
import '../utils/location_helper.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {

  static const Color _primaryRed = Color(0xFFB71C1C);
  static const Color _backgroundCream = Color(0xFFF5EFE6);
  static const Color _textDark = Color(0xFF2D2D2D);
  static const Color _textGrey = Color(0xFF9E9E9E);

  Position? _posisiSekarang;
  bool _loadingLokasi = false;
  final MapController _mapController = MapController();

  static const List<Map<String, dynamic>> _statusList = [
    {
      "title": "Kompensasi Selesai",
      "subtitle": "Seluruh proses kompensasi telah selesai. Form digital dapat diakses pada Riwayat Kompensasi.",
      "date": "13 Apr · 15:00",
      "isDone": true,
      "isActive": false,
      "isFinal": true,
    },
    {
      "title": "Selesai & Tervalidasi",
      "subtitle": "Pengajuan kompensasi telah divalidasi secara penuh oleh Kaprodi.",
      "date": "13 Apr · 15:00",
      "isDone": true,
      "isActive": false,
      "isFinal": false,
    },
    {
      "title": "Validasi Kaprodi",
      "subtitle": "Menunggu tanda tangan digital Kaprodi sebagai validasi akhir.",
      "date": "13 Apr · 14:30",
      "isDone": true,
      "isActive": false,
      "isFinal": false,
    },
    {
      "title": "Jam Alpha Berkurang Otomatis",
      "subtitle": "Sistem otomatis kurangi jam alpha matkul terkait.",
      "date": "13 Apr · 13:46",
      "isDone": true,
      "isActive": false,
      "isFinal": false,
    },
    {
      "title": "TTD Digital Diterima",
      "subtitle": "Form kompensasi digital telah ditandatangani.",
      "date": "13 Apr · 13:45",
      "isDone": true,
      "isActive": false,
      "isFinal": false,
    },
    {
      "title": "Menunggu TTD Admin",
      "subtitle": "Jika dosen tidak TTD, admin yang menandatangani.",
      "date": "13 Apr · 11:00",
      "isDone": true,
      "isActive": false,
      "isFinal": false,
    },
    {
      "title": "Menunggu TTD Dosen",
      "subtitle": "Mahasiswa telah submit form digital. Menunggu tanda tangan dosen.",
      "date": "13 Apr · 10:30",
      "isDone": true,
      "isActive": false,
      "isFinal": false,
    },
    {
      "title": "Sedang Dikerjakan",
      "subtitle": "Sistem update status otomatis setelah konfirmasi.",
      "date": "13 Apr · 09:15",
      "isDone": true,
      "isActive": false,
      "isFinal": false,
    },
    {
      "title": "Pengajuan Diterima",
      "subtitle": "Dosen & Admin telah konfirmasi pengajuan kompen.",
      "date": "13 Apr · 08:00",
      "isDone": true,
      "isActive": false,
      "isFinal": false,
    },
  ];

  // Ambil lokasi GPS mahasiswa saat ini
  Future<void> _ambilLokasi() async {
    setState(() => _loadingLokasi = true);
    final pos = await LocationHelper.getCurrentPosition();
    setState(() {
      _posisiSekarang = pos;
      _loadingLokasi = false;
    });
    if (pos != null) {
      _mapController.move(LatLng(pos.latitude, pos.longitude), 17);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat mengakses lokasi. Pastikan GPS aktif.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Widget peta lokasi
  Widget _buildMapSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, color: _primaryRed, size: 18),
                const SizedBox(width: 6),
                const Text(
                  'Lokasi Pengerjaan',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: _textDark,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _loadingLokasi ? null : _ambilLokasi,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE5E5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _loadingLokasi
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _primaryRed,
                            ),
                          )
                        : const Row(
                            children: [
                              Icon(Icons.my_location, color: _primaryRed, size: 13),
                              SizedBox(width: 4),
                              Text(
                                'Tandai Lokasi',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _primaryRed,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
          // Peta OpenStreetMap
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(14),
              bottomRight: Radius.circular(14),
            ),
            child: SizedBox(
              height: 200,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _posisiSekarang != null
                      ? LatLng(_posisiSekarang!.latitude, _posisiSekarang!.longitude)
                      : const LatLng(-7.9402, 112.6178), // koordinat default Polinema
                  initialZoom: 17,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.tugas4_pm',
                  ),
                  if (_posisiSekarang != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(
                            _posisiSekarang!.latitude,
                            _posisiSekarang!.longitude,
                          ),
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_pin,
                            color: _primaryRed,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          // Info koordinat
          if (_posisiSekarang != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              child: Row(
                children: [
                  const Icon(Icons.gps_fixed, size: 12, color: _textGrey),
                  const SizedBox(width: 4),
                  Text(
                    '${_posisiSekarang!.latitude.toStringAsFixed(5)}, '
                    '${_posisiSekarang!.longitude.toStringAsFixed(5)}',
                    style: const TextStyle(fontSize: 11, color: _textGrey),
                  ),
                ],
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 8, 14, 12),
              child: Text(
                'Tap "Tandai Lokasi" untuk menampilkan posisi kamu sekarang',
                style: TextStyle(fontSize: 11, color: _textGrey),
              ),
            ),
        ],
      ),
    );
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card info pengajuan
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.05),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFCE8E8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.receipt_long_outlined, color: _primaryRed, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pemrograman Web — 2 Jam Alpha',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: _textDark),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '244107060064 · Sally Savista',
                                  style: TextStyle(fontSize: 11, color: _textGrey),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Selesai',
                              style: TextStyle(fontSize: 11, color: Color(0xFF2E7D32), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Text(
                      'LOKASI PENGERJAAN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _textGrey,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),

                  _buildMapSection(),

                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Text(
                      'RIWAYAT TRACKING',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _textGrey,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),

                  // Timeline
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: _statusList.length,
                      itemBuilder: (context, index) {
                        final status = _statusList[index];
                        final isLast = index == _statusList.length - 1;
                        final isDone = status['isDone'] as bool;
                        final isActive = status['isActive'] as bool;
                        final isFinal = status['isFinal'] as bool;

                        // Banner "Kompensasi Selesai" hijau soft
                        if (isFinal) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEDF7EE),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFA5D6A7), width: 1),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFC8E6C9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.verified_rounded, color: Color(0xFF2E7D32), size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Kompensasi Selesai! 🎉',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: Color(0xFF1B5E20),
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          status['subtitle'],
                                          style: const TextStyle(fontSize: 11, color: Color(0xFF388E3C)),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.access_time, size: 11, color: Color(0xFF66BB6A)),
                                            const SizedBox(width: 3),
                                            Text(
                                              status['date'],
                                              style: const TextStyle(fontSize: 10, color: Color(0xFF66BB6A)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // ── FIX: IntrinsicHeight + Expanded pada garis
                        // IntrinsicHeight bikin Column kiri tau tinggi card kanan,
                        // lalu Expanded pada garis mengisi PERSIS dari bawah lingkaran
                        // sampai ujung bawah card — tidak ada jarak sama sekali.
                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Kolom kiri: lingkaran + garis nyambung
                              SizedBox(
                                width: 40,
                                child: Column(
                                  children: [
                                    // Lingkaran (tidak pakai margin top lagi)
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: isDone
                                                ? _primaryRed.withOpacity(0.15)
                                                : Colors.black.withOpacity(0.06),
                                            blurRadius: 6,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 26,
                                          height: 26,
                                          decoration: BoxDecoration(
                                            color: isDone
                                                ? _primaryRed
                                                : isActive
                                                    ? Colors.white
                                                    : const Color(0xFFE0E0E0),
                                            shape: BoxShape.circle,
                                            border: isActive
                                                ? Border.all(color: _primaryRed, width: 2.5)
                                                : null,
                                          ),
                                          child: isDone
                                              ? const Icon(Icons.check, color: Colors.white, size: 13)
                                              : isActive
                                                  ? Center(
                                                      child: Container(
                                                        width: 9,
                                                        height: 9,
                                                        decoration: const BoxDecoration(
                                                          color: _primaryRed,
                                                          shape: BoxShape.circle,
                                                        ),
                                                      ),
                                                    )
                                                  : null,
                                        ),
                                      ),
                                    ),

                                    // Garis: Expanded = mengisi sisa tinggi IntrinsicHeight
                                    // sehingga garis persis nyambung dari bawah lingkaran
                                    // sampai bawah card konten di sebelahnya
                                    if (!isLast)
                                      Expanded(
                                        child: Container(
                                          width: 2,
                                          color: isDone
                                              ? _primaryRed.withOpacity(0.25)
                                              : const Color(0xFFE0E0E0),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // ── Kolom kanan: card konten
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(left: 8, top: 6, bottom: 6),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: isActive
                                        ? Border.all(color: _primaryRed.withOpacity(0.3))
                                        : null,
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color.fromRGBO(0, 0, 0, 0.04),
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        status['title'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: isActive ? _primaryRed : _textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        status['subtitle'],
                                        style: const TextStyle(fontSize: 12, color: _textGrey),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time, size: 12, color: _textGrey),
                                          const SizedBox(width: 4),
                                          Text(
                                            status['date'],
                                            style: const TextStyle(fontSize: 11, color: _textGrey),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppBottomNav(
            activeTab: NavTab.tracking,
            onTabSelected: (tab) =>
                NavMahasiswa.handleBottomNav(context, tab, NavTab.tracking),
          ),
        ],
      ),
    );
  }
}