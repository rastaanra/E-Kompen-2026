<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Absensi;
use App\Models\Mahasiswa;
use Illuminate\Http\Request;
use Maatwebsite\Excel\Facades\Excel;
use App\Imports\AbsensiImport;

class AbsensiController extends Controller
{
    // ==========================================
    // GET SEMUA ABSENSI (list per mahasiswa + total A, I, S)
    // GET /api/absensi
    // Untuk: Admin
    // ==========================================
    public function index()
    {
        $data = Mahasiswa::with(['absensi'])
            ->get()
            ->map(function ($mahasiswa) {
                $absensi = $mahasiswa->absensi;
                return [
                    'id_mahasiswa'  => $mahasiswa->id_mahasiswa,
                    'nim'           => $mahasiswa->nim,
                    'nama_lengkap'  => $mahasiswa->nama_lengkap,
                    'program_studi' => $mahasiswa->program_studi,
                    'total_alpha'   => $absensi->where('status', 'alpha')->sum('jml_jam'),
                    'total_izin'    => $absensi->where('status', 'izin')->sum('jml_jam'),
                    'total_sakit'   => $absensi->where('status', 'sakit')->sum('jml_jam'),
                ];
            });

        return response()->json([
            'success' => true,
            'data'    => $data
        ]);
    }

    // ==========================================
    // GET DETAIL ABSENSI PER MAHASISWA
    // GET /api/absensi/mahasiswa/{id_mahasiswa}
    // Untuk: Admin & Mahasiswa
    // ==========================================
    public function getByMahasiswa($id_mahasiswa)
    {
        $mahasiswa = Mahasiswa::find($id_mahasiswa);
        if (!$mahasiswa) {
            return response()->json([
                'success' => false,
                'message' => 'Mahasiswa tidak ditemukan'
            ], 404);
        }

        $absensi = Absensi::with(['mataKuliah', 'dosen'])
            ->where('id_mahasiswa', $id_mahasiswa)
            ->get()
            ->map(function ($item) {
                return [
                    'id_absensi'    => $item->id_absensi,
                    'nama_matkul'   => $item->mataKuliah->nama_matkul ?? null,
                    'nama_dosen'    => $item->dosen->nama_lengkap ?? null,
                    'tanggal'       => $item->tanggal,
                    'status'        => $item->status,
                    'jml_jam'       => $item->jml_jam,
                ];
            });

        return response()->json([
            'success'    => true,
            'mahasiswa'  => [
                'id_mahasiswa'  => $mahasiswa->id_mahasiswa,
                'nim'           => $mahasiswa->nim,
                'nama_lengkap'  => $mahasiswa->nama_lengkap,
                'program_studi' => $mahasiswa->program_studi,
            ],
            'data' => $absensi
        ]);
    }

    // ==========================================
    // EDIT JUMLAH JAM ABSENSI
    // PUT /api/absensi/{id}
    // Body: { jml_jam }
    // Untuk: Admin
    // ==========================================
    public function update(Request $request, $id)
    {
        $absensi = Absensi::find($id);
        if (!$absensi) {
            return response()->json([
                'success' => false,
                'message' => 'Absensi tidak ditemukan'
            ], 404);
        }

        // Hanya jml_jam yang bisa diupdate
        $absensi->update($request->only('jml_jam'));

        return response()->json([
            'success' => true,
            'message' => 'Jumlah jam absensi berhasil diupdate',
            'data'    => $absensi
        ]);
    }

    // ==========================================
    // HAPUS SEMUA ABSENSI MILIK MAHASISWA
    // DELETE /api/absensi/mahasiswa/{id_mahasiswa}
    // Untuk: Admin
    // ==========================================
    public function destroyByMahasiswa($id_mahasiswa)
    {
        $mahasiswa = Mahasiswa::find($id_mahasiswa);
        if (!$mahasiswa) {
            return response()->json([
                'success' => false,
                'message' => 'Mahasiswa tidak ditemukan'
            ], 404);
        }

        Absensi::where('id_mahasiswa', $id_mahasiswa)->delete();

        return response()->json([
            'success' => true,
            'message' => 'Semua absensi mahasiswa berhasil dihapus'
        ]);
    }

    // ==========================================
    // CARI ABSENSI (berdasarkan nama/nim mahasiswa)
    // GET /api/absensi/cari?keyword=xxx
    // Untuk: Admin
    // ==========================================
    public function cari(Request $request)
    {
        $keyword = $request->keyword;

        $data = Mahasiswa::with(['absensi'])
            ->where('nama_lengkap', 'LIKE', '%'.$keyword.'%')
            ->orWhere('nim', 'LIKE', '%'.$keyword.'%')
            ->get()
            ->map(function ($mahasiswa) {
                $absensi = $mahasiswa->absensi;
                return [
                    'id_mahasiswa'  => $mahasiswa->id_mahasiswa,
                    'nim'           => $mahasiswa->nim,
                    'nama_lengkap'  => $mahasiswa->nama_lengkap,
                    'program_studi' => $mahasiswa->program_studi,
                    'total_alpha'   => $absensi->where('status', 'alpha')->sum('jml_jam'),
                    'total_izin'    => $absensi->where('status', 'izin')->sum('jml_jam'),
                    'total_sakit'   => $absensi->where('status', 'sakit')->sum('jml_jam'),
                ];
            });

        return response()->json([
            'success' => true,
            'data'    => $data
        ]);
    }

    // ==========================================
    // FILTER ABSENSI (berdasarkan prodi & angkatan)
    // GET /api/absensi/filter?prodi=xxx&angkatan=24
    // Untuk: Admin
    // ==========================================
    public function filter(Request $request)
    {
        $query = Mahasiswa::with(['absensi']);

        if ($request->filled('prodi')) {
            $query->where('program_studi', $request->prodi);
        }

        if ($request->filled('angkatan')) {
            $query->where('nim', 'LIKE', $request->angkatan.'%');
        }

        $data = $query->get()->map(function ($mahasiswa) {
            $absensi = $mahasiswa->absensi;
            return [
                'id_mahasiswa'  => $mahasiswa->id_mahasiswa,
                'nim'           => $mahasiswa->nim,
                'nama_lengkap'  => $mahasiswa->nama_lengkap,
                'program_studi' => $mahasiswa->program_studi,
                'total_alpha'   => $absensi->where('status', 'alpha')->sum('jml_jam'),
                'total_izin'    => $absensi->where('status', 'izin')->sum('jml_jam'),
                'total_sakit'   => $absensi->where('status', 'sakit')->sum('jml_jam'),
            ];
        });

        return response()->json([
            'success' => true,
            'data'    => $data
        ]);
    }

    // ==========================================
    // IMPORT FILE ABSENSI
    // POST /api/absensi/import
    // Body: form-data, key: file, value: file.xlsx/csv
    // Untuk: Admin
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

        // Ambil id_admin dari request
        if (!$request->filled('id_admin')) {
            return response()->json([
                'success' => false,
                'message' => 'id_admin diperlukan'
            ], 400);
        }

        try {
            Excel::import(new AbsensiImport($request->id_admin), $file);
            return response()->json([
                'success' => true,
                'message' => 'Data absensi berhasil diimport'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal import: ' . $e->getMessage()
            ], 500);
        }
    }
}