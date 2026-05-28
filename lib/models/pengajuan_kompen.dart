class PengajuanKompen {
  final int idPengajuan;
  final int idMahasiswa;
  final int idAbsensi;
  final int? idDosen;
  final int? idAdmin;
  final String tujuan; // 'dosen', 'admin'
  final String status; // 'pending', 'sedang_dikerjakan', 'menunggu_ttd_dosen', dst
  final String semester;
  final DateTime? tanggalPertemuan;
  final int? totalJamKompen;
  final String? namaLokasi;
  final double? latitude;
  final double? longitude;

  PengajuanKompen({
    required this.idPengajuan,
    required this.idMahasiswa,
    required this.idAbsensi,
    this.idDosen,
    this.idAdmin,
    required this.tujuan,
    required this.status,
    required this.semester,
    this.tanggalPertemuan,
    this.totalJamKompen,
    this.namaLokasi,
    this.latitude,
    this.longitude,
  });

  factory PengajuanKompen.fromJson(Map<String, dynamic> json) {
    return PengajuanKompen(
      idPengajuan: json['id_pengajuan'],
      idMahasiswa: json['id_mahasiswa'],
      idAbsensi: json['id_absensi'],
      idDosen: json['id_dosen'],
      idAdmin: json['id_admin'],
      tujuan: json['tujuan'],
      status: json['status'],
      semester: json['semester'],
      tanggalPertemuan: json['tanggal_pertemuan'] != null
          ? DateTime.parse(json['tanggal_pertemuan'])
          : null,
      totalJamKompen: json['total_jam_kompen'],
      namaLokasi: json['nama_lokasi'],
      latitude: json['latitude'] != null
          ? double.parse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.parse(json['longitude'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pengajuan': idPengajuan,
      'id_mahasiswa': idMahasiswa,
      'id_absensi': idAbsensi,
      'id_dosen': idDosen,
      'id_admin': idAdmin,
      'tujuan': tujuan,
      'status': status,
      'semester': semester,
      'tanggal_pertemuan': tanggalPertemuan?.toIso8601String(),
      'total_jam_kompen': totalJamKompen,
      'nama_lokasi': namaLokasi,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
