<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
 
class Admin extends Model {
    protected $table      = 'admin';
    protected $primaryKey = 'id_admin';
    public $timestamps    = false;
    protected $fillable   = [
        'id_pengguna', 'nama'
    ];
 
    public function pengguna() {
        return $this->belongsTo(Pengguna::class, 'id_pengguna', 'id_pengguna');
    }
 
    public function absensi() {
        return $this->hasMany(Absensi::class, 'id_admin', 'id_admin');
    }
 
    public function pengajuanKompen() {
        return $this->hasMany(PengajuanKompen::class, 'id_admin', 'id_admin');
    }
}