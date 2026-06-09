class Mahasiswa {
  final int idMahasiswa;
  final int? idPengguna;
  final String nim;
  final String nama; // disesuaikan class diagram: nama bukan nama_lengkap
  final String programStudi;
  final bool isRegistered;

  Mahasiswa({
    required this.idMahasiswa,
    this.idPengguna,
    required this.nim,
    required this.nama,
    required this.programStudi,
    required this.isRegistered,
  });

  factory Mahasiswa.fromJson(Map<String, dynamic> json) {
    return Mahasiswa(
      idMahasiswa: json['id_mahasiswa'],
      idPengguna: json['id_pengguna'],
      nim: json['nim'],
      // coba 'nama' dulu, fallback ke 'nama_lengkap'
      nama: json['nama'] ?? json['nama_lengkap'] ?? '',
      programStudi: json['program_studi'] ?? '',
      isRegistered: json['is_registered'] == 1 || json['is_registered'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_mahasiswa': idMahasiswa,
      'id_pengguna': idPengguna,
      'nim': nim,
      'nama': nama,
      'program_studi': programStudi,
      'is_registered': isRegistered,
    };
  }
}
