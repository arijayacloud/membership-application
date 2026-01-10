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
        $user = $request->user();

        $members = \App\Models\Member::where('user_id', $user->id)
            ->orderBy('id')
            ->get()
            ->map(function ($m) {
                return [
                    'id' => $m->id,
                    'address' => $m->address,
                    'city' => $m->city,
                    'vehicle_type' => $m->vehicle_type,
                    'vehicle_brand' => $m->vehicle_brand,
                    'vehicle_model' => $m->vehicle_model,
                    'vehicle_serial_number' => $m->vehicle_serial_number,

                    // 🔥 FIX UTAMA DI SINI
                    'member_photo_url' => $m->member_photo
                        ? url('/media/' . $m->member_photo)
                        : null,
                ];
            });

        return response()->json([
            'success' => true,
            'user' => [
                'id'    => $user->id,
                'name'  => $user->name,
                'phone' => $user->phone,
                'email' => $user->email,
            ],
            'members' => $members,
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

    // ==========================================
    // ✏️ UPDATE PROFILE USER / ADMIN
    // ==========================================
    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'name'     => 'required|string|max:255',
            'email'    => 'nullable|email|unique:users,email,' . $user->id,
            'phone'    => 'required|string|unique:users,phone,' . $user->id,
            'password' => 'nullable|min:6|confirmed',
        ]);

        $user->name  = $request->name;
        $user->email = $request->email;
        $user->phone = $request->phone;

        // jika password diisi → update
        if ($request->filled('password')) {
            $user->password = Hash::make($request->password);
        }

        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Profil berhasil diperbarui',
            'user'    => $user
        ], 200);
    }
}
