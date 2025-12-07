<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Member;
use Illuminate\Http\Request;

class MemberController extends Controller
{
    // ==================================================
    // 🔍 CEK STATUS MEMBER BERDASARKAN USER LOGIN
    // ==================================================
    public function checkMember(Request $request)
    {
        $member = Member::where('phone', $request->user()->phone)->first();

        if ($member) {
            return response()->json([
                'status' => true,
                'message' => 'User already registered as member',
                'member' => $member
            ], 200);
        }

        return response()->json([
            'status' => false,
            'message' => 'User is not a member yet'
        ], 200);
    }

    // ==================================================
    // 📝 REGISTER MEMBER (BARU SETELAH USER LOGIN)
    // ==================================================
    public function registerMember(Request $request)
    {
        $request->validate([
            'name' => 'required',
            'phone' => 'required|unique:members,phone',
            'email' => 'nullable|email|unique:members,email'
        ]);

        // Hitung nomor urut per hari
        $today = now()->format('Ymd');
        $countToday = Member::whereDate('created_at', now()->toDateString())->count() + 1;

        // Generate kode member yg rapi
        $memberCode = "MBR-" . $today . "-" . str_pad($countToday, 4, '0', STR_PAD_LEFT);

        $member = Member::create([
            'name' => $request->name,
            'phone' => $request->phone,
            'email' => $request->email,
            'member_code' => $memberCode,
            'join_date' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Member registered successfully',
            'member' => $member
        ], 200);
    }

    // ==================================================
    // 📌 LIST MEMBER (KHUSUS ADMIN)
    // ==================================================
    public function index()
    {
        $members = Member::latest()->get();

        return response()->json([
            'members' => $members
        ], 200);
    }

    // ==================================================
    // 📌 DETAIL MEMBER (ADMIN)
    // ==================================================
    public function show($id)
    {
        $member = Member::find($id);

        if (!$member) {
            return response()->json([
                'message' => 'Member not found'
            ], 404);
        }

        return response()->json([
            'member' => $member
        ], 200);
    }

    // ==================================================
    // 🔍 CEK MEMBER BERDASARKAN NOMOR HP (UNTUK USER)
    // ==================================================
    public function checkByPhone(Request $request)
    {
        $phone = $request->query('phone');

        if (!$phone) {
            return response()->json([
                "status" => false,
                "message" => "Phone is required"
            ], 422);
        }

        $member = Member::where('phone', $phone)->first();

        if ($member) {
            return response()->json([
                "status" => true,
                "member" => $member
            ], 200);
        }

        return response()->json([
            "status" => false,
            "message" => "Member not found"
        ], 404);
    }
}
