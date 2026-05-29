class Admin {
  final int idAdmin;
  final int idPengguna;
  final String nama;

  Admin({
    required this.idAdmin,
    required this.idPengguna,
    required this.nama,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      idAdmin: json['id_admin'],
      idPengguna: json['id_pengguna'],
      nama: json['nama'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_admin': idAdmin,
      'id_pengguna': idPengguna,
      'nama': nama,
    };
  }
}
