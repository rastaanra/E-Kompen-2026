<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\TtdDigital;
use App\Models\PengajuanKompen;
use App\Models\Absensi;
use App\Models\BuktiKompen;
use Illuminate\Http\Request;
use App\Models\Mahasiswa;
use App\Models\Notifikasi;
use App\Models\Dosen;


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
    public function ttdDosen($id_pengajuan)
    {
        $pengajuan = PengajuanKompen::find($id_pengajuan);
        if (!$pengajuan) {
            return response()->json([
                'success' => false,
                'message' => 'Pengajuan tidak ditemukan'
            ], 404);
        }

        // Validasi status
        if ($pengajuan->status !== 'menunggu_ttd_dosen') {
            return response()->json([
                'success' => false,
                'message' => 'Pengajuan belum siap untuk ditandatangani'
            ], 400);
        }

        // Tentukan role TTD
        $role = 'dosen';

        // Generate kode TTD Admin
        $mahasiswa = Mahasiswa::find($pengajuan->id_mahasiswa);
        if (!$mahasiswa) {
            return response()->json([
                'success' => false,
                'message' => 'Mahasiswa tidak ditemukan'
            ], 404);
        }

            Notifikasi::create([
            'id_pengajuan'  => $pengajuan->id_pengajuan,
            'id_pengguna'   => $mahasiswa->id_pengguna,
            'judul'         => 'Tanda Tangan Dosen',
            'pesan'         =>
                'Wahh! Pengajuan kompen untuk mata kuliah ' .
                $pengajuan->mataKuliah->nama_matkul .
                ' telah ditandatangani oleh Dosen. Selanjutnya pengajuan akan diteruskan ke Kaprodi untuk proses persetujuan akhir.',
            'waktu_kirim'   => now(),
            'sudah_dilihat' => 0,
        ]);


        $kode = $this->generateKodeTTD(
            $id_pengajuan,
            'dosen',
            $mahasiswa->nim
        );

        // Simpan TTD
        $ttd = TtdDigital::create([
            'id_pengajuan' => $id_pengajuan,
            'role_ttd' => 'dosen',
            'kode_ttd'     => $kode,
            'waktu_ttd'    => now(),
            'status_ttd'   => 'sudah',
        ]);

        // Update status pengajuan → menunggu TTD kaprodi
        $pengajuan->update(['status' => 'menunggu_ttd_kaprodi']);
        // Cari kaprodi
        $kaprodi = Dosen::where('is_kaprodi', 1)->first();

        if ($kaprodi) {
            Notifikasi::create([
                'id_pengajuan'  => $pengajuan->id_pengajuan,
                'id_pengguna'   => $kaprodi->id_pengguna,
                'judul'         => 'Menunggu Persetujuan Kaprodi',
                'pesan'         =>
                    'Terdapat pengajuan kompen mata kuliah ' .
                    $pengajuan->mataKuliah->nama_matkul .
                    ' dari mahasiswa ' .
                    $mahasiswa->nama_lengkap .
                    ' yang menunggu tanda tangan Kaprodi.',
                'waktu_kirim'   => now(),
                'sudah_dilihat' => 0,
            ]);
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
            Notifikasi::create([
                'id_pengajuan'  => $pengajuan->id_pengajuan,
                'id_pengguna'   => $mahasiswa->id_pengguna,
                'judul'         => 'Kompen Selesai',
                'pesan'         =>
                    'Selamat! Seluruh proses kompen untuk mata kuliah ' .
                    $pengajuan->mataKuliah->nama_matkul .
                    ' telah selesai. Bukti kompen sekarang sudah dapat digunakan sebagai arsip penyelesaian kompen Anda.',
                'waktu_kirim'   => now(),
                'sudah_dilihat' => 0,
            ]);

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