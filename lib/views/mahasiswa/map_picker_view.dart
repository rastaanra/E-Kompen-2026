import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapPickerView extends StatefulWidget {
  const MapPickerView({super.key});

  @override
  State<MapPickerView> createState() => _MapPickerViewState();
}

class _MapPickerViewState extends State<MapPickerView> {
  static const Color _red = Color(0xFFB71C1C);

  final MapController _mapController = MapController();

  // Default: Politeknik Negeri Malang
  LatLng _selectedLatLng = const LatLng(-7.9402, 112.6178);
  String _namaLokasi = 'Lokasi dipilih';
  bool _isLoadingLokasi = false;

  @override
  void initState() {
    super.initState();
    _getLokasiSekarang();
  }

  // Ambil lokasi GPS sekarang
  Future<void> _getLokasiSekarang() async {
    setState(() => _isLoadingLokasi = true);

    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final latLng = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _selectedLatLng = latLng;
        _namaLokasi = 'Lokasi saya sekarang';
      });
      _mapController.move(latLng, 16);
    } catch (e) {
      // Kalau gagal, tetap pakai default
    }

    setState(() => _isLoadingLokasi = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _red,
        foregroundColor: Colors.white,
        title: const Text(
          'Pilih Lokasi Pengerjaan',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        elevation: 0,
        actions: [
          // Tombol lokasi sekarang
          IconButton(
            onPressed: _getLokasiSekarang,
            icon: _isLoadingLokasi
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.my_location, color: Colors.white),
            tooltip: 'Lokasi saya',
          ),
        ],
      ),
      body: Column(
        children: [
          // Info koordinat yang dipilih
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFFCE8E8),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: _red, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_selectedLatLng.latitude.toStringAsFixed(5)}, '
                    '${_selectedLatLng.longitude.toStringAsFixed(5)}',
                    style: const TextStyle(
                        fontSize: 12,
                        color: _red,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const Icon(Icons.touch_app_outlined,
                    size: 14, color: _red),
                const SizedBox(width: 4),
                const Text(
                  'Tap peta untuk pilih',
                  style: TextStyle(fontSize: 11, color: _red),
                ),
              ],
            ),
          ),

          // Peta
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedLatLng,
                initialZoom: 16,
                onTap: (tapPosition, point) {
                  setState(() {
                    _selectedLatLng = point;
                    _namaLokasi = 'Lokasi dipilih';
                  });
                },
              ),
              children: [
                // Tile layer OpenStreetMap
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                // Marker lokasi yang dipilih
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLatLng,
                      width: 48,
                      height: 48,
                      child: const Icon(
                        Icons.location_on,
                        color: _red,
                        size: 48,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Field nama lokasi + tombol konfirmasi
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.08),
                  blurRadius: 12,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nama Lokasi',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D)),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (v) => setState(() => _namaLokasi = v),
                  controller:
                      TextEditingController(text: _namaLokasi)
                        ..selection = TextSelection.fromPosition(
                          TextPosition(offset: _namaLokasi.length),
                        ),
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText:
                        'Contoh: Lab Komputer A, Ruang Dosen...',
                    hintStyle: const TextStyle(
                        fontSize: 13, color: Color(0xFF9E9E9E)),
                    prefixIcon: const Icon(Icons.place_outlined,
                        size: 18, color: Color(0xFF9E9E9E)),
                    filled: true,
                    fillColor: const Color(0xFFF8F4EE),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFFE8E0D5)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFFE8E0D5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: _red, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_namaLokasi.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Isi nama lokasi dulu'),
                            backgroundColor: _red,
                          ),
                        );
                        return;
                      }
                      // Return data ke form lengkapi
                      Navigator.pop(context, {
                        'lat': _selectedLatLng.latitude,
                        'lng': _selectedLatLng.longitude,
                        'nama': _namaLokasi.trim(),
                      });
                    },
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text(
                      'Konfirmasi Lokasi',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _red,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}