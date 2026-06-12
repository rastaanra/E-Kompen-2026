<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Notifikasi;

class NotifikasiController extends Controller
{
    public function getByPengguna($id_pengguna)
    {
        $data = Notifikasi::where('id_pengguna', $id_pengguna)
            ->orderBy('waktu_kirim', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $data
        ]);
    }

    public function lihatSemua($id_pengguna)
    {
        Notifikasi::where('id_pengguna', $id_pengguna)
            ->where('sudah_dilihat', 0)
            ->update([
                'sudah_dilihat' => 1
            ]);

        return response()->json([
            'success' => true,
            'message' => 'Semua notifikasi telah dilihat'
        ]);
    }
}