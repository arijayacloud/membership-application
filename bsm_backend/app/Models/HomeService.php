<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class HomeService extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'member_id',
        'service_type',
        'schedule_date',
        'schedule_time',
        'address',
        'city',
        'problem_description',
        'problem_photo',
        'status',
        'work_notes',
        'completion_photo'
    ];

    public function member()
    {
        return $this->belongsTo(Member::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
