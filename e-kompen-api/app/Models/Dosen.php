<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
 
class Dosen extends Model {
    protected $table      = 'dosen';
    protected $primaryKey = 'id_dosen';
    public $timestamps    = false;
    protected $fillable   = [
        'id_pengguna', 'nip', 'nama_lengkap', 'is_kaprodi', 'is_registered'
    ];
 
    public function pengguna() {
        return $this->belongsTo(Pengguna::class, 'id_pengguna', 'id_pengguna');
    }
 
    public function absensi() {
        return $this->hasMany(Absensi::class, 'id_dosen', 'id_dosen');
    }
 
    public function pengajuanKompen() {
        return $this->hasMany(PengajuanKompen::class, 'id_dosen', 'id_dosen');
    }
}