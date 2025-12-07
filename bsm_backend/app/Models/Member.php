<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Member extends Model
{
    use HasFactory;

    protected $fillable = [
        'member_code',
        'name',
        'phone',
        'email',
        'join_date',
        'status'
    ];

    public function homeServices()
    {
        return $this->hasMany(HomeService::class, 'member_code', 'member_code');
    }
}
