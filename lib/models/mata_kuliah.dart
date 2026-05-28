class MataKuliah {
  final int idMataKuliah;
  final String namaMk;   // disesuaikan class diagram: nama_mk

  MataKuliah({
    required this.idMataKuliah,
    required this.namaMk,

  });

  factory MataKuliah.fromJson(Map<String, dynamic> json) {
    return MataKuliah(
      idMataKuliah: json['id_mata_kuliah'],
      namaMk: json['nama_mk'],
      
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_mata_kuliah': idMataKuliah,
      'nama_mk': namaMk,
      
    };
  }
}
