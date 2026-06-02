class Pengguna {
  final int idPengguna;
  final String namaLengkap;
  final String email;
  final String role; // 'mahasiswa', 'dosen', 'admin', 'kaprodi'
  final String? fotoProfil;

  Pengguna({
    required this.idPengguna,
    required this.namaLengkap,
    required this.email,
    required this.role,
    this.fotoProfil,
  });

  factory Pengguna.fromJson(Map<String, dynamic> json) {
    return Pengguna(
      idPengguna: json['id_pengguna'],
      namaLengkap: json['nama_lengkap'],
      email: json['email'],
      role: json['role'],
      fotoProfil: json['foto_profil'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pengguna': idPengguna,
      'nama_lengkap': namaLengkap,
      'email': email,
      'role': role,
      'foto_profil': fotoProfil,
    };
  }
}
