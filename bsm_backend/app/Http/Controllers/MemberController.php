<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Member;
use App\Models\User;
use App\Models\MembershipType;
use Illuminate\Http\Request;
use Maatwebsite\Excel\Facades\Excel;
use Carbon\Carbon;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class MemberController extends Controller
{
    // ==================================================
    // 🔍 CEK STATUS MEMBER BERDASARKAN USER LOGIN
    // ==================================================
    public function checkMember(Request $request)
    {
        $member = Member::with(['membershipType', 'user'])
            ->where(function ($q) use ($request) {
                $q->whereHas('user', function ($u) use ($request) {
                    $u->where('phone', $request->phone);
                })
                    ->orWhere('member_code', $request->member_code);
            })
            ->first();

        if (!$member) {
            return response()->json([
                'status' => false,
                'message' => 'Member tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'status' => true,
            'member' => [
                'name'             => $member->user->name,
                'member_code'      => $member->member_code,
                'phone'            => $member->user->phone,
                'membership_type'  => $member->membershipType,
                'join_date'        => $member->join_date,
                'expired_at'       => $member->expired_at
                    ? Carbon::parse($member->expired_at)->locale('id')->translatedFormat('d F Y')
                    : null,
                'status'           => $member->status,
            ]
        ]);
    }

    public function registerMember(Request $request)
    {
        $request->validate([
            'membership_type_id' => 'required|exists:membership_types,id',
            'vehicle_type'       => 'nullable|string',
            'vehicle_brand'      => 'nullable|string',
            'vehicle_model'      => 'nullable|string',
            'vehicle_serial_number' => 'nullable|string',
            'address'            => 'nullable|string',
            'city'               => 'nullable|string',
        ]);

        $user = Auth::user();

        // 🔒 CEK: USER SUDAH JADI MEMBER
        $existingMember = Member::where('user_id', $user->id)->first();

        if ($existingMember) {
            return response()->json([
                'success' => false,
                'message' => 'Anda sudah terdaftar sebagai member'
            ], 403);
        }

        // ================================
        // LANJUT PROSES REGISTRASI
        // ================================
        $type = MembershipType::findOrFail($request->membership_type_id);

        $count = Member::count() + 1;
        $number = str_pad($count, 3, '0', STR_PAD_LEFT);
        $memberCode = "MBR-" . $number . "-" . strtoupper($type->code);

        $member = Member::create([
            'user_id'            => $user->id,
            'member_code'        => $memberCode,
            'name'               => $user->name,
            'phone'              => $user->phone,
            'email'              => $user->email,
            'membership_type_id' => $type->id,
            'join_date'          => now(),
            'expired_at'         => now()->addMonths($type->duration_months),
            'vehicle_type'          => $request->vehicle_type,
            'vehicle_brand'         => $request->vehicle_brand,
            'vehicle_model'         => $request->vehicle_model,
            'vehicle_serial_number' => $request->vehicle_serial_number,
            'address' => $request->address,
            'city'    => $request->city,
            'status'  => 'active',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Member registered successfully',
            'member'  => $member
        ]);
    }

    public function getMembershipTypes()
    {
        $types = MembershipType::select('id', 'name', 'duration_months', 'benefits')
            ->orderBy('id', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'types' => $types
        ]);
    }

    public function updateProfile(Request $request)
    {
        $user = Auth::user();
        $member = $user->member;

        if (!$member) {
            return response()->json([
                'success' => false,
                'message' => 'Member not found'
            ], 404);
        }

        // VALIDASI
        $validated = $request->validate([
            'name'   => 'required|string|max:255',
            'phone'  => 'required|string|unique:users,phone,' . $user->id,
            'email'  => 'nullable|email|unique:users,email,' . $user->id,

            'address' => 'nullable|string',
            'city'    => 'nullable|string',
            'vehicle_type'  => 'nullable|string',
            'vehicle_brand' => 'nullable|string',
            'vehicle_model' => 'nullable|string',
            'vehicle_serial_number' => 'nullable|string',
        ]);

        // ======================
        // 🔵 UPDATE USER
        // ======================
        DB::table('users')
            ->where('id', $user->id)
            ->update([
                'name'  => $validated['name'],
                'phone' => $validated['phone'],
                'email' => $validated['email'] ?? $user->email,
                'updated_at' => now(),
            ]);

        // ======================
        // 🔵 UPDATE MEMBER
        // ======================
        DB::table('members')
            ->where('id', $member->id)
            ->update([
                'address' => $validated['address'] ?? $member->address,
                'city'    => $validated['city'] ?? $member->city,
                'vehicle_type'  => $validated['vehicle_type'] ?? $member->vehicle_type,
                'vehicle_brand' => $validated['vehicle_brand'] ?? $member->vehicle_brand,
                'vehicle_model' => $validated['vehicle_model'] ?? $member->vehicle_model,
                'vehicle_serial_number' => $validated['vehicle_serial_number'] ?? $member->vehicle_serial_number,
                'updated_at' => now(),
            ]);

        // ambil ulang data terbaru
        $updatedUser   = User::find($user->id);
        $updatedMember = $updatedUser->member;

        return response()->json([
            'success' => true,
            'message' => 'Profile updated successfully',
            'user'    => $updatedUser,
            'member'  => $updatedMember
        ]);
    }

    // ==================================================
    // 📌 LIST MEMBER (ADMIN)
    // ==================================================
    public function index(Request $request)
    {
        $search = $request->query('search');

        $query = Member::with([
            'user:id,name,phone,email',
            'membershipType:id,name'
        ]);

        if ($search) {
            $query->where(function ($q) use ($search) {
                // 🔍 SEARCH DI USER
                $q->whereHas('user', function ($u) use ($search) {
                    $u->where('name', 'like', "%{$search}%")
                        ->orWhere('phone', 'like', "%{$search}%")
                        ->orWhere('email', 'like', "%{$search}%");
                })
                    // 🔍 SEARCH DI MEMBER
                    ->orWhere('member_code', 'like', "%{$search}%")
                    // 🔍 SEARCH DI MEMBERSHIP TYPE
                    ->orWhereHas('membershipType', function ($m) use ($search) {
                        $m->where('name', 'like', "%{$search}%");
                    });
            });
        }

        $members = $query->latest()->paginate(10);

        return response()->json([
            "members" => [
                "data" => $members->items(),
                "current_page" => $members->currentPage(),
                "last_page" => $members->lastPage(),
                "total" => $members->total(),
            ]
        ]);
    }

    // ==================================================
    // 📌 DETAIL MEMBER (ADMIN)
    // ==================================================
    public function show($id)
    {
        $member = Member::find($id);

        if (!$member) {
            return response()->json([
                'success' => false,
                'message' => 'Member not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'member' => $member
        ]);
    }

    // ==================================================
    // ✏️ UPDATE MEMBER
    // ==================================================
    public function update(Request $request, $id)
    {
        $member = Member::with('user')->find($id);

        if (!$member) {
            return response()->json([
                'success' => false,
                'message' => 'Member not found'
            ], 404);
        }

        $user = $member->user;

        // =========================
        // VALIDASI
        // =========================
        $request->validate([
            // USER
            'name'  => 'required|string',
            'phone' => 'required|string|unique:users,phone,' . $user->id,
            'email' => 'nullable|email|unique:users,email,' . $user->id,

            // MEMBER
            'membership_type_id' => 'nullable|exists:membership_types,id',
            'status' => 'nullable|in:active,non_active,expired,pending',

            'vehicle_type' => 'nullable|string',
            'vehicle_brand' => 'nullable|string',
            'vehicle_model' => 'nullable|string',
            'vehicle_serial_number' => 'nullable|string',
            'address' => 'nullable|string',
            'city' => 'nullable|string',
        ]);

        // =========================
        // UPDATE USER
        // =========================
        $user->update([
            'name'  => $request->name,
            'phone' => $request->phone,
            'email' => $request->email,
        ]);

        // =========================
        // UPDATE MEMBERSHIP (JIKA DIUBAH)
        // =========================
        if (
            $request->filled('membership_type_id') &&
            $request->membership_type_id != $member->membership_type_id
        ) {
            $type = MembershipType::findOrFail($request->membership_type_id);

            $count = Member::count() + 1;
            $number = str_pad($count, 3, '0', STR_PAD_LEFT);
            $memberCode = "MBR-$number-" . strtoupper($type->code);

            $member->membership_type_id = $type->id;
            $member->expired_at = now()->addMonths($type->duration_months);
            $member->member_code = $memberCode;
        }

        // =========================
        // UPDATE MEMBER
        // =========================
        $member->update([
            'status' => $request->status ?? $member->status,
            'vehicle_type' => $request->vehicle_type,
            'vehicle_brand' => $request->vehicle_brand,
            'vehicle_model' => $request->vehicle_model,
            'vehicle_serial_number' => $request->vehicle_serial_number,
            'address' => $request->address,
            'city' => $request->city,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Member updated successfully',
            'member' => $member->load('user')
        ]);
    }

    // ==================================================
    // 🗑 DELETE MEMBER
    // ==================================================
    public function destroy($id)
    {
        $member = Member::find($id);

        if (!$member) {
            return response()->json([
                'success' => false,
                'message' => 'Member not found'
            ], 404);
        }

        $member->delete();

        return response()->json([
            'success' => true,
            'message' => 'Member deleted successfully'
        ]);
    }

    // ==================================================
    // 🔍 CEK MEMBER BY PHONE (USER)
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

        return response()->json([
            "status" => $member ? true : false,
            "message" => $member ? "Member found" : "Member not found",
            "member" => $member
        ], $member ? 200 : 404);
    }

    // ==================================================
    // 📤 EXPORT EXCEL
    // ==================================================
    public function exportExcel()
    {
        $fileName = "data_member_" . now()->format("Ymd_His") . ".xlsx";

        return Excel::download(
            new \App\Exports\MemberExport,
            $fileName,
            \Maatwebsite\Excel\Excel::XLSX,
            [
                'Content-Disposition' => 'attachment; filename="' . $fileName . '"',
                'Access-Control-Expose-Headers' => 'Content-Disposition',
            ]
        );
    }
}
