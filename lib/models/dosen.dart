class Dosen {
  final int idDosen;
  final int? idPengguna;
  final String nip;
  final String namaLengkap;
  final bool isKaprodi;
  final bool isRegistered;

  Dosen({
    required this.idDosen,
    this.idPengguna,
    required this.nip,
    required this.namaLengkap,
    required this.isKaprodi,
    required this.isRegistered,
  });

  factory Dosen.fromJson(Map<String, dynamic> json) {
    return Dosen(
      idDosen: json['id_dosen'],
      idPengguna: json['id_pengguna'],
      nip: json['nip'],
      namaLengkap: json['nama_lengkap'],
      isKaprodi: json['is_kaprodi'] == 1 || json['is_kaprodi'] == true,
      isRegistered: json['is_registered'] == 1 || json['is_registered'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_dosen': idDosen,
      'id_pengguna': idPengguna,
      'nip': nip,
      'nama_lengkap': namaLengkap,
      'is_kaprodi': isKaprodi,
      'is_registered': isRegistered,
    };
  }
}
