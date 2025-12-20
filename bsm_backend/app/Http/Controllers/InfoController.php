<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Info;

class InfoController extends Controller
{
    // 🔹 Get info klinik (untuk Flutter user)
    public function index()
    {
        $info = Info::first();

        return response()->json([
            'status' => true,
            'message' => 'Informasi klinik',
            'data' => $info
        ]);
    }

    // 🔹 CREATE
    public function store(Request $request)
    {
        $data = $request->validate([
            'clinic_name' => 'nullable|string|max:255',
            'address' => 'nullable|string',
            'phone' => 'nullable|string|max:50',
            'email' => 'nullable|email',
            'operational_hours' => 'nullable|string',
            'about' => 'nullable|string',
            'description' => 'nullable|string',
            'facilities' => 'nullable|string',
            'services' => 'nullable|string',
            'maps_url' => 'nullable|string',
            'instagram' => 'nullable|string',
            'website' => 'nullable|string',
        ]);

        $info = Info::create($data);

        return response()->json([
            'status' => true,
            'message' => 'Info klinik berhasil ditambahkan',
            'data' => $info
        ], 201);
    }

    // 🔹 UPDATE
    public function update(Request $request, $id)
    {
        $validated = $request->validate([
            'clinic_name' => 'required|string|max:255',
            'address' => 'nullable|string',
            'phone' => 'nullable|string',
            'email' => 'nullable|email',
            'operational_hours' => 'nullable|string',
            'about' => 'nullable|string',
            'description' => 'nullable|string',
            'facilities' => 'nullable|array',
            'facilities.*' => 'string',
            'services' => 'nullable|array',
            'services.*' => 'string',
            'maps_url' => 'nullable|string',
            'instagram' => 'nullable|string',
            'website' => 'nullable|string',
        ]);

        $info = Info::findOrFail($id);
        $info->update($validated);

        return response()->json([
            'status' => true,
            'message' => 'Info klinik berhasil diperbarui',
            'data' => $info
        ]);
    }

    // 🔹 DELETE
    public function destroy($id)
    {
        $info = Info::findOrFail($id);
        $info->delete();

        return response()->json([
            'status' => true,
            'message' => 'Info klinik berhasil dihapus'
        ]);
    }
}
