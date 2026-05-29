<?php
namespace App\Http\Controllers;
use App\Models\Pengguna;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller {

    // Login
    public function login(Request $request) {
        $user = Pengguna::where('email', $request->email)->first();
        if ($user && Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => true,
                'data'    => $user,
                'role'    => $user->role
            ]);
        }
        return response()->json([
            'success' => false,
            'message' => 'Email atau password salah'
        ]);
    }

    // Register
    public function register(Request $request) {
        $user = Pengguna::create([
            'nama_lengkap' => $request->nama_lengkap,
            'email'        => $request->email,
            'password'     => Hash::make($request->password),
            'role'         => $request->role,
        ]);
        return response()->json(['success' => true, 'data' => $user]);
    }

    // Logout
    public function logout() {
        return response()->json(['success' => true]);
    }

    // Update Profil
    public function updateProfile(Request $request, $id) {
        $user = Pengguna::find($id);
        $user->update($request->all());
        return response()->json(['success' => true, 'data' => $user]);
    }
}
