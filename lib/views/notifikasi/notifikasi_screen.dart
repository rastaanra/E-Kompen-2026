import 'package:flutter/material.dart';
import '../../models/notifikasi.dart';
import '../../services/notifikasi_service.dart';
import '../../utils/session_manager.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  List<Notifikasi> notifList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotif();
  }

  Future<void> _loadNotif() async {
    try {
      final idPengguna = await SessionManager.getIdPengguna();

      if (idPengguna == null) {
        setState(() => isLoading = false);
        return;
      }

      final service = NotifikasiService();

      final data = await service.getNotifikasi(idPengguna);

      await service.lihatSemua(idPengguna);

      setState(() {
        notifList = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error notif: $e');

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF2D2D2D),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifikasi Kompen',
              style: TextStyle(
                color: Color(0xFF2D2D2D),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Semua aktivitas kompen akan muncul di sini',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFB71C1C),
              ),
            )
          : notifList.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifList.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _NotifikasiCard(
                      notifikasi: notifList[index],
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 70,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada notifikasi',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifikasiCard extends StatelessWidget {
  final Notifikasi notifikasi;

  const _NotifikasiCard({
    required this.notifikasi,
  });

  @override
  Widget build(BuildContext context) {
    final tipe = _getTipe(notifikasi.judul);

    return Container(
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
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: tipe.warnaBorder,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),

            const SizedBox(width: 14),

            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: tipe.warnaIkonBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                tipe.ikon,
                color: tipe.warnaIkon,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notifikasi.judul,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notifikasi.pesan,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatWaktu(notifikasi.waktuKirim),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
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

  _TipeNotifikasi _getTipe(String judul) {
    final j = judul.toLowerCase();

    if (j.contains('pengajuan kompen baru')) {
      return _TipeNotifikasi.pengajuanBaru;
    }

    if (j.contains('menunggu ttd')) {
      return _TipeNotifikasi.menungguTtd;
    }

    if (j.contains('disetujui')) {
      return _TipeNotifikasi.disetujui;
    }

    return _TipeNotifikasi.pengajuanBaru;
  }

  String _formatWaktu(DateTime waktu) {
    final selisih = DateTime.now().difference(waktu);

    if (selisih.inMinutes < 1) {
      return 'Baru saja';
    }

    if (selisih.inMinutes < 60) {
      return '${selisih.inMinutes} menit lalu';
    }

    if (selisih.inHours < 24) {
      return '${selisih.inHours} jam lalu';
    }

    if (selisih.inDays < 7) {
      return '${selisih.inDays} hari lalu';
    }

    return '${waktu.day}/${waktu.month}/${waktu.year}';
  }
}

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

  static const pengajuanBaru = _TipeNotifikasi(
    warnaBorder: Color(0xFFB71C1C),
    warnaIkonBg: Color(0xFFFFEBEE),
    warnaIkon: Color(0xFFB71C1C),
    ikon: Icons.assignment_outlined,
  );

  static const menungguTtd = _TipeNotifikasi(
    warnaBorder: Color(0xFFFF9800),
    warnaIkonBg: Color(0xFFFFF3E0),
    warnaIkon: Color(0xFFFF9800),
    ikon: Icons.draw_outlined,
  );

  static const disetujui = _TipeNotifikasi(
    warnaBorder: Color(0xFF4CAF50),
    warnaIkonBg: Color(0xFFE8F5E9),
    warnaIkon: Color(0xFF4CAF50),
    ikon: Icons.check_circle_outline,
  );
}