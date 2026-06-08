import 'package:flutter/material.dart';
import '../../widgets/app_header.dart'; // Memanggil file AppHeader kamu

// ── Tipe notif untuk menentukan warna indikator UI
enum NotifTipe { sukses, peringatan, info }

// ── Struktur Data Dummy Notifikasi
class NotifDummy {
  final String judul;
  final String pesan;
  final String waktu;
  final NotifTipe tipe;
  final bool isRead;

  const NotifDummy({
    required this.judul,
    required this.pesan,
    required this.waktu,
    required this.tipe,
    this.isRead = false,
  });
}

// ── Pabrik Data Dummy Sesuai Kebutuhan Fungsional Kamu
class DummyNotifProvider {
  // 1. ADMIN
  static List<NotifDummy> getAdminNotif() => [
        const NotifDummy(
          judul: 'Pengajuan Kompen Baru',
          pesan: 'Sally Savista mengajukan kompen Basis Data. Segera cek bagian Konfirmasi Pengajuan.',
          waktu: 'Baru saja',
          tipe: NotifTipe.info,
          isRead: false,
        ),
        const NotifDummy(
          judul: 'Form Penyelesaian Masuk',
          pesan: 'Michael Jordan mengirim form penyelesaian kompen Jarkom. Silakan verifikasi dan berikan TTD digital.',
          waktu: '10 mnt yang lalu',
          tipe: NotifTipe.peringatan,
          isRead: false,
        ),
        const NotifDummy(
          judul: 'Pengajuan Berhasil Dikonfirmasi',
          pesan: 'Kamu telah menyetujui pengajuan kompen Kalkulus atas nama Andi Budiman.',
          waktu: '1 jam yang lalu',
          tipe: NotifTipe.sukses,
          isRead: true,
        ),
      ];

  // 2. MAHASISWA
  static List<NotifDummy> getMahasiswaNotif() => [
        const NotifDummy(
          judul: 'Batas Kompen Hampir Habis!',
          pesan: 'Kompen Pemrograman Web kamu tinggal 2 hari lagi! Selesaikan sekarang atau kompen double di semester depan.',
          waktu: 'Baru saja',
          tipe: NotifTipe.peringatan,
          isRead: false,
        ),
        const NotifDummy(
          judul: 'Pengajuan Diterima',
          pesan: 'Hore! Pengajuan kompen Basis Data kamu telah diterima dan dikonfirmasi oleh Dosen.',
          waktu: '15 mnt yang lalu',
          tipe: NotifTipe.sukses,
          isRead: false,
        ),
        const NotifDummy(
          judul: 'Kompen Terverifikasi',
          pesan: 'Form penyelesaian kompen Jarkom kamu telah sukses diverifikasi dan di-TTD oleh Admin.',
          waktu: '3 jam yang lalu',
          tipe: NotifTipe.sukses,
          isRead: true,
        ),
      ];

  // 3. DOSEN
  static List<NotifDummy> getDosenNotif() => [
        const NotifDummy(
          judul: 'Pengajuan Kompen Baru',
          pesan: 'Seli Permata mengajukan kompen Basis Data. Mohon tinjau berkas pengajuan.',
          waktu: 'Baru saja',
          tipe: NotifTipe.info,
          isRead: false,
        ),
        const NotifDummy(
          judul: 'Form Penyelesaian Masuk',
          pesan: 'Rina Lestari mengirim form penyelesaian kompen Jarkom Komputer II. Silakan verifikasi & TTD.',
          waktu: '5 mnt yang lalu',
          tipe: NotifTipe.peringatan,
          isRead: false,
        ),
      ];

  // 4. KAPRODI
  static List<NotifDummy> getKaprodiNotif() => [
        const NotifDummy(
          judul: 'Form Perlu Validasi Akhir',
          pesan: 'Form penyelesaian Seli Permata (Basis Data) menunggu TTD Validasi Akhir dari kamu.',
          waktu: 'Baru saja',
          tipe: NotifTipe.peringatan,
          isRead: false,
        ),
        const NotifDummy(
          judul: 'Validasi Akhir Berhasil',
          pesan: 'Form penyelesaian Budi Prasetyo telah sukses kamu tandatangani sebagai validasi akhir.',
          waktu: '1 jam yang lalu',
          tipe: NotifTipe.sukses,
          isRead: true,
        ),
      ];
}

// ── Screen Utama (Bisa dipakai rame-rame tinggal lempar rolenya)
class NotificationScreen extends StatelessWidget {
  /// Diisi: 'admin' | 'mahasiswa' | 'dosen' | 'kaprodi'
  final String role;

  const NotificationScreen({super.key, required this.role});

  static const Color _primaryRed = Color(0xFFB71C1C);
  static const Color _backgroundCream = Color(0xFFF5EFE6);
  static const Color _textDark = Color(0xFF2D2D2D);
  static const Color _textGrey = Color(0xFF9E9E9E);

  // Otomatis memilih data dummy berdasarkan parameter role yang masuk
  List<NotifDummy> get _filteredItems {
    switch (role.toLowerCase()) {
      case 'admin':
        return DummyNotifProvider.getAdminNotif();
      case 'mahasiswa':
        return DummyNotifProvider.getMahasiswaNotif();
      case 'kaprodi':
        return DummyNotifProvider.getKaprodiNotif();
      default:
        return DummyNotifProvider.getDosenNotif();
    }
  }

  @override
  Widget build(BuildContext context) {
    final listNotif = _filteredItems;

    return Scaffold(
      backgroundColor: _primaryRed,
      body: Column(
        children: [
          // SEKARANG SUDAH BERES: Melemparkan data role ke AppHeader agar tidak error merah lagi!
          AppHeader(role: role),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: _backgroundCream,
                borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifikasi (${role.toUpperCase()})',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: _textDark),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Semua notifikasi masuk simulasi sistem kompen.',
                          style: TextStyle(fontSize: 13, color: _textGrey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: listNotif.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            itemCount: listNotif.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, i) => _buildCard(listNotif[i]),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(NotifDummy item) {
    final cfg = _config(item.tipe);
    return Container(
      decoration: BoxDecoration(
        color: item.isRead ? Colors.white.withOpacity(0.85) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Garis vertikal di paling kiri kartu
            Container(width: 5, color: cfg['border'] as Color),

            // Bagian konten teks & ikon
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 14, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bulatan Ikon
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: cfg['iconBg'] as Color,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(cfg['icon'] as IconData,
                            color: cfg['iconColor'] as Color, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Teks Detail Notif
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.judul,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: item.isRead
                                          ? FontWeight.w600
                                          : FontWeight.w700,
                                      color: _textDark),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                item.waktu,
                                style: const TextStyle(
                                    fontSize: 10, color: _textGrey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.pesan,
                            style: TextStyle(
                                fontSize: 12, 
                                color: item.isRead ? _textGrey : _textDark.withOpacity(0.85), 
                                height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _config(NotifTipe tipe) {
    switch (tipe) {
      case NotifTipe.sukses:
        return {
          'border': const Color(0xFF4CAF50),
          'iconBg': const Color(0xFFE8F5E9),
          'iconColor': const Color(0xFF388E3C),
          'icon': Icons.check_circle_outline,
        };
      case NotifTipe.peringatan:
        return {
          'border': const Color(0xFFFFA000),
          'iconBg': const Color(0xFFFFF8E1),
          'iconColor': const Color(0xFFFF8F00),
          'icon': Icons.warning_amber_rounded,
        };
      case NotifTipe.info:
        return {
          'border': const Color(0xFF1976D2),
          'iconBg': const Color(0xFFE3F2FD),
          'iconColor': const Color(0xFF1565C0),
          'icon': Icons.notifications_none_outlined,
        };
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 52, color: _textGrey.withOpacity(0.4)),
          const SizedBox(height: 12),
          const Text('Belum ada notifikasi',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _textGrey)),
        ],
      ),
    );
  }
}