<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\PengajuanKompen;
use App\Models\Admin;
use Illuminate\Http\Request;

class PengajuanKompenController extends Controller
{
    // ==========================================
    // BUAT PENGAJUAN KOMPEN
    // POST /api/pengajuan-kompen
    // Untuk: Mahasiswa
    // Body: { id_mahasiswa, id_absensi, id_dosen, id_admin, tujuan, semester, tanggal_pertemuan, total_jam_kompen }
    // ==========================================
    public function store(Request $request)
    {
        $data = PengajuanKompen::create([
            'id_mahasiswa'      => $request->id_mahasiswa,
            'id_absensi'        => $request->id_absensi,
            'id_dosen'          => $request->tujuan === 'dosen' ? $request->id_dosen : null,
            'id_admin'          => $request->tujuan === 'admin' ? $request->id_admin : null,
            'tujuan'            => $request->tujuan,
            'semester'          => $request->semester,
            'tanggal_pertemuan' => $request->tanggal_pertemuan,
            'total_jam_kompen'  => $request->total_jam_kompen,
            'status'            => 'pending',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pengajuan kompen berhasil dikirim',
            'data'    => $data
        ], 201);
    }

    // ==========================================
    // GET INFO ADMIN (untuk form pengajuan)
    // GET /api/admin
    // Untuk: Mahasiswa
    // ==========================================
    public function getAdmin()
    {
        $admin = Admin::with('pengguna')->first();
        if (!$admin) {
            return response()->json([
                'success' => false,
                'message' => 'Admin tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data'    => [
                'id_admin' => $admin->id_admin,
                'nama'     => $admin->nama,
            ]
        ]);
    }

    // ==========================================
    // LIST PENGAJUAN MILIK MAHASISWA
    // GET /api/pengajuan-kompen/mahasiswa/{id_mahasiswa}
    // Untuk: Mahasiswa
    // ==========================================
    public function getByMahasiswa($id_mahasiswa)
    {
        $data = PengajuanKompen::with(['absensi.mataKuliah', 'dosen', 'admin'])
            ->where('id_mahasiswa', $id_mahasiswa)
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function ($item) {
                return [
                    'id_pengajuan'      => $item->id_pengajuan,
                    'nama_matkul'       => $item->absensi->mataKuliah->nama_matkul ?? null,
                    'nama_dosen'        => $item->dosen->nama_lengkap ?? $item->admin->nama ?? null,
                    'tujuan'            => $item->tujuan,
                    'semester'          => $item->semester,
                    'tanggal_pertemuan' => $item->tanggal_pertemuan,
                    'total_jam_kompen'  => $item->total_jam_kompen,
                    'deskripsi_tugas'   => $item->deskripsi_tugas,
                    'status'            => $item->status,
                ];
            });

        return response()->json([
            'success' => true,
            'data'    => $data
        ]);
    }

    // ==========================================
    // LIST PENGAJUAN MASUK KE DOSEN
    // GET /api/pengajuan-kompen/dosen/{id_dosen}
    // Untuk: Dosen
    // ==========================================
    public function getByDosen($id_dosen)
    {
        $data = PengajuanKompen::with(['absensi.mataKuliah', 'mahasiswa'])
            ->where('id_dosen', $id_dosen)
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function ($item) {
                return [
                    'id_pengajuan'      => $item->id_pengajuan,
                    'nama_mahasiswa'    => $item->mahasiswa->nama_lengkap ?? null,
                    'nim'               => $item->mahasiswa->nim ?? null,
                    'nama_matkul'       => $item->absensi->mataKuliah->nama_matkul ?? null,
                    'semester'          => $item->semester,
                    'tanggal_pertemuan' => $item->tanggal_pertemuan,
                    'total_jam_kompen'  => $item->total_jam_kompen,
                    'status'            => $item->status,
                ];
            });

        return response()->json([
            'success' => true,
            'data'    => $data
        ]);
    }

    // ==========================================
    // LIST PENGAJUAN MASUK KE ADMIN
    // GET /api/pengajuan-kompen/admin/{id_admin}
    // Untuk: Admin
    // ==========================================
    public function getByAdmin($id_admin)
    {
        $data = PengajuanKompen::with(['absensi.mataKuliah', 'mahasiswa'])
            ->where('id_admin', $id_admin)
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function ($item) {
                return [
                    'id_pengajuan'      => $item->id_pengajuan,
                    'nama_mahasiswa'    => $item->mahasiswa->nama_lengkap ?? null,
                    'nim'               => $item->mahasiswa->nim ?? null,
                    'nama_matkul'       => $item->absensi->mataKuliah->nama_matkul ?? null,
                    'semester'          => $item->semester,
                    'tanggal_pertemuan' => $item->tanggal_pertemuan,
                    'total_jam_kompen'  => $item->total_jam_kompen,
                    'status'            => $item->status,
                ];
            });

        return response()->json([
            'success' => true,
            'data'    => $data
        ]);
    }

    // ==========================================
    // DETAIL 1 PENGAJUAN (Berita Acara)
    // GET /api/pengajuan-kompen/{id}
    // Untuk: Dosen & Admin & Kaprodi
    // ==========================================
    public function show($id)
    {
        $item = PengajuanKompen::with([
            'absensi.mataKuliah',
            'mahasiswa',
            'dosen',
            'admin'
        ])->find($id);

        if (!$item) {
            return response()->json([
                'success' => false,
                'message' => 'Pengajuan tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data'    => [
                'id_pengajuan'      => $item->id_pengajuan,
                // Data Mahasiswa
                'nama_mahasiswa'    => $item->mahasiswa->nama_lengkap ?? null,
                'nim'               => $item->mahasiswa->nim ?? null,
                'program_studi'     => $item->mahasiswa->program_studi ?? null,
                // Data Dosen/Admin
                'nama_dosen'        => $item->dosen->nama_lengkap ?? $item->admin->nama ?? null,
                'nip_dosen'         => $item->dosen->nip ?? null,
                // Data Pengajuan
                'tujuan'            => $item->tujuan,
                'semester'          => $item->semester,
                'nama_matkul'       => $item->absensi->mataKuliah->nama_matkul ?? null,
                'tanggal_pertemuan' => $item->tanggal_pertemuan,
                'total_jam_kompen'  => $item->total_jam_kompen,
                'deskripsi_tugas'   => $item->deskripsi_tugas,
                // Data Lokasi
                'nama_lokasi'       => $item->nama_lokasi,
                'latitude'          => $item->latitude,
                'longitude'         => $item->longitude,
                // Status
                'status'            => $item->status,
            ]
        ]);
    }

    // ==========================================
    // LENGKAPI FORM KOMPEN
    // PUT /api/pengajuan-kompen/{id}/lengkapi
    // Untuk: Mahasiswa
    // Body: { deskripsi_tugas, nama_lokasi, latitude, longitude }
    // ==========================================
    public function lengkapi(Request $request, $id)
    {
        $item = PengajuanKompen::find($id);
        if (!$item) {
            return response()->json([
                'success' => false,
                'message' => 'Pengajuan tidak ditemukan'
            ], 404);
        }

        if ($item->status !== 'sedang_dikerjakan') {
            return response()->json([
                'success' => false,
                'message' => 'Pengajuan belum dikonfirmasi atau sudah tidak bisa dilengkapi'
            ], 400);
        }

        $item->update([
            'deskripsi_tugas' => $request->deskripsi_tugas,
            'nama_lokasi'     => $request->nama_lokasi,
            'latitude'        => $request->latitude,
            'longitude'       => $request->longitude,
            'status'          => 'siap_diajukan',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Form kompen berhasil dilengkapi',
            'data'    => $item
        ]);
    }

    // ==========================================
    // AJUKAN TTD
    // PUT /api/pengajuan-kompen/{id}/ajukan-ttd
    // Untuk: Mahasiswa
    // ==========================================
    public function ajukanTTD($id)
    {
        $item = PengajuanKompen::find($id);
        if (!$item) {
            return response()->json([
                'success' => false,
                'message' => 'Pengajuan tidak ditemukan'
            ], 404);
        }

        if ($item->status !== 'siap_diajukan') {
            return response()->json([
                'success' => false,
                'message' => 'Form kompen belum dilengkapi'
            ], 400);
        }

        $newStatus = $item->tujuan === 'dosen'
            ? 'menunggu_ttd_dosen'
            : 'menunggu_ttd_admin';

        $item->update(['status' => $newStatus]);

        return response()->json([
            'success' => true,
            'message' => 'Pengajuan TTD berhasil dikirim',
            'data'    => $item
        ]);
    }

    // ==========================================
    // KONFIRMASI PENGAJUAN
    // PUT /api/pengajuan-kompen/{id}/konfirmasi
    // Untuk: Admin & Dosen
    // ==========================================
    public function konfirmasi($id)
    {
        $item = PengajuanKompen::find($id);
        if (!$item) {
            return response()->json([
                'success' => false,
                'message' => 'Pengajuan tidak ditemukan'
            ], 404);
        }

        if ($item->status !== 'pending') {
            return response()->json([
                'success' => false,
                'message' => 'Pengajuan sudah dikonfirmasi sebelumnya'
            ], 400);
        }

        $item->update(['status' => 'sedang_dikerjakan']);

        return response()->json([
            'success' => true,
            'message' => 'Pengajuan berhasil dikonfirmasi',
            'data'    => $item
        ]);
    }
}
