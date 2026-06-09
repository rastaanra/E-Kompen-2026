class MataKuliah {
  final int idMataKuliah;
  final String namaMk;

  MataKuliah({
    required this.idMataKuliah,
    required this.namaMk,
  });

  factory MataKuliah.fromJson(Map<String, dynamic> json) {
    return MataKuliah(
      idMataKuliah: json['id_mata_kuliah'],
      namaMk: json['nama_matkul'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_mata_kuliah': idMataKuliah,
      'nama_matkul': namaMk,
    };
  }
}