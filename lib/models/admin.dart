class Admin {
  final int idAdmin;
  final String nama;

  Admin({
    required this.idAdmin,
    required this.nama,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      idAdmin: json['id_admin'],
      nama: json['nama'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_admin': idAdmin,
      'nama': nama,
    };
  }
}