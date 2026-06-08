<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
 
class Mahasiswa extends Model {
    protected $table      = 'mahasiswa';
    protected $primaryKey = 'id_mahasiswa';
    public $timestamps    = false;
    protected $fillable   = [
        'id_pengguna', 'nim', 'nama_lengkap', 'program_studi', 'is_registered'
    ];
 
    public function pengguna() {
        return $this->belongsTo(Pengguna::class, 'id_pengguna', 'id_pengguna');
    }
 
    public function absensi() {
        return $this->hasMany(Absensi::class, 'id_mahasiswa', 'id_mahasiswa');
    }
 
    public function pengajuanKompen() {
        return $this->hasMany(PengajuanKompen::class, 'id_mahasiswa', 'id_mahasiswa');
    }
}