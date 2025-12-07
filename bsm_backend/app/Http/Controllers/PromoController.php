<?php

namespace App\Http\Controllers;

use App\Models\Promo;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class PromoController extends Controller
{
    // ============================
    // 📌 GET ALL PROMO (USER/ADMIN)
    // ============================
    public function index()
    {
        $promos = Promo::where('is_active', true)
            ->where(function($q){
                $q->whereNull('end_date')->orWhere('end_date', '>=', now());
            })
            ->latest()
            ->get();

        return response()->json([
            'message' => 'Promo list retrieved',
            'data' => $promos
        ]);
    }

    // ============================
    // 📌 CREATE PROMO (ADMIN ONLY)
    // ============================
    public function store(Request $request)
    {
        $request->validate([
            'title'        => 'required',
            'banner'       => 'nullable|image|mimes:jpg,png,jpeg',
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
}
