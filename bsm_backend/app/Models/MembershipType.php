<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MembershipType extends Model
{
    protected $table = 'membership_types';

    protected $fillable = [
        'name',
        'display_name',
        'duration_months',
        'benefits',
    ];

    /**
     * Benefits disimpan dalam bentuk JSON
     * Maka kita cast agar otomatis menjadi array saat diambil
     */
    protected $casts = [
        'benefits' => 'array',
    ];

    /**
     * Relasi ke Member
     * Satu tipe membership bisa dimiliki banyak member
     */
    public function members()
    {
        return $this->hasMany(Member::class, 'membership_type', 'name');
    }
}
