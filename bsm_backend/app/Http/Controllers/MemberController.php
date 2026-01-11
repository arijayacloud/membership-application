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
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

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

    public function myMembers(Request $request)
    {
        $user = $request->user();

        $members = Member::with([
            'user:id,name',
            'membershipType:id,name'
        ])
            ->where('user_id', $user->id)
            ->get()
            ->map(function ($m) {
                return [
                    'name' => $m->user->name ?? '-',
                    'member_code' => $m->member_code ?? '-',
                    'membership_type' => [
                        'name' => $m->membershipType->name ?? '-',
                    ],
                    'expired_at' => $m->expired_at
                        ? $m->expired_at->format('d M Y')
                        : '-',
                ];
            });

        return response()->json([
            'status' => true,
            'members' => $members,
        ]);
    }

    public function myActiveMembers(Request $request)
    {
        $user = $request->user();

        $members = Member::with(['user:id,name'])
            ->where('user_id', $user->id)
            ->where('status', 'active')
            ->get()
            ->map(function ($m) {
                return [
                    'id' => $m->id,
                    'user' => [
                        'name' => $m->user->name ?? '-',
                    ],
                    'vehicle_type' => $m->vehicle_type,
                    'vehicle_brand' => $m->vehicle_brand,
                    'vehicle_model' => $m->vehicle_model,
                    'vehicle_serial_number' => $m->vehicle_serial_number,
                    'address' => $m->address,
                    'city' => $m->city,
                    'expired_at' => optional($m->expired_at)->format('Y-m-d'),
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $members, // ⬅️ GANTI DARI 'members'
        ]);
    }

    public function registerMember(Request $request)
    {
        // =========================
        // 1️⃣ VALIDASI INPUT
        // =========================
        $request->validate([
            'membership_type_id'      => 'required|exists:membership_types,id',
            'vehicle_type'            => 'required|string',
            'vehicle_brand'           => 'required|string',
            'vehicle_model'           => 'required|string',
            'vehicle_serial_number'   => 'required|string',

            // 🔥 upload bukti (wajib)
            'member_photo' => 'required|image|mimes:jpg,jpeg,png',

            'address'                 => 'nullable|string',
            'city'                    => 'nullable|string',
        ]);

        // =========================
        // 2️⃣ AUTH USER
        // =========================
        $user = Auth::user();

        // =========================
        // 3️⃣ CEK DUPLIKASI UNIT
        // =========================
        $unitExists = Member::where('user_id', $user->id)
            ->where('vehicle_serial_number', $request->vehicle_serial_number)
            ->exists();

        if ($unitExists) {
            return response()->json([
                'success' => false,
                'message' => 'Unit kendaraan ini sudah terdaftar sebagai member'
            ], 409);
        }

        // =========================
        // 4️⃣ SIMPAN FOTO BUKTI
        // =========================
        $photoPath = $request->file('member_photo')
            ->store('member-photo', 'public');

        // =========================
        // 5️⃣ AMBIL TIPE MEMBERSHIP
        // =========================
        $type = MembershipType::findOrFail($request->membership_type_id);

        // =========================
        // 6️⃣ GENERATE MEMBER CODE
        // =========================
        $count = Member::count() + 1;
        $number = str_pad($count, 3, '0', STR_PAD_LEFT);
        $memberCode = "MBR-" . $number . "-" . strtoupper($type->code);

        $duration = (int) $type->duration_months;
        // =========================
        // 7️⃣ SIMPAN DATA MEMBER
        // =========================
        $member = Member::create([
            'user_id'               => $user->id,
            'member_code'           => $memberCode,
            'membership_type_id'    => $type->id,

            'join_date'             => now(),

            'expired_at' => Carbon::now()->addMonths($duration),


            // kendaraan
            'vehicle_type'          => $request->vehicle_type,
            'vehicle_brand'         => $request->vehicle_brand,
            'vehicle_model'         => $request->vehicle_model,
            'vehicle_serial_number' => $request->vehicle_serial_number,

            // alamat
            'address'               => $request->address,
            'city'                  => $request->city,

            // FOTO MEMBER
            'member_photo'          => $photoPath,

            'status'                => 'pending',
        ]);

        // =========================
        // 8️⃣ RESPONSE
        // =========================
        return response()->json([
            'success' => true,
            'message' => 'Pendaftaran member berhasil. Menunggu validasi admin.',
            'member'  => [
                'member_code' => $member->member_code,
                'status'      => $member->status,
            ]
        ], 201);
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

    public function updateProfile(Request $request, Member $member)
    {
        $authUser = Auth::user();

        // 🔐 CEK KEPEMILIKAN
        if ($member->user_id !== $authUser->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized member'
            ], 403);
        }

        $validated = $request->validate([
            'name'   => 'required|string|max:255',
            'phone'  => 'required|string|unique:users,phone,' . $authUser->id,
            'email'  => 'nullable|email|unique:users,email,' . $authUser->id,

            'address' => 'nullable|string',
            'city'    => 'nullable|string',
            'vehicle_type' => 'nullable|string',
            'vehicle_brand' => 'nullable|string',
            'vehicle_model' => 'nullable|string',
            'vehicle_serial_number' => 'nullable|string',
        ]);

        // ✅ AMBIL USER ELOQUENT ASLI
        $user = User::findOrFail($authUser->id);

        // ✅ SEKARANG PASTI AMAN
        $user->update([
            'name'  => $validated['name'],
            'phone' => $validated['phone'],
            'email' => $validated['email'] ?? $user->email,
        ]);

        // 📸 FOTO MEMBER
        if ($request->hasFile('member_photo')) {
            if ($member->member_photo) {
                Storage::disk('public')->delete($member->member_photo);
            }

            $member->member_photo = $request
                ->file('member_photo')
                ->store('member_photos', 'public');
        }

        // ✅ UPDATE MEMBER
        $member->update([
            'address' => $validated['address'] ?? $member->address,
            'city'    => $validated['city'] ?? $member->city,
            'vehicle_type' => $validated['vehicle_type'] ?? $member->vehicle_type,
            'vehicle_brand' => $validated['vehicle_brand'] ?? $member->vehicle_brand,
            'vehicle_model' => $validated['vehicle_model'] ?? $member->vehicle_model,
            'vehicle_serial_number' =>
            $validated['vehicle_serial_number'] ?? $member->vehicle_serial_number,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Profile updated',
            'member'  => $member->fresh('user')
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

        // ======================
        // VALIDASI
        // ======================
        $request->validate([
            // USER
            'name'  => 'required|string',
            'phone' => 'required|string|unique:users,phone,' . $user->id,
            'email' => 'nullable|email|unique:users,email,' . $user->id,

            // MEMBER
            'membership_type_id' => 'nullable|exists:membership_types,id',
            'status' => 'nullable|in:active,pending,expired,non_active',

            'vehicle_type' => 'nullable|string',
            'vehicle_brand' => 'nullable|string',
            'vehicle_model' => 'nullable|string',
            'vehicle_serial_number' => 'nullable|string',
            'address' => 'nullable|string',
            'city' => 'nullable|string',

            // 📸 FOTO MEMBER
            'member_photo' => 'nullable|image|mimes:jpg,jpeg,png,webp',
        ]);

        // ======================
        // VALIDASI DUPLIKASI UNIT
        // ======================
        if ($request->filled('vehicle_serial_number')) {
            $exists = Member::where('user_id', $user->id)
                ->where('vehicle_serial_number', $request->vehicle_serial_number)
                ->where('id', '!=', $member->id)
                ->exists();

            if ($exists) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unit kendaraan ini sudah terdaftar'
                ], 409);
            }
        }

        // ======================
        // UPDATE USER
        // ======================
        $user->update([
            'name'  => $request->name,
            'phone' => $request->phone,
            'email' => $request->email,
        ]);

        // ======================
        // UPDATE MEMBERSHIP TYPE
        // ======================
        if (
            $request->filled('membership_type_id') &&
            (int)$request->membership_type_id !== (int)$member->membership_type_id
        ) {
            $type = MembershipType::findOrFail($request->membership_type_id);

            $duration = (int) $type->duration_months;

            $member->membership_type_id = $type->id;
            $member->expired_at = now()->addMonths($duration);
        }
        // ======================
        // 📸 UPLOAD FOTO MEMBER
        // ======================
        if ($request->hasFile('member_photo')) {

            // hapus foto lama (jika ada)
            if ($member->member_photo && Storage::disk('public')->exists($member->member_photo)) {
                Storage::disk('public')->delete($member->member_photo);
            }

            $path = $request->file('member_photo')->store(
                'member_photos',
                'public'
            );

            $member->member_photo = $path;
        }

        // ======================
        // UPDATE MEMBER
        // ======================
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
            'member' => $member->load('user', 'membershipType'),
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

    public function validateMember($id)
    {
        $member = Member::findOrFail($id);

        if (!$member->member_photo) {
            return response()->json([
                'message' => 'Foto member belum ada'
            ], 422);
        }

        $member->update([
            'status' => 'active'
        ]);

        return response()->json([
            'message' => 'Member berhasil divalidasi'
        ]);
    }
}
