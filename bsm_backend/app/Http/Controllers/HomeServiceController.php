<?php

namespace App\Http\Controllers;

use App\Models\HomeService;
use App\Models\User;
use App\Models\Member;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Auth;

class HomeServiceController extends Controller
{
    // ======================================================
    // 📌 LIST DATA — ADMIN (SEARCH + FILTER STATUS)
    // ======================================================
    public function index(Request $request)
    {
        $search = $request->query('search');
        $status = $request->query('status');

        $query = HomeService::with([
            'user:id,name,phone,email',
            'member:id,vehicle_type,vehicle_brand,vehicle_model,vehicle_serial_number'
        ])->latest();

        // =========================
        // SEARCH (ADMIN)
        // =========================
        if ($search) {
            $query->where(function ($q) use ($search) {
                $q->where('service_type', 'like', "%$search%")
                    ->orWhere('address', 'like', "%$search%")
                    ->orWhereHas('user', function ($u) use ($search) {
                        $u->where('name', 'like', "%$search%")
                            ->orWhere('phone', 'like', "%$search%");
                    })
                    ->orWhereHas('member', function ($m) use ($search) {
                        $m->where('vehicle_type', 'like', "%$search%")
                            ->orWhere('vehicle_brand', 'like', "%$search%")
                            ->orWhere('vehicle_model', 'like', "%$search%");
                    });
            });
        }

        // =========================
        // FILTER STATUS
        // =========================
        if ($status) {
            $query->where('status', $status);
        }

        $data = $query->paginate(10);

        return response()->json([
            "success" => true,
            "home_service" => $data
        ]);
    }

    public function store(Request $request)
    {
        // ===============================
        // 🔐 AUTH CHECK
        // ===============================
        $user = $request->user();
        if (!$user) {
            return response()->json([
                "success" => false,
                "message" => "Unauthenticated"
            ], 401);
        }

        // ===============================
        // 🔒 CEK MEMBER
        // ===============================
        $member = $user->members()
            ->where('id', $request->member_id)
            ->first();
        if (!$member) {
            return response()->json([
                "success" => false,
                "message" => "Member tidak valid atau bukan milik Anda"
            ], 403);
        }

        // ===============================
        // 🚫 CEK HOME SERVICE AKTIF
        // ===============================
        $hasActive = HomeService::where('member_id', $member->id)
            ->whereIn('status', ['pending', 'approved', 'on_process'])
            ->exists();

        if ($hasActive) {
            return response()->json([
                "success" => false,
                "message" => "Anda masih memiliki Home Service yang aktif"
            ], 409);
        }
        // ===============================
        // ✅ VALIDASI INPUT
        // ===============================
        $validated = $request->validate([
            'member_id'           => 'required|exists:members,id',
            'service_type'        => 'required|string',
            'schedule_date'       => 'required|date',
            'schedule_time'       => 'required|date_format:H:i',
            'address'             => 'nullable|string',
            'city'                => 'nullable|string',
            'problem_description' => 'nullable|string',
            'problem_photo'       => 'nullable|image|mimes:jpeg,png,jpg,gif|max:5120',
        ]);

        // ===============================
        // 📸 UPLOAD FOTO (OPSIONAL)
        // ===============================
        $problemPhotoPath = null;
        $problemPhotoUrl = null;

        if ($request->hasFile('problem_photo')) {
            $problemPhotoPath = $request->file('problem_photo')
                ->store('problem_photos', 'public');

            $problemPhotoUrl = asset('storage/' . $problemPhotoPath);
        }

        // ===============================
        // 📍 ALAMAT FINAL
        // ===============================
        $finalAddress = $validated['address'] ?? $member->address;
        $finalCity    = $validated['city'] ?? $member->city;

        // ===============================
        // 💾 SIMPAN HOME SERVICE
        // ===============================
        $homeService = HomeService::create([
            'user_id'             => $user->id,
            'member_id'           => $member->id,
            'service_type'        => $validated['service_type'],
            'schedule_date'       => $validated['schedule_date'],
            'schedule_time'       => $validated['schedule_time'],
            'address'             => $finalAddress,
            'city'                => $finalCity,
            'problem_description' => $validated['problem_description'] ?? null,
            'problem_photo'       => $problemPhotoPath,
            'status'              => 'pending',
        ]);

        // ===============================
        // ✅ RESPONSE
        // ===============================
        return response()->json([
            "success" => true,
            "message" => "Home service request created successfully",
            "data"    => $homeService,
            "photo_url" => $problemPhotoUrl,
        ], 201);
    }

    // ======================================================
    // 📌 DETAIL — USER & ADMIN
    // ======================================================
    public function show($id)
    {
        $service = HomeService::with(['user', 'member'])
            ->find($id);

        if (!$service) {
            return response()->json([
                "success" => false,
                "message" => "Home service not found"
            ], 404);
        }

        return response()->json([
            "success" => true,
            "data" => $service
        ]);
    }

    // ======================================================
    // 📌 ADMIN UPDATE STATUS (pending → approved → on_progress → done)
    // ======================================================
    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:pending,approved,on_process,done,canceled'
        ]);

        $service = HomeService::find($id);

        if (!$service) {
            return response()->json([
                "success" => false,
                "message" => "Home service not found"
            ], 404);
        }

        $service->update([
            'status' => $request->status
        ]);

        return response()->json([
            "success" => true,
            "message" => "Status updated",
            "data" => $service->load(['user', 'member'])
        ]);
    }

    // ======================================================
    // 📌 ADMIN MENYELESAIKAN PENGERJAAN
    // ======================================================
    public function finishWork(Request $request, $id)
    {
        $request->validate([
            'work_notes' => 'required|string',
            'completion_photo' => 'nullable|image|max:2048'
        ]);

        $service = HomeService::find($id);

        if (!$service) {
            return response()->json([
                "success" => false,
                "message" => "Data not found"
            ], 404);
        }

        if ($service->status === 'done') {
            return response()->json([
                "success" => false,
                "message" => "Work already completed"
            ], 400);
        }

        $photoPath = $service->completion_photo;

        if ($request->hasFile('completion_photo')) {
            $photoPath = $request->file('completion_photo')
                ->store('completion_photos', 'public');
        }

        $service->update([
            'work_notes' => $request->work_notes,
            'completion_photo' => $photoPath,
            'status' => 'done',
            'completed_at' => now(),
        ]);

        return response()->json([
            "success" => true,
            "message" => "Work completed successfully",
            "data" => $service->load(['user', 'member'])
        ]);
    }


    // ======================================================
    // 🗑 DELETE — ADMIN
    // ======================================================
    public function destroy($id)
    {
        $service = HomeService::find($id);

        if (!$service) {
            return response()->json([
                "success" => false,
                "message" => "Home service not found"
            ], 404);
        }

        $service->delete();

        return response()->json([
            "success" => true,
            "message" => "Home service deleted"
        ]);
    }

    public function profile(Request $request)
    {
        $user = $request->user();

        // Ambil data member
        $member = Member::where('user_id', $user->id)->first();

        // Jika bukan member
        if (!$member) {
            return response()->json([
                "success" => false,
                "data" => null,
                "message" => "Anda belum menjadi member",
            ], 200);
        }

        return response()->json([
            "success" => true,
            "data" => [
                "name"                   => $user->name,
                "phone"                  => $user->phone,
                "email"                  => $user->email,

                "address"                => $member->address,
                "city"                   => $member->city,
                "vehicle_type"           => $member->vehicle_type,
                "vehicle_brand"          => $member->vehicle_brand,
                "vehicle_model"          => $member->vehicle_model,
                "vehicle_serial_number"  => $member->vehicle_serial_number,
            ]
        ], 200);
    }

    public function myRequests(Request $request)
{
    $user = $request->user();

    $memberIds = $user->members()->pluck('id');

    if ($memberIds->isEmpty()) {
        return response()->json([
            "success" => true,
            "message" => "User belum memiliki member",
            "data" => []
        ]);
    }

    $requests = HomeService::with([
        'member:id,user_id,member_code,vehicle_type',
        'member.user:id,name'
    ])
    ->whereIn('member_id', $memberIds)
    ->orderBy('created_at', 'desc')
    ->get();

    return response()->json([
        "success" => true,
        "message" => "My Home Service Requests",
        "data" => $requests
    ]);
}

    // ======================================================
    // 📌 CEK HOME SERVICE AKTIF USER
    // ======================================================
    public function active(Request $request)
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                "success" => false,
                "message" => "Unauthenticated"
            ], 401);
        }

        $activeService = HomeService::where('user_id', $user->id)
            ->whereIn('status', [
                'pending',
                'approved',
                'on_process'
            ])
            ->latest()
            ->first();

        if ($activeService) {
            return response()->json([
                "success" => true,
                "has_active" => true,
                "message" => "Anda masih memiliki Home Service yang aktif",
                "data" => $activeService
            ]);
        }

        return response()->json([
            "success" => true,
            "has_active" => false,
            "message" => "Tidak ada Home Service aktif"
        ]);
    }
}
