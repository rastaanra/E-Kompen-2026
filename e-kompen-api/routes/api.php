<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\API\MahasiswaController;
use Illuminate\Support\Facades\Route;

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