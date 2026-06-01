<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Dosen;
use Illuminate\Http\Request;
use Maatwebsite\Excel\Facades\Excel;
use App\Imports\DosenImport;

class DosenController extends Controller
{
    // ==========================================
    // GET SEMUA DOSEN
    // GET /api/dosen
    // ==========================================
    public function index()
    {
        $data = Dosen::all();
        return response()->json([
            'success' => true,
            'data'    => $data
        ]);
    }

    // ==========================================
    // GET 1 DOSEN
    // GET /api/dosen/{id}
    // ==========================================
    public function show($id)
    {
        $data = Dosen::find($id);
        if (!$data) {
            return response()->json([
                'success' => false,
                'message' => 'Dosen tidak ditemukan'
            ], 404);
        }
        return response()->json([
            'success' => true,
            'data'    => $data
        ]);
    }

    // ==========================================
    // TAMBAH DOSEN (MANUAL)
    // POST /api/dosen
    // Body: { nip, nama_lengkap }
    // ==========================================
    public function store(Request $request)
    {
        // Cek NIP sudah ada atau belum
        $nipExist = Dosen::where('nip', $request->nip)->first();
        if ($nipExist) {
            return response()->json([
                'success' => false,
                'message' => 'NIP sudah terdaftar'
            ], 400);
        }

        $data = Dosen::create([
            'nip'           => $request->nip,
            'nama_lengkap'  => $request->nama_lengkap,
            'is_kaprodi'    => false,
            'is_registered' => false
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Dosen berhasil ditambahkan',
            'data'    => $data
        ], 201);
    }

    // ==========================================
    // UPDATE DOSEN
    // PUT /api/dosen/{id}
    // Body: { nama_lengkap }
    // Note: NIP tidak bisa diubah
    // ==========================================
    public function update(Request $request, $id)
    {
        $data = Dosen::find($id);
        if (!$data) {
            return response()->json([
                'success' => false,
                'message' => 'Dosen tidak ditemukan'
            ], 404);
        }

        // NIP dan is_kaprodi tidak bisa diupdate di sini
        $data->update($request->only('nama_lengkap'));

        return response()->json([
            'success' => true,
            'message' => 'Data dosen berhasil diupdate',
            'data'    => $data
        ]);
    }

    // ==========================================
    // HAPUS DOSEN
    // DELETE /api/dosen/{id}
    // ==========================================
    public function destroy($id)
    {
        $data = Dosen::find($id);
        if (!$data) {
            return response()->json([
                'success' => false,
                'message' => 'Dosen tidak ditemukan'
            ], 404);
        }

        $data->delete();
        return response()->json([
            'success' => true,
            'message' => 'Dosen berhasil dihapus'
        ]);
    }

    // ==========================================
    // CARI DOSEN
    // GET /api/dosen/cari?keyword=xxx
    // Cari berdasarkan: nama atau NIP
    // ==========================================
    public function cari(Request $request)
    {
        $keyword = $request->keyword;

        $data = Dosen::where('nama_lengkap', 'LIKE', '%'.$keyword.'%')
            ->orWhere('nip', 'LIKE', '%'.$keyword.'%')
            ->get();

        return response()->json([
            'success' => true,
            'data'    => $data
        ]);
    }

    // ==========================================
    // SET KAPRODI
    // PUT /api/dosen/{id}/set-kaprodi
    // Note: hanya 1 kaprodi yang bisa aktif
    // ==========================================
    public function setKaprodi($id)
    {
        $dosen = Dosen::find($id);
        if (!$dosen) {
            return response()->json([
                'success' => false,
                'message' => 'Dosen tidak ditemukan'
            ], 404);
        }

        // Matikan kaprodi yang lama dulu
        Dosen::where('is_kaprodi', true)->update(['is_kaprodi' => false]);

        // Set dosen ini jadi kaprodi
        $dosen->update(['is_kaprodi' => true]);

        return response()->json([
            'success' => true,
            'message' => $dosen->nama_lengkap . ' berhasil dijadikan Kaprodi',
            'data'    => $dosen
        ]);
    }

    // ==========================================
    // IMPORT FILE EXCEL/CSV
    // POST /api/dosen/import
    // Body: form-data, key: file, value: file.xlsx/csv
    // ==========================================
    public function import(Request $request)
    {
        if (!$request->hasFile('file')) {
            return response()->json([
                'success' => false,
                'message' => 'File tidak ditemukan'
            ], 400);
        }

        $file = $request->file('file');
        $extension = $file->getClientOriginalExtension();

        if (!in_array($extension, ['xlsx', 'xls', 'csv'])) {
            return response()->json([
                'success' => false,
                'message' => 'Format file tidak valid. Gunakan xlsx, xls, atau csv'
            ], 400);
        }

        try {
            Excel::import(new DosenImport, $file);
            return response()->json([
                'success' => true,
                'message' => 'Data dosen berhasil diimport'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal import: ' . $e->getMessage()
            ], 500);
        }
    }
}