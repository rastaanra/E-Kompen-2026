<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\PengajuanKompen;
use App\Models\Admin;
use Illuminate\Http\Request;
use App\Models\Absensi;
use App\Models\TtdDigital;
use App\Models\Mahasiswa;

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
        $absensi = Absensi::where('id_mahasiswa', $request->id_mahasiswa)
            ->where('id_mata_kuliah', $request->id_mata_kuliah)
            ->where('status', 'alpha')
            ->get();

        $totalTagihan = $absensi->sum('jml_jam') * 2;

        $jamTerpakai = PengajuanKompen::where(
            'id_mahasiswa',
            $request->id_mahasiswa
        )
        ->where(
            'id_mata_kuliah',
            $request->id_mata_kuliah
        )
        ->sum('total_jam_kompen');

        $sisaJam = max($totalTagihan - $jamTerpakai, 0);

        if ($absensi->isEmpty()) {
            return response()->json([
                'success' => false,
                'message' => 'Mata kuliah tidak memiliki tagihan kompen'
            ], 400);
        }

        if ($request->total_jam_kompen > $sisaJam) {
            return response()->json([
                'success' => false,
                'message' => 'Jumlah jam melebihi sisa tagihan kompen'
            ], 400);
        }

        if ($sisaJam <= 0) {
            return response()->json([
                'success' => false,
                'message' => 'Tagihan kompen mata kuliah ini sudah selesai'
            ], 400);
        }

        if (!in_array($request->tujuan, ['dosen', 'admin'])) {
            return response()->json([
                'success' => false,
                'message' => 'Tujuan tidak valid'
            ], 400);
        }

        if ($request->tujuan === 'dosen' && !$request->id_dosen) {
            return response()->json([
                'success' => false,
                'message' => 'Dosen harus dipilih'
            ], 400);
        }

        if ($request->tujuan === 'admin' && !$request->id_admin) {
            return response()->json([
                'success' => false,
                'message' => 'Admin tidak ditemukan'
            ], 400);
        }

        if ($request->total_jam_kompen <= 0) {
            return response()->json([
                'success' => false,
                'message' => 'Jumlah jam tidak valid'
            ], 400);
        }

        if (!$request->semester) {
            return response()->json([
                'success' => false,
                'message' => 'Semester wajib diisi'
            ], 400);
        }

        if (!$request->tanggal_pertemuan) {
            return response()->json([
                'success' => false,
                'message' => 'Tanggal pertemuan wajib diisi'
            ], 400);
        }

        $data = PengajuanKompen::create([
            'id_mahasiswa'      => $request->id_mahasiswa,
            'id_mata_kuliah' => $request->id_mata_kuliah,
            'id_absensi'        => null,
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
        $data = PengajuanKompen::with(['mataKuliah', 'dosen', 'admin', 'ttdDigital'])
            ->where('id_mahasiswa', $id_mahasiswa)
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function ($item) {
            return [
                'id_pengajuan'      => $item->id_pengajuan,

                'id_mahasiswa'      => $item->id_mahasiswa,
                'id_absensi'        => $item->id_absensi,
                'id_dosen'          => $item->id_dosen,
                'id_admin'          => $item->id_admin,
                'id_mata_kuliah'    => $item->id_mata_kuliah,

                'nama_matkul'       => $item->mataKuliah->nama_matkul ?? null,
                'nama_tujuan'       => $item->dosen->nama_lengkap ?? $item->admin->nama ?? null,

                'tujuan'            => $item->tujuan,
                'semester'          => $item->semester,
                'tanggal_pertemuan' => $item->tanggal_pertemuan,
                'total_jam_kompen'  => $item->total_jam_kompen,
                'deskripsi_tugas'   => $item->deskripsi_tugas,

                'nama_lokasi'       => $item->nama_lokasi,
                'latitude'          => $item->latitude,
                'longitude'         => $item->longitude,

                'status'            => $item->status,
                'ttd_digital'       => $item->ttdDigital->map(function ($ttd) {
                    return [
                        'id_ttd'     => $ttd->id_ttd,
                        'kode_ttd'   => $ttd->kode_ttd,
                        'status_ttd' => $ttd->status_ttd,
                    ];
                }),
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
        $data = PengajuanKompen::with(['mataKuliah', 'mahasiswa', 'ttdDigital'])
            ->where('id_dosen', $id_dosen)
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function ($item) {
                return [
                    'id_pengajuan'      => $item->id_pengajuan,
                    'nama_mahasiswa'    => $item->mahasiswa->nama_lengkap ?? null,
                    'nim'               => $item->mahasiswa->nim ?? null,
                    'nama_matkul'       => $item->mataKuliah->nama_matkul ?? null,
                    'semester'          => $item->semester,
                    'tanggal_pertemuan' => $item->tanggal_pertemuan,
                    'total_jam_kompen'  => $item->total_jam_kompen,
                    'status'            => $item->status,
                    'ttd_digital'       => $item->ttdDigital->map(function ($ttd) {
                        return [
                            'id_ttd'     => $ttd->id_ttd,
                            'kode_ttd'   => $ttd->kode_ttd,
                            'status_ttd' => $ttd->status_ttd,
                        ];
                    }),
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
        $data = PengajuanKompen::with(['mataKuliah', 'mahasiswa', 'ttdDigital'])
            ->where('id_admin', $id_admin)
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function ($item) {
                return [
                    'id_pengajuan'      => $item->id_pengajuan,

                    'id_mahasiswa'      => $item->id_mahasiswa,
                    'id_absensi'        => $item->id_absensi,
                    'id_dosen'          => $item->id_dosen,
                    'id_admin'          => $item->id_admin,
                    'id_mata_kuliah'    => $item->id_mata_kuliah,

                    'nama_mahasiswa'    => $item->mahasiswa->nama_lengkap ?? null,
                    'nim'               => $item->mahasiswa->nim ?? null,
                    'nama_matkul'       => $item->mataKuliah->nama_matkul ?? null,

                    'tujuan'            => $item->tujuan,
                    'nama_tujuan'       => $item->dosen->nama_lengkap ?? $item->admin->nama ?? null,
                    'semester'          => $item->semester,
                    'tanggal_pertemuan' => $item->tanggal_pertemuan,
                    'total_jam_kompen'  => $item->total_jam_kompen,

                    'deskripsi_tugas'   => $item->deskripsi_tugas,
                    'nama_lokasi'       => $item->nama_lokasi,
                    'latitude'          => $item->latitude,
                    'longitude'         => $item->longitude,

                    'status'            => $item->status,
                    'ttd_digital'       => $item->ttdDigital->map(function ($ttd) {
                        return [
                            'id_ttd'     => $ttd->id_ttd,
                            'kode_ttd'   => $ttd->kode_ttd,
                            'status_ttd' => $ttd->status_ttd,
                        ];
                    }),
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
            'mataKuliah',
            'mahasiswa',
            'dosen',
            'admin',
            'ttdDigital'
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
                'nama_matkul'       => $item->mataKuliah->nama_matkul ?? null,
                'tanggal_pertemuan' => $item->tanggal_pertemuan,
                'total_jam_kompen'  => $item->total_jam_kompen,
                'deskripsi_tugas'   => $item->deskripsi_tugas,
                // Data Lokasi
                'nama_lokasi'       => $item->nama_lokasi,
                'latitude'          => $item->latitude,
                'longitude'         => $item->longitude,
                // Status
                'status'            => $item->status,
                // TTD Digital
                'ttd_digital'       => $item->ttdDigital->map(function ($ttd) {
                    return [
                        'id_ttd'     => $ttd->id_ttd,
                        'kode_ttd'   => $ttd->kode_ttd,
                        'status_ttd' => $ttd->status_ttd,
                    ];
                }),
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

        if (
            empty($request->deskripsi_tugas) ||
            empty($request->nama_lokasi)
        ) {
            return response()->json([
                'success' => false,
                'message' => 'Lengkapi semua data terlebih dahulu'
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

public function ttdAdmin($id)
{
    $item = PengajuanKompen::find($id);

    if (!$item) {
        return response()->json([
            'success' => false,
            'message' => 'Pengajuan tidak ditemukan'
        ], 404);
    }

    if ($item->status !== 'menunggu_ttd_admin') {
        return response()->json([
            'success' => false,
            'message' => 'Status tidak valid'
        ], 400);
    }

    // Ambil mahasiswa
    $mahasiswa = Mahasiswa::find($item->id_mahasiswa);

    if (!$mahasiswa) {
        return response()->json([
            'success' => false,
            'message' => 'Mahasiswa tidak ditemukan'
        ], 404);
    }

    // Generate kode TTD
    $kode = 'ADM-' . $mahasiswa->nim . '-' . $item->id_pengajuan;

    // Simpan TTD Digital
    $ttd = TtdDigital::create([
        'id_pengajuan' => $item->id_pengajuan,
        'role_ttd'     => 'admin',
        'kode_ttd'     => $kode,
        'waktu_ttd'    => now(),
        'status_ttd'   => 'sudah',
    ]);

    // Update status pengajuan
    $item->update([
        'status' => 'menunggu_ttd_kaprodi'
    ]);

    return response()->json([
        'success' => true,
        'message' => 'TTD Admin berhasil',
        'kode_ttd' => $kode,
        'ttd' => $ttd,
        'data' => $item
    ]);
}
}
