<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class BuktiKompen extends Model {
    protected $table      = 'bukti_kompen';
    protected $primaryKey = 'id_bukti';
    public $timestamps    = false;
    protected $fillable   = [
        'id_pengajuan', 'file_path'
    ];

    public function pengajuanKompen() {
        return $this->belongsTo(PengajuanKompen::class, 'id_pengajuan', 'id_pengajuan');
    }
}