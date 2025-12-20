<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Info extends Model
{
    use HasFactory;

    protected $fillable = [
        'clinic_name',
        'address',
        'phone',
        'email',
        'operational_hours',
        'about',
        'description',
        'facilities',
        'services',
        'maps_url',
        'instagram',
        'website',
    ];

    protected $casts = [
        'facilities' => 'array',
        'services'   => 'array',
    ];
}
