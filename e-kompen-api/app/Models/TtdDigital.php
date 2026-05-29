<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class TtdDigital extends Model {
    protected $table      = 'ttd_digital';
    protected $primaryKey = 'id_ttd';
    public $timestamps    = false;
    protected $fillable   = [
        'id_pengajuan', 'role_ttd', 'kode_ttd', 'file_ttd', 'waktu_ttd', 'status_ttd'
    ];

    public function pengajuanKompen() {
        return $this->belongsTo(PengajuanKompen::class, 'id_pengajuan', 'id_pengajuan');
    }
}