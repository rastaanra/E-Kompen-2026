class TtdDigital {
  final int idTtd;
  final int idPengajuan;
  final String roleTtd;   // 'dosen', 'admin', 'kaprodi'
  final String kodeTtd;   // digenerate oleh Laravel, bukan Flutter
  final String? fileTtd;
  final DateTime? waktuTtd;
  final String statusTtd; // 'belum', 'sudah'

  TtdDigital({
    required this.idTtd,
    required this.idPengajuan,
    required this.roleTtd,
    required this.kodeTtd,
    this.fileTtd,
    this.waktuTtd,
    required this.statusTtd,
  });

  factory TtdDigital.fromJson(Map<String, dynamic> json) {
    return TtdDigital(
      idTtd: json['id_ttd'],
      idPengajuan: json['id_pengajuan'],
      roleTtd: json['role_ttd'],
      kodeTtd: json['kode_ttd'],
      fileTtd: json['file_ttd'],
      waktuTtd: json['waktu_ttd'] != null
          ? DateTime.parse(json['waktu_ttd'])
          : null,
      statusTtd: json['status_ttd'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_ttd': idTtd,
      'id_pengajuan': idPengajuan,
      'role_ttd': roleTtd,
      'kode_ttd': kodeTtd,
      'file_ttd': fileTtd,
      'waktu_ttd': waktuTtd?.toIso8601String(),
      'status_ttd': statusTtd,
    };
  }
}
