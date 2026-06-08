import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notifikasi_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/notifikasi.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ambil idPengguna dari AuthProvider — sesuai model Pengguna yang sudah ada
      final idPengguna =
          context.read<AuthProvider>().pengguna!.idPengguna;
      context.read<NotifikasiProvider>().getNotifikasi(idPengguna);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      appBar: _buildAppBar(),
      body: Consumer<NotifikasiProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF8B7355),
              ),
            );
          }

          if (provider.listNotifikasi.isEmpty) {
            return _buildKosong();
          }

          return _buildListNotifikasi(provider.listNotifikasi);
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF5F0EB),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1A1A1A), size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notifikasi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          Text(
            'Semua notifikasi akan muncul disini.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF888888),
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
      toolbarHeight: 72,
    );
  }

  Widget _buildListNotifikasi(List<Notifikasi> list) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _NotifikasiCard(notifikasi: list[index]);
      },
    );
  }

  Widget _buildKosong() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada notifikasi',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card per notifikasi ──────────────────────────────────────────────────────

class _NotifikasiCard extends StatelessWidget {
  final Notifikasi notifikasi;
  const _NotifikasiCard({required this.notifikasi});

  @override
  Widget build(BuildContext context) {
    final tipe = _getTipe(notifikasi.judul);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Border kiri berwarna
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: tipe.warnaBorder,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Ikon lingkaran
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tipe.warnaIkonBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(tipe.ikon, color: tipe.warnaIkon, size: 20),
              ),
            ),
            const SizedBox(width: 12),

            // Teks
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notifikasi.judul,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatWaktu(notifikasi.waktuKirim),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notifikasi.pesan,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF555555),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  // Tentukan tipe visual dari kata kunci di judul notifikasi
  _TipeNotifikasi _getTipe(String judul) {
    final j = judul.toLowerCase();
    if (j.contains('dikonfirmasi') ||
        j.contains('diterima') ||
        j.contains('disetujui') ||
        j.contains('selesai') ||
        j.contains('ttd') ||
        j.contains('tanda tangan')) {
      return _TipeNotifikasi.konfirmasi;
    }
    return _TipeNotifikasi.peringatan;
  }

  String _formatWaktu(DateTime waktu) {
    final selisih = DateTime.now().difference(waktu);
    if (selisih.inMinutes < 1) return 'Baru saja';
    if (selisih.inMinutes < 60) return '${selisih.inMinutes} mnt yang lalu';
    if (selisih.inHours < 24) return '${selisih.inHours} jam yang lalu';
    if (selisih.inDays < 7) return '${selisih.inDays} hari yang lalu';
    return '${waktu.day}/${waktu.month}/${waktu.year}';
  }
}

// ── Tipe visual notifikasi ───────────────────────────────────────────────────

class _TipeNotifikasi {
  final Color warnaBorder;
  final Color warnaIkonBg;
  final Color warnaIkon;
  final IconData ikon;

  const _TipeNotifikasi({
    required this.warnaBorder,
    required this.warnaIkonBg,
    required this.warnaIkon,
    required this.ikon,
  });

  // Hijau — konfirmasi/disetujui (sesuai mockup)
  static const konfirmasi = _TipeNotifikasi(
    warnaBorder: Color(0xFF5BAD6F),
    warnaIkonBg: Color(0xFFDFF2E3),
    warnaIkon: Color(0xFF5BAD6F),
    ikon: Icons.check_rounded,
  );

  // Kuning/coklat — peringatan/reminder (sesuai mockup)
  static const peringatan = _TipeNotifikasi(
    warnaBorder: Color(0xFFB8860B),
    warnaIkonBg: Color(0xFFFFF3CD),
    warnaIkon: Color(0xFFB8860B),
    ikon: Icons.warning_amber_rounded,
  );
}