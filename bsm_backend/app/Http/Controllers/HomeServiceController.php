<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\HomeService;
use Illuminate\Http\Request;

class HomeServiceController extends Controller
{
    // ==============================
    // 🧾 LIST DATA HOME SERVICE
    // ==============================
    public function index(Request $request)
    {
        $user = $request->user();

        // Jika admin → tampilkan semua
        if ($user->role === 'admin') {
            $data = HomeService::with('member')->latest()->get();
        }
        // Jika user → hanya miliknya
        else {
            if (!$user->member) {
                return response()->json([
                    'message' => 'Anda belum menjadi member, silakan daftar member terlebih dahulu.'
                ], 403);
            }

            $data = HomeService::where('member_id', $user->member->id)->latest()->get();
        }

        return response()->json([
            'message' => 'Data retrieved successfully',
            'data' => $data
        ], 200);
    }

    // ==============================
    // 🏥 REQUEST HOME SERVICE (USER)
    // ==============================
    public function requestService(Request $request)
    {
        $request->validate([
            'service_type' => 'required|string',
            'schedule_date' => 'required|date',
            'schedule_time' => 'required',
            'address' => 'required|string',
            'note' => 'nullable|string'
        ]);

        $user = $request->user();

        // Harus member
        if (!$user->member) {
            return response()->json([
                'message' => 'Home Service hanya tersedia untuk member! Silakan daftar member terlebih dahulu.'
            ], 403);
        }

        $homeService = HomeService::create([
            'user_id' => $user->id,
            'member_id' => $user->member->id,
            'service_type' => $request->service_type,
            'schedule_date' => $request->schedule_date,
            'schedule_time' => $request->schedule_time,
            'address' => $request->address,
            'note' => $request->note,
            'status' => 'pending',
        ]);

        return response()->json([
            'message' => 'Home Service request berhasil dikirim, menunggu persetujuan admin.',
            'data' => $homeService
        ], 201);
    }

    // ==============================
    // 📄 DETAIL HOME SERVICE
    // ==============================
    public function show(Request $request, $id)
    {
        $data = HomeService::with(['member', 'user'])->findOrFail($id);

        if ($request->user()->role !== 'admin') {
            if (!$request->user()->member || $request->user()->member->id !== $data->member_id) {
                return response()->json(['message' => 'Akses ditolak'], 403);
            }
        }

        return response()->json([
            'message' => 'Detail ditemukan',
            'data' => $data
        ], 200);
    }

    // ==============================
    // 🔧 UPDATE STATUS (ADMIN)
    // ==============================
    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:pending,approved,on_progress,done,canceled'
        ]);

        if ($request->user()->role !== 'admin') {
            return response()->json(['message' => 'Hak akses hanya untuk admin'], 403);
        }

        $homeService = HomeService::findOrFail($id);
        $homeService->update(['status' => $request->status]);

        return response()->json([
            'message' => 'Status berhasil diperbarui.',
            'status_now' => $request->status,
            'data' => $homeService
        ], 200);
    }

    // ==============================
    // ❌ CANCEL BY USER
    // ==============================
    public function cancel(Request $request, $id)
    {
        $user = $request->user();
        $homeService = HomeService::findOrFail($id);

        if (!$user->member || $user->member->id !== $homeService->member_id) {
            return response()->json(['message' => 'Akses ditolak'], 403);
        }

        if ($homeService->status === 'canceled') {
            return response()->json(['message' => 'Request sudah dibatalkan sebelumnya'], 400);
        }

        if (!in_array($homeService->status, ['pending', 'approved'])) {
            return response()->json(['message' => 'Tidak dapat membatalkan request pada status ini'], 400);
        }

        $homeService->update(['status' => 'canceled']);

        return response()->json([
            'message' => 'Permintaan home service berhasil dibatalkan.',
            'data' => $homeService
        ], 200);
    }
}
