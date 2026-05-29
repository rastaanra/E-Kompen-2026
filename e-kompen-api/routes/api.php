<?php
use App\Http\Controllers\AuthController;
use Illuminate\Support\Facades\Route;

// Test koneksi
Route::get('/test', function() {
    return response()->json([
        'success' => true,
        'message' => 'API E-Kompen berjalan'
    ]);
});

// Auth
Route::post('/auth/login',               [AuthController::class, 'login']);
Route::post('/auth/register',             [AuthController::class, 'register']);
Route::post('/auth/logout',               [AuthController::class, 'logout']);
Route::put('/auth/update-profile/{id}',  [AuthController::class, 'updateProfile']);
