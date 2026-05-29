<?php

namespace App\Http\Controllers;

use App\Models\Pengguna;
use App\Models\Mahasiswa;
use App\Models\Dosen;
use App\Models\Admin;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    // ==========================================
    // LOGIN
    // POST /api/auth/login
    // Body: { email, password }
    // ==========================================
    public function login(Request $request)
    {
        $user = Pengguna::where('email', $request->email)->first();

        if ($user && Hash::check($request->password, $user->password)) {

            $roleData = null;
            $role = $user->role;

            if ($user->role === 'mahasiswa') {
                $roleData = Mahasiswa::where('id_pengguna', $user->id_pengguna)->first();

            } elseif ($user->role === 'dosen') {
                $roleData = Dosen::where('id_pengguna', $user->id_pengguna)->first();

                // Cek apakah dosen ini adalah kaprodi
                if ($roleData && $roleData->is_kaprodi) {
                    $role = 'kaprodi';
                }

            } elseif ($user->role === 'admin') {
                $roleData = Admin::where('id_pengguna', $user->id_pengguna)->first();
            }

            return response()->json([
                'success'   => true,
                'data'      => $user,
                'role'      => $role,
                'role_data' => $roleData
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'Email atau password salah'
        ], 401);
    }

    // ==========================================
    // REGISTER
    // POST /api/auth/register
    // Body: { email, password, role, nim (mahasiswa) / nip (dosen) }
    // Note: nama_lengkap diambil dari tabel mahasiswa/dosen
    // ==========================================
    public function register(Request $request)
    {
        // Cek email sudah terdaftar atau belum
        $emailExist = Pengguna::where('email', $request->email)->first();
        if ($emailExist) {
            return response()->json([
                'success' => false,
                'message' => 'Email sudah terdaftar'
            ], 400);
        }

        // Validasi khusus Mahasiswa
        if ($request->role === 'mahasiswa') {
            $mahasiswa = Mahasiswa::where('nim', $request->nim)
                ->where('is_registered', false)
                ->first();

            if (!$mahasiswa) {
                return response()->json([
                    'success' => false,
                    'message' => 'NIM tidak ditemukan atau sudah terdaftar'
                ], 404);
            }

            // Buat akun pengguna, nama_lengkap dari tabel mahasiswa
            $user = Pengguna::create([
                'nama_lengkap' => $mahasiswa->nama_lengkap,
                'email'        => $request->email,
                'password'     => Hash::make($request->password),
                'role'         => 'mahasiswa',
            ]);

            // Update id_pengguna & is_registered di tabel mahasiswa
            $mahasiswa->update([
                'id_pengguna'   => $user->id_pengguna,
                'is_registered' => true
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Registrasi berhasil',
                'data'    => $user
            ], 201);
        }

        // Validasi khusus Dosen
        if ($request->role === 'dosen') {
            $dosen = Dosen::where('nip', $request->nip)
                ->where('is_registered', false)
                ->first();

            if (!$dosen) {
                return response()->json([
                    'success' => false,
                    'message' => 'NIP tidak ditemukan atau sudah terdaftar'
                ], 404);
            }

            // Buat akun pengguna, nama_lengkap dari tabel dosen
            $user = Pengguna::create([
                'nama_lengkap' => $dosen->nama_lengkap,
                'email'        => $request->email,
                'password'     => Hash::make($request->password),
                'role'         => 'dosen',
            ]);

            // Update id_pengguna & is_registered di tabel dosen
            $dosen->update([
                'id_pengguna'   => $user->id_pengguna,
                'is_registered' => true
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Registrasi berhasil',
                'data'    => $user
            ], 201);
        }

        return response()->json([
            'success' => false,
            'message' => 'Role tidak valid'
        ], 400);
    }

    // ==========================================
    // LOGOUT
    // POST /api/auth/logout
    // ==========================================
    public function logout()
    {
        return response()->json([
            'success' => true,
            'message' => 'Logout berhasil'
        ]);
    }

    // ==========================================
    // UPDATE PROFILE
    // PUT /api/auth/update-profile/{id}
    // Body: { nama_lengkap, email, foto_profil (hanya sekali) }
    // Note: password tidak bisa diupdate
    //       foto_profil tidak bisa diganti jika sudah ada
    // ==========================================
    public function updateProfile(Request $request, $id)
    {
        $user = Pengguna::find($id);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User tidak ditemukan'
            ], 404);
        }

        $data = $request->except('password');

        // Foto profil hanya bisa diupload sekali, tidak bisa diganti
        if ($user->foto_profil && isset($data['foto_profil'])) {
            unset($data['foto_profil']);
        }

        $user->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Profil berhasil diupdate',
            'data'    => $user
        ]);
    }
}
