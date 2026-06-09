class PengajuanKompen {
  final int idPengajuan;
  final int idMahasiswa;
  final int? idAbsensi;
  final int? idDosen;
  final int? idAdmin;
  final int idMataKuliah;
  final String tujuan;    // 'dosen' | 'admin'
  final String status;
  // Status yang valid:
  // 'pending'                → menunggu konfirmasi
  // 'sedang_dikerjakan'      → sudah dikonfirmasi, belum dilengkapi
  // 'siap_diajukan'          → data lengkap, belum ajukan TTD
  // 'menunggu_ttd_dosen'     → menunggu TTD dosen (tujuan: dosen)
  // 'menunggu_ttd_admin'     → menunggu TTD admin (tujuan: admin)
  // 'menunggu_ttd_kaprodi'   → menunggu TTD kaprodi (TTD terakhir)
  // 'selesai'                → selesai semua

  final String semester;  // '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8'
  final DateTime? tanggalPertemuan;
  final int? totalJamKompen;
  final String? deskripsiTugas;   // tambahan baru — VARCHAR(255)
  final String? namaLokasi;
  final double? latitude;
  final double? longitude;
  final String? namaTujuan;
  final String? namaMahasiswa;
  final String? nim;
  final String? namaMatkul;
  String? kodeTtdTujuan;
  String? kodeTtdKaprodi;
  final String? namaKaprodi;
  final String? nipKaprodi;


  PengajuanKompen({
    required this.idPengajuan,
    required this.idMahasiswa,
    required this.idAbsensi,
    this.idDosen,
    this.idAdmin,
    required this.idMataKuliah,
    required this.tujuan,
    required this.status,
    required this.semester,
    this.tanggalPertemuan,
    this.totalJamKompen,
    this.deskripsiTugas,
    this.namaLokasi,
    this.latitude,
    this.longitude,
    this.namaTujuan,
    this.namaMahasiswa,
    this.nim,
    this.namaMatkul,
    this.kodeTtdTujuan,
    this.kodeTtdKaprodi,
    this.namaKaprodi,
    this.nipKaprodi,
  });

  factory PengajuanKompen.fromJson(Map<String, dynamic> json) {
    print('JSON MASUK = $json');
    return PengajuanKompen(
      idPengajuan: json['id_pengajuan'],
      idMahasiswa: json['id_mahasiswa'],
      idAbsensi: json['id_absensi'],
      idDosen: json['id_dosen'],
      idAdmin: json['id_admin'],
      idMataKuliah: json['id_mata_kuliah'],
      tujuan: json['tujuan'],
      status: json['status'],
      semester: json['semester']?.toString() ?? '1',
      tanggalPertemuan: json['tanggal_pertemuan'] != null
          ? DateTime.parse(json['tanggal_pertemuan'])
          : null,
      totalJamKompen: json['total_jam_kompen'],
      deskripsiTugas: json['deskripsi_tugas'],
      namaLokasi: json['nama_lokasi'],
      latitude: json['latitude'] != null
          ? double.parse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.parse(json['longitude'].toString())
          : null,
      namaTujuan: json['nama_tujuan'],
      namaMahasiswa: json['nama_mahasiswa'],
      nim: json['nim'],
      namaMatkul: json['nama_matkul'],
      kodeTtdTujuan: json['kode_ttd_tujuan'],
      kodeTtdKaprodi: json['kode_ttd_kaprodi'],
      namaKaprodi: json['nama_kaprodi'],
      nipKaprodi: json['nip_kaprodi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pengajuan':      idPengajuan,
      'id_mahasiswa':      idMahasiswa,
      'id_absensi':        idAbsensi,
      'id_dosen':          idDosen,
      'id_admin':          idAdmin,
      'tujuan':            tujuan,
      'status':            status,
      'semester':          semester,
      'tanggal_pertemuan': tanggalPertemuan?.toIso8601String(),
      'total_jam_kompen':  totalJamKompen,
      'deskripsi_tugas':   deskripsiTugas,
      'nama_lokasi':       namaLokasi,
      'latitude':          latitude,
      'longitude':         longitude,
    };
  }

  // Helper: cek apakah data sudah lengkap untuk ajukan TTD
  bool get isLengkap =>
      deskripsiTugas != null && deskripsiTugas!.isNotEmpty &&
      namaLokasi != null && namaLokasi!.isNotEmpty &&
      latitude != null && longitude != null;

  // Helper: cek apakah sudah diajukan TTD (masuk tracking)
  bool get sudahAjukanTTD => [
    'menunggu_ttd_dosen',
    'menunggu_ttd_admin',
    'menunggu_ttd_kaprodi',
    'selesai',
  ].contains(status);

  // Helper: label UI dari status
  String get statusLabel {
    switch (status) {
      case 'pending':               return 'Menunggu Konfirmasi';
      case 'sedang_dikerjakan':     return 'Belum Lengkap';
      case 'siap_diajukan':         return 'Siap Diajukan';
      case 'menunggu_ttd_dosen':    return 'Menunggu TTD Dosen';
      case 'menunggu_ttd_admin':    return 'Menunggu TTD Admin';
      case 'menunggu_ttd_kaprodi':  return 'Menunggu TTD Kaprodi';
      case 'selesai':               return 'Selesai';
      default:                      return status;
    }
  }
}