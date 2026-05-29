<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Absensi extends Model {
    protected $table      = 'absensi';
    protected $primaryKey = 'id_absensi';
    public $timestamps    = false;
    protected $fillable   = [
        'id_mahasiswa', 'id_mata_kuliah', 'id_dosen', 'id_admin',
        'tanggal', 'status', 'jml_jam'
    ];

    public function mahasiswa() {
        return $this->belongsTo(Mahasiswa::class, 'id_mahasiswa', 'id_mahasiswa');
    }

    public function mataKuliah() {
        return $this->belongsTo(MataKuliah::class, 'id_mata_kuliah', 'id_mata_kuliah');
    }

    public function dosen() {
        return $this->belongsTo(Dosen::class, 'id_dosen', 'id_dosen');
    }

    public function admin() {
        return $this->belongsTo(Admin::class, 'id_admin', 'id_admin');
    }

    public function pengajuanKompen() {
        return $this->hasMany(PengajuanKompen::class, 'id_absensi', 'id_absensi');
    }
}