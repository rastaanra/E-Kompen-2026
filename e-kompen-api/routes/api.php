<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\API\MahasiswaController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\DosenController;
use App\Http\Controllers\API\AbsensiController;
use App\Http\Controllers\API\PengajuanKompenController;
use App\Http\Controllers\API\TtdDigitalController;
use App\Http\Controllers\API\MataKuliahController;
// ==========================================
// TEST KONEKSI
// ==========================================
Route::get('/test', function() {
    return response()->json([
        'success' => true,
        'message' => 'API E-Kompen berjalan'
    ]);
});

// ==========================================
// AUTH
// ==========================================
Route::post('/auth/login',               [AuthController::class, 'login']);
Route::post('/auth/register',            [AuthController::class, 'register']);
Route::post('/auth/logout',              [AuthController::class, 'logout']);
Route::put('/auth/update-profile/{id}',  [AuthController::class, 'updateProfile']);

// ==========================================
// MAHASISWA (hanya admin)
// ==========================================
Route::get('/mahasiswa',                 [MahasiswaController::class, 'index']);
Route::get('/mahasiswa/cari',            [MahasiswaController::class, 'cari']);
Route::get('/mahasiswa/filter',          [MahasiswaController::class, 'filter']);
Route::get('/mahasiswa/{id}',            [MahasiswaController::class, 'show']);
Route::post('/mahasiswa',                [MahasiswaController::class, 'store']);
Route::post('/mahasiswa/import',         [MahasiswaController::class, 'import']);
Route::put('/mahasiswa/{id}',            [MahasiswaController::class, 'update']);
Route::delete('/mahasiswa/{id}',         [MahasiswaController::class, 'destroy']);
Route::get('/mahasiswa/{id}/home',       [MahasiswaController::class, 'home']);


// DOSEN
Route::get('/dosen',                  [DosenController::class, 'index']);
Route::get('/dosen/cari',             [DosenController::class, 'cari']);
Route::get('/dosen/{id}',             [DosenController::class, 'show']);
Route::post('/dosen',                 [DosenController::class, 'store']);
Route::post('/dosen/import',          [DosenController::class, 'import']);
Route::put('/dosen/{id}',             [DosenController::class, 'update']);
Route::put('/dosen/{id}/set-kaprodi', [DosenController::class, 'setKaprodi']);
Route::delete('/dosen/{id}',          [DosenController::class, 'destroy']);


// ABSENSI
Route::get('/absensi',                              [AbsensiController::class, 'index']);
Route::get('/absensi/cari',                         [AbsensiController::class, 'cari']);
Route::get('/absensi/filter',                       [AbsensiController::class, 'filter']);
Route::get('/absensi/mahasiswa/{id_mahasiswa}',     [AbsensiController::class, 'getByMahasiswa']);
Route::post('/absensi/import',                      [AbsensiController::class, 'import']);
Route::put('/absensi/{id}',                         [AbsensiController::class, 'update']);
Route::delete('/absensi/mahasiswa/{id_mahasiswa}',  [AbsensiController::class, 'destroyByMahasiswa']);


// PENGAJUAN KOMPEN
Route::get('/admin',                                    [PengajuanKompenController::class, 'getAdmin']);
Route::post('/pengajuan-kompen',                        [PengajuanKompenController::class, 'store']);
Route::get('/pengajuan-kompen/mahasiswa/{id}',          [PengajuanKompenController::class, 'getByMahasiswa']);
Route::get('/pengajuan-kompen/dosen/{id}',              [PengajuanKompenController::class, 'getByDosen']);
Route::get('/pengajuan-kompen/admin/{id}',              [PengajuanKompenController::class, 'getByAdmin']);
Route::get('/pengajuan-kompen/{id}',                    [PengajuanKompenController::class, 'show']);
Route::put('/pengajuan-kompen/{id}/lengkapi',           [PengajuanKompenController::class, 'lengkapi']);
Route::put('/pengajuan-kompen/{id}/ajukan-ttd',         [PengajuanKompenController::class, 'ajukanTTD']);
Route::put('/pengajuan-kompen/{id}/konfirmasi',         [PengajuanKompenController::class, 'konfirmasi']);


// TTD DIGITAL
Route::post('/ttd/{id_pengajuan}/ttd',          [TtdDigitalController::class, 'ttdDosenAdmin']);
Route::post('/ttd/{id_pengajuan}/ttd-kaprodi',  [TtdDigitalController::class, 'ttdKaprodi']);
Route::get('/ttd/{id_pengajuan}',               [TtdDigitalController::class, 'getByPengajuan']);

// MATA KULIAH
Route::get('/mata-kuliah/{idMahasiswa}',        [MataKuliahController::class, 'index']);