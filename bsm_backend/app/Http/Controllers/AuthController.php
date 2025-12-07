<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class AuthController extends Controller
{
    // ==========================================
    // 🔐 REGISTER USER / ADMIN
    // ==========================================
    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required',
            'phone' => 'required|unique:users,phone',
            'email' => 'nullable|email|unique:users,email',
            'password' => 'required|min:6',
            'role' => 'required|in:user,admin',
            'admin_secret' => 'nullable'
        ]);

        // Validasi Admin jika memilih role admin
        if ($request->role === 'admin') {
            if ($request->admin_secret !== env('ADMIN_SECRET')) {
                return response()->json([
                    'message' => 'Invalid admin secret key!'
                ], 403);
            }
        }

        $user = User::create([
            'name' => $request->name,
            'phone' => $request->phone,
            'email' => $request->email,
            'role' => $request->role,
            'password' => Hash::make($request->password),
        ]);

        return response()->json([
            'message' => 'Register successfully',
            'user' => $user,
        ], 200);
    }

    // ==========================================
    // 🔑 LOGIN USER / ADMIN
    // ==========================================
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required'
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Invalid Credentials'
            ], 401);
        }

        // Generate Sanctum Token
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Login successful',
            'token' => $token,
            'role' => $user->role,
            'user' => $user
        ], 200);
    }

    // ==========================================
    // 🚪 LOGOUT
    // ==========================================
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logged out successfully'
        ]);
    }

    // ==========================================
    // 👤 USER PROFILE (OPSIONAL)
    // ==========================================
    public function profile(Request $request)
    {
        return response()->json([
            'user' => $request->user()
        ], 200);
    }

    // ==========================================
    // 🔄 REFRESH TOKEN (OPSIONAL)
    // ==========================================
    public function refresh(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        $newToken = $request->user()->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Token refreshed',
            'token' => $newToken
        ], 200);
    }
}
