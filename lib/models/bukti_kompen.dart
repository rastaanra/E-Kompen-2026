class BuktiKompen {
  final int idBukti;
  final int idPengajuan;
  final String filePath;

  BuktiKompen({
    required this.idBukti,
    required this.idPengajuan,
    required this.filePath,
  });

  factory BuktiKompen.fromJson(Map<String, dynamic> json) {
    return BuktiKompen(
      idBukti: json['id_bukti'],
      idPengajuan: json['id_pengajuan'],
      filePath: json['file_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_bukti': idBukti,
      'id_pengajuan': idPengajuan,
      'file_path': filePath,
    };
  }
}
