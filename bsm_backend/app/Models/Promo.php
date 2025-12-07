<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class Promo extends Model
{
    protected $fillable = [
        'title',
        'banner',
        'description',
        'start_date',
        'end_date',
        'is_active',
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date'   => 'date',
    ];

    // AUTO deactivate bila expired
    public function getIsExpiredAttribute()
    {
        return $this->end_date && $this->end_date < now();
    }
}
