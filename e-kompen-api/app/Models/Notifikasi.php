<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Notifikasi extends Model {
    protected $table      = 'notifikasi';
    protected $primaryKey = 'id_notifikasi';
    public $timestamps    = false;
    protected $fillable   = [
        'id_pengajuan', 'id_pengguna', 'judul', 'pesan', 'waktu_kirim'
    ];

    public function pengajuanKompen() {
        return $this->belongsTo(PengajuanKompen::class, 'id_pengajuan', 'id_pengajuan');
    }

    public function pengguna() {
        return $this->belongsTo(Pengguna::class, 'id_pengguna', 'id_pengguna');
    }
}