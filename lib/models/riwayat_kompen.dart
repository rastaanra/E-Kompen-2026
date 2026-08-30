class RiwayatKompen {
  final int idRiwayat;
  final int idPengajuan;
  final String status;
  // status: 'pengajuan_dikirim', 'dikonfirmasi', 'sedang_dikerjakan',
  //         'menunggu_ttd_dosen', 'menunggu_ttd_admin',
  //         'menunggu_ttd_kaprodi', 'selesai'
  final DateTime waktuPerubahan;

  RiwayatKompen({
    required this.idRiwayat,
    required this.idPengajuan,
    required this.status,
    required this.waktuPerubahan,
  });

  factory RiwayatKompen.fromJson(Map<String, dynamic> json) {
    return RiwayatKompen(
      idRiwayat: json['id_riwayat'],
      idPengajuan: json['id_pengajuan'],
      status: json['status'],
      waktuPerubahan: DateTime.parse(json['waktu_perubahan']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_riwayat': idRiwayat,
      'id_pengajuan': idPengajuan,
      'status': status,
      'waktu_perubahan': waktuPerubahan.toIso8601String(),
    };
  }
}
