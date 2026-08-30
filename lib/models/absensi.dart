class Absensi {
  final int idAbsensi;
  final int idMahasiswa;
  final int idMataKuliah;
  final int idDosen;
  final int idAdmin;
  final DateTime tanggal;
  final String status; // 'alpha', 'izin', 'sakit'
  final int jmlJam;

  Absensi({
    required this.idAbsensi,
    required this.idMahasiswa,
    required this.idMataKuliah,
    required this.idDosen,
    required this.idAdmin,
    required this.tanggal,
    required this.status,
    required this.jmlJam,
  });

  factory Absensi.fromJson(Map<String, dynamic> json) {
    return Absensi(
      idAbsensi: json['id_absensi'],
      idMahasiswa: json['id_mahasiswa'],
      idMataKuliah: json['id_mata_kuliah'],
      idDosen: json['id_dosen'],
      idAdmin: json['id_admin'],
      tanggal: DateTime.parse(json['tanggal']),
      status: json['status'],
      jmlJam: json['jml_jam'],
      
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_absensi': idAbsensi,
      'id_mahasiswa': idMahasiswa,
      'id_mata_kuliah': idMataKuliah,
      'id_dosen': idDosen,
      'id_admin': idAdmin,
      'tanggal': tanggal.toIso8601String(),
      'status': status,
      'jml_jam': jmlJam,
      
    };
  }
}
