<?php

namespace App\Http\Controllers\API;

use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use App\Models\MataKuliah;


class MataKuliahController extends Controller
{
    public function index($idMahasiswa)
    {
        $matkul = DB::table('absensi')
            ->join(
                'mata_kuliah',
                'absensi.id_mata_kuliah',
                '=',
                'mata_kuliah.id_mata_kuliah'
            )
            ->where('absensi.id_mahasiswa', $idMahasiswa)
            ->where('absensi.status', 'alpha')
            ->select(
                'mata_kuliah.id_mata_kuliah',
                'mata_kuliah.nama_matkul'
            )
            ->distinct()
            ->get();

        return response()->json([
            'success' => true,
            'data' => $matkul
        ]);
    }
}