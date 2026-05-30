<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Mahasiswa;
use Illuminate\Http\Request;
use Maatwebsite\Excel\Facades\Excel;
use App\Imports\MahasiswaImport;

class MahasiswaController extends Controller
{
    // ==========================================
    // GET SEMUA MAHASISWA
    // GET /api/mahasiswa
    // ==========================================
    public function index()
    {
        $data = Mahasiswa::all();
        return response()->json([
            'success' => true,
            'data'    => $data
        ]);
    }

    // ==========================================
    // GET 1 MAHASISWA
    // GET /api/mahasiswa/{id}
    // ==========================================
    public function show($id)
    {
        $data = Mahasiswa::find($id);
        if (!$data) {
            return response()->json([
                'success' => false,
                'message' => 'Mahasiswa tidak ditemukan'
            ], 404);
        }
        return response()->json([
            'success' => true,
            'data'    => $data
        ]);
    }

    // ==========================================
    // TAMBAH MAHASISWA (MANUAL)
    // POST /api/mahasiswa
    // Body: { nim, nama_lengkap, program_studi }
    // ==========================================
    public function store(Request $request)
    {
        // Cek NIM sudah ada atau belum
        $nimExist = Mahasiswa::where('nim', $request->nim)->first();
        if ($nimExist) {
            return response()->json([
                'success' => false,
                'message' => 'NIM sudah terdaftar'
            ], 400);
        }

        $data = Mahasiswa::create([
            'nim'           => $request->nim,
            'nama_lengkap'  => $request->nama_lengkap,
            'program_studi' => $request->program_studi,
            'is_registered' => false
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Mahasiswa berhasil ditambahkan',
            'data'    => $data
        ], 201);
    }

    // ==========================================
    // UPDATE MAHASISWA
    // PUT /api/mahasiswa/{id}
    // Body: { nama_lengkap, program_studi }
    // Note: NIM tidak bisa diubah
    // ==========================================
    public function update(Request $request, $id)
    {
        $data = Mahasiswa::find($id);
        if (!$data) {
            return response()->json([
                'success' => false,
                'message' => 'Mahasiswa tidak ditemukan'
            ], 404);
        }

        // NIM tidak bisa diupdate
        $data->update($request->except('nim'));

        return response()->json([
            'success' => true,
            'message' => 'Data mahasiswa berhasil diupdate',
            'data'    => $data
        ]);
    }

    // ==========================================
    // HAPUS MAHASISWA
    // DELETE /api/mahasiswa/{id}
    // ==========================================
    public function destroy($id)
    {
        $data = Mahasiswa::find($id);
        if (!$data) {
            return response()->json([
                'success' => false,
                'message' => 'Mahasiswa tidak ditemukan'
            ], 404);
        }

        $data->delete();
        return response()->json([
            'success' => true,
            'message' => 'Mahasiswa berhasil dihapus'
        ]);
    }

    // ==========================================
    // CARI MAHASISWA
    // GET /api/mahasiswa/cari?keyword=xxx
    // Cari berdasarkan: nama, nim, prodi
    // ==========================================
    public function cari(Request $request)
    {
        $keyword = $request->keyword;

        $data = Mahasiswa::where('nama_lengkap', 'LIKE', '%'.$keyword.'%')
            ->orWhere('nim', 'LIKE', '%'.$keyword.'%')
            ->orWhere('program_studi', 'LIKE', '%'.$keyword.'%')
            ->get();

        return response()->json([
            'success' => true,
            'data'    => $data
        ]);
    }

    // ==========================================
    // FILTER MAHASISWA
    // GET /api/mahasiswa/filter?prodi=xxx&angkatan=24
    // Bisa filter salah satu atau keduanya
    // ==========================================
    public function filter(Request $request)
    {
        $query = Mahasiswa::query();

        // Filter berdasarkan prodi
        if ($request->filled('prodi')) {
            $query->where('program_studi', $request->prodi);
        }

        // Filter berdasarkan angkatan (2 digit pertama NIM)
        if ($request->filled('angkatan')) {
            $query->where('nim', 'LIKE', $request->angkatan.'%');
        }

        $data = $query->get();

        return response()->json([
            'success' => true,
            'data'    => $data
        ]);
    }

    // ==========================================
    // IMPORT FILE EXCEL/CSV
    // POST /api/mahasiswa/import
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

        // Validasi ekstensi file
        if (!in_array($extension, ['xlsx', 'xls', 'csv'])) {
            return response()->json([
                'success' => false,
                'message' => 'Format file tidak valid. Gunakan xlsx, xls, atau csv'
            ], 400);
        }

        try {
            Excel::import(new MahasiswaImport, $file);
            return response()->json([
                'success' => true,
                'message' => 'Data mahasiswa berhasil diimport'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal import: ' . $e->getMessage()
            ], 500);
        }
    }
}