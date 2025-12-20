<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\MembershipType;
use Illuminate\Http\Request;

class MembershipTypeController extends Controller
{
    // 📌 LIST ALL MEMBERSHIP TYPES
    public function index()
    {
        return response()->json([
            'success' => true,
            'types' => MembershipType::all()
        ]);
    }

    // 📌 CREATE MEMBERSHIP TYPE
    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|in:blue,gold,platinum|unique:membership_types,name',
            'display_name'     => 'required',
            'duration_months'  => 'required|integer',
            'benefits'         => 'required|array'
        ]);

        $type = MembershipType::create($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Membership type created',
            'data' => $type
        ]);
    }

    // 📌 UPDATE MEMBERSHIP TYPE
    public function update(Request $request, $id)
    {
        $type = MembershipType::find($id);

        if (!$type) {
            return response()->json(['success' => false, 'message' => 'Not found'], 404);
        }

        $request->validate([
            'display_name'     => 'required',
            'duration_months'  => 'required|integer',
            'benefits'         => 'required|array'
        ]);

        $type->update($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Membership updated',
            'data' => $type
        ]);
    }

    // 📌 DELETE MEMBERSHIP TYPE
    public function destroy($id)
    {
        $type = MembershipType::find($id);

        if (!$type) {
            return response()->json(['success' => false, 'message' => 'Not found'], 404);
        }

        $type->delete();

        return response()->json([
            'success' => true,
            'message' => 'Membership type deleted'
        ]);
    }
}
