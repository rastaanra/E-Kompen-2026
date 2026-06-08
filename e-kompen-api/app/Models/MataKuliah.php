<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
 
class MataKuliah extends Model {
    protected $table      = 'mata_kuliah';
    protected $primaryKey = 'id_mata_kuliah';
    public $timestamps    = false;
    protected $fillable   = [
        'nama_matkul'
    ];
 
    public function absensi() {
        return $this->hasMany(Absensi::class, 'id_mata_kuliah', 'id_mata_kuliah');
    }

    public function pengajuanKompen()
    {
        return $this->hasMany(
            PengajuanKompen::class,
            'id_mata_kuliah',
            'id_mata_kuliah'
        );
    }
}