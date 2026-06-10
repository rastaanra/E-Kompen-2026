class Notifikasi {
  final int idNotifikasi;
  final int idPengajuan;
  final int idPengguna;
  final String judul;
  final String pesan;
  final DateTime waktuKirim;
  final bool sudahDilihat;

  Notifikasi({
    required this.idNotifikasi,
    required this.idPengajuan,
    required this.idPengguna,
    required this.judul,
    required this.pesan,
    required this.waktuKirim,
    required this.sudahDilihat,
  });

  factory Notifikasi.fromJson(Map<String, dynamic> json) {
    return Notifikasi(
      idNotifikasi: json['id_notifikasi'],
      idPengajuan: json['id_pengajuan'],
      idPengguna: json['id_pengguna'],
      judul: json['judul'],
      pesan: json['pesan'],
      waktuKirim: DateTime.parse(json['waktu_kirim']),
      sudahDilihat: json['sudah_dilihat'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_notifikasi': idNotifikasi,
      'id_pengajuan': idPengajuan,
      'id_pengguna': idPengguna,
      'judul': judul,
      'pesan': pesan,
      'waktu_kirim': waktuKirim.toIso8601String(),
      'sudah_dilihat': sudahDilihat,
    };
  }
}
