<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class Member extends Model
{
    use HasFactory;

    protected $table = 'members';

   protected $fillable = [
    'address',
    'city',
    'vehicle_type',
    'vehicle_brand',
    'vehicle_model',
    'vehicle_serial_number'
];

    protected $casts = [
        'join_date'  => 'date',
        'expired_at' => 'date',
    ];

    // =====================
    // RELASI BARU
    // =====================
    public function user()
{
    return $this->belongsTo(User::class);
}

    // =====================
    // RELASI LAIN
    // =====================
    public function homeServices()
    {
        return $this->hasMany(HomeService::class);
    }

    public function membership()
    {
        return $this->belongsTo(MembershipType::class, 'membership_type', 'name');
    }

    public function membershipType()
    {
        return $this->belongsTo(MembershipType::class, 'membership_type_id');
    }

    // ====================================
    // SCOPE SEARCH, ACCESSOR, ATTRIBUTE
    // ====================================
    public function scopeSearch($query, $keyword)
    {
        if (!$keyword) return $query;

        return $query->where(function ($q) use ($keyword) {
            $q->where('name', 'like', "%$keyword%")
              ->orWhere('phone', 'like', "%$keyword%")
              ->orWhere('member_code', 'like', "%$keyword%");
        });
    }

    public function getMembershipTypeLabelAttribute()
    {
        return strtoupper($this->membership_type);
    }

    public function getIsActiveAttribute()
    {
        if (!$this->expired_at) return false;
        return Carbon::now()->lte($this->expired_at);
    }
}
