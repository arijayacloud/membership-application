<?php

namespace App\Http\Controllers;

use App\Models\Promo;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class PromoController extends Controller
{
    // ============================
    // 📌 GET ALL PROMO (MEMBER + ADMIN)
    // ============================
    public function index(Request $request)
    {
        Promo::where('is_active', 1)
            ->whereNotNull('end_date')
            ->where('end_date', '<', today())
            ->update(['is_active' => 0]);

        $status = $request->query('status');
        $query = Promo::query();

        // User / guest
        if (!$request->user() || $request->user()->role === "user") {
            $query->where('is_active', 1)
                ->where(function ($q) {
                    $q->whereNull('end_date')
                        ->orWhere('end_date', '>=', today());
                });
        }

        // Filter admin
        if ($status === "expired") {
            $query->whereNotNull('end_date')
                ->where('end_date', '<', today());
        } elseif ($status === "upcoming") {
            $query->where('start_date', '>', today());
        } elseif ($status === "active") {
            $query->where('is_active', 1)
                ->where(function ($q) {
                    $q->whereNull('end_date')
                        ->orWhere('end_date', '>=', today());
                });
        }

        $promos = $query
            ->select('id', 'title', 'description', 'banner', 'is_active', 'start_date', 'end_date')
            ->orderByDesc('id')
            ->paginate(10);

        return response()->json([
            'message' => 'Promo list retrieved',
            'data' => $promos
        ]);
    }

    // ============================
    // 📌 GET DETAIL PROMO (MEMBER + ADMIN)
    // ============================
    public function show($id, Request $request)
    {
        $promo = Promo::find($id);

        if (!$promo) {
            return response()->json([
                'message' => 'Promo not found'
            ], 404);
        }

        // Member hanya bisa lihat promo aktif
        if ((!$request->user() || $request->user()->role == "user")) {
            if (
                !$promo->is_active ||
                ($promo->end_date && $promo->end_date < today())
            ) {
                return response()->json([
                    'message' => 'Promo tidak tersedia'
                ], 403);
            }
        }

        return response()->json([
            'message' => 'Promo detail retrieved',
            'data' => $promo
        ]);
    }

    // ============================
    // 📌 CREATE PROMO (ADMIN ONLY)
    // ============================
    public function store(Request $request)
    {
        $request->validate([
            'title'        => 'required',
            'banner' => 'nullable|image|max:5120',
            'description'  => 'nullable',
            'start_date'   => 'nullable|date',
            'end_date'     => 'nullable|date|after_or_equal:start_date',
        ]);

        $banner = null;
        if ($request->hasFile('banner')) {
            $banner = $request->file('banner')->store('promo', 'public');
        }

        $promo = Promo::create([
            'title'        => $request->title,
            'banner'       => $banner,
            'description'  => $request->description,
            'start_date'   => $request->start_date,
            'end_date'     => $request->end_date,
            'is_active'    => true,
        ]);

        return response()->json([
            'message' => 'Promo created successfully',
            'data' => $promo
        ], 201);
    }

    // ============================
    // 📌 UPDATE PROMO (ADMIN ONLY)
    // ============================
    public function update(Request $request, $id)
    {
        $request->validate([
            'title'        => 'required',
            'banner'       => 'nullable|image|mimes:jpg,png,jpeg',
            'description'  => 'nullable',
            'start_date'   => 'nullable|date',
            'end_date'     => 'nullable|date|after_or_equal:start_date',
            'is_active'    => 'nullable|boolean',
        ]);

        $promo = Promo::findOrFail($id);

        if ($request->hasFile('banner')) {
            if ($promo->banner) {
                Storage::disk('public')->delete($promo->banner);
            }
            $promo->banner = $request->file('banner')->store('promo', 'public');
        }

        $promo->update([
            'title'        => $request->title,
            'description'  => $request->description,
            'start_date'   => $request->start_date,
            'end_date'     => $request->end_date,
            'is_active'    => $request->is_active ?? $promo->is_active,
        ]);

        return response()->json([
            'message' => 'Promo updated successfully',
            'data' => $promo
        ]);
    }

    // ============================
    // 📌 DELETE PROMO (ADMIN ONLY)
    // ============================
    public function destroy($id)
    {
        $promo = Promo::findOrFail($id);
        if ($promo->banner) {
            Storage::disk('public')->delete($promo->banner);
        }
        $promo->delete();

        return response()->json([
            'message' => 'Promo deleted successfully'
        ]);
    }

    // ============================
    // 📌 UPDATE STATUS PROMO (ADMIN ONLY)
    // ============================
    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'is_active' => 'required|boolean',
        ]);

        $promo = Promo::findOrFail($id);
        $promo->is_active = $request->is_active;
        $promo->save();

        return response()->json([
            'message' => 'Status promo updated',
            'data' => $promo
        ]);
    }
}
