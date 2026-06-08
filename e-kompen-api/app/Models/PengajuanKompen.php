<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class PengajuanKompen extends Model {
    protected $table      = 'pengajuan_kompen';
    protected $primaryKey = 'id_pengajuan';
    public $timestamps    = false;
    protected $fillable   = [
        'id_mahasiswa','id_mata_kuliah', 'id_absensi', 'id_dosen', 'id_admin',
        'tujuan', 'status', 'semester', 'tanggal_pertemuan',
        'total_jam_kompen','deskripsi_tugas', 'nama_lokasi', 'latitude', 'longitude'
    ];

    public function mahasiswa() {
        return $this->belongsTo(Mahasiswa::class, 'id_mahasiswa', 'id_mahasiswa');
    }

    public function mataKuliah() {
        return $this->belongsTo(MataKuliah::class, 'id_mata_kuliah', 'id_mata_kuliah');
    }

    public function absensi() {
        return $this->belongsTo(Absensi::class, 'id_absensi', 'id_absensi');
    }

    public function dosen() {
        return $this->belongsTo(Dosen::class, 'id_dosen', 'id_dosen');
    }

    public function admin() {
        return $this->belongsTo(Admin::class, 'id_admin', 'id_admin');
    }

    public function riwayatKompen() {
        return $this->hasMany(RiwayatKompen::class, 'id_pengajuan', 'id_pengajuan');
    }

    public function ttdDigital() {
        return $this->hasMany(TtdDigital::class, 'id_pengajuan', 'id_pengajuan');
    }

    public function buktiKompen() {
        return $this->hasOne(BuktiKompen::class, 'id_pengajuan', 'id_pengajuan');
    }

    public function notifikasi() {
        return $this->hasMany(Notifikasi::class, 'id_pengajuan', 'id_pengajuan');
    }
}