<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class RiwayatKompen extends Model {
    protected $table      = 'riwayat_kompen';
    protected $primaryKey = 'id_riwayat';
    public $timestamps    = false;
    protected $fillable   = [
        'id_pengajuan', 'status', 'waktu_perubahan'
    ];

    public function pengajuanKompen() {
        return $this->belongsTo(PengajuanKompen::class, 'id_pengajuan', 'id_pengajuan');
    }
}