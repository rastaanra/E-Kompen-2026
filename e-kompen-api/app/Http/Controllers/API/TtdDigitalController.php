<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\TtdDigital;
use App\Models\PengajuanKompen;
use App\Models\Absensi;
use App\Models\BuktiKompen;
use Illuminate\Http\Request;
use App\Models\Mahasiswa;

class TtdDigitalController extends Controller
{
    // ==========================================
    // GENERATE KODE TTD
    // ==========================================
    private function generateKodeTTD($id_pengajuan, $role, $nim)
        {
            return strtoupper(substr($role, 0, 3)) . '-' . $nim . '-' . $id_pengajuan;
        }

    // ==========================================
    // TTD DOSEN / ADMIN
    // POST /api/ttd/{id_pengajuan}/ttd
    // Untuk: Dosen & Admin
    // ==========================================
    public function ttdDosenAdmin($id_pengajuan)
    {
        $pengajuan = PengajuanKompen::find($id_pengajuan);
        if (!$pengajuan) {
            return response()->json([
                'success' => false,
                'message' => 'Pengajuan tidak ditemukan'
            ], 404);
        }

        // Validasi status
        if (!in_array($pengajuan->status, ['menunggu_ttd_dosen', 'menunggu_ttd_admin'])) {
            return response()->json([
                'success' => false,
                'message' => 'Pengajuan belum siap untuk ditandatangani'
            ], 400);
        }

        // Tentukan role TTD
        $role = $pengajuan->tujuan === 'dosen' ? 'dosen' : 'admin';

        // Generate kode TTD Admin
        $mahasiswa = Mahasiswa::find($pengajuan->id_mahasiswa);

        if (!$mahasiswa) {
            return response()->json([
                'success' => false,
                'message' => 'Mahasiswa tidak ditemukan'
            ], 404);
        }

        $kode = $this->generateKodeTTD(
            $id_pengajuan,
            $role,
            $mahasiswa->nim
        );

        // Simpan TTD
        $ttd = TtdDigital::create([
            'id_pengajuan' => $id_pengajuan,
            'role_ttd'     => $role,
            'kode_ttd'     => $kode,
            'waktu_ttd'    => now(),
            'status_ttd'   => 'sudah',
        ]);

        // Update status pengajuan → menunggu TTD kaprodi
        $pengajuan->update(['status' => 'menunggu_ttd_kaprodi']);

        // Kurangi jam alpha di absensi
        $absensi = Absensi::find($pengajuan->id_absensi);
        if ($absensi) {
            $sisaJam = $absensi->jml_jam - $pengajuan->total_jam_kompen;
            $absensi->update(['jml_jam' => max(0, $sisaJam)]);
        }

        return response()->json([
            'success'  => true,
            'message'  => 'Tanda tangan berhasil',
            'kode_ttd' => $kode,
            'data'     => $ttd
        ]);
    }

    // ==========================================
    // TTD KAPRODI + GENERATE BUKTI KOMPEN
    // POST /api/ttd/{id_pengajuan}/ttd-kaprodi
    // Untuk: Kaprodi
    // ==========================================
    public function ttdKaprodi($id_pengajuan)
    {
        $pengajuan = PengajuanKompen::find($id_pengajuan);
        if (!$pengajuan) {
            return response()->json([
                'success' => false,
                'message' => 'Pengajuan tidak ditemukan'
            ], 404);
        }

        // Validasi status
        if ($pengajuan->status !== 'menunggu_ttd_kaprodi') {
            return response()->json([
                'success' => false,
                'message' => 'Pengajuan belum siap untuk ditandatangani kaprodi'
            ], 400);
        }

        // Generate kode TTD kaprodi
        $mahasiswa = Mahasiswa::find($pengajuan->id_mahasiswa);

        if (!$mahasiswa) {
            return response()->json([
                'success' => false,
                'message' => 'Mahasiswa tidak ditemukan'
            ], 404);
        }

        $kode = $this->generateKodeTTD(
            $id_pengajuan,
            'kaprodi',
            $mahasiswa->nim
        );

        // Simpan TTD kaprodi
        $ttd = TtdDigital::create([
            'id_pengajuan' => $id_pengajuan,
            'role_ttd'     => 'kaprodi',
            'kode_ttd'     => $kode,
            'waktu_ttd'    => now(),
            'status_ttd'   => 'sudah',
        ]);

        // Update status pengajuan → selesai
        $pengajuan->update(['status' => 'selesai']);

        // Generate bukti kompen (simpan path PDF)
        $filePath = 'bukti/bukti-kompen-' . $id_pengajuan . '.pdf';
        BuktiKompen::create([
            'id_pengajuan' => $id_pengajuan,
            'file_path'    => $filePath,
        ]);

        return response()->json([
            'success'   => true,
            'message'   => 'Tanda tangan kaprodi berhasil, kompen selesai!',
            'kode_ttd'  => $kode,
            'file_path' => $filePath,
            'data'      => $ttd
        ]);
    }

    // ==========================================
    // LIHAT TTD PER PENGAJUAN
    // GET /api/ttd/{id_pengajuan}
    // Untuk: Semua
    // ==========================================
    public function getByPengajuan($id_pengajuan)
    {
        $data = TtdDigital::where('id_pengajuan', $id_pengajuan)->get();

        return response()->json([
            'success' => true,
            'data'    => $data
        ]);
    }

    public function verifikasi($kode)
    {
        $ttd = TtdDigital::where('kode_ttd', $kode)->first();

        if (!$ttd) {
            return response()->json([
                'success' => false,
                'message' => 'Kode TTD tidak valid'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $ttd
        ]);
    }
}