<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PushToken extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'fidele_id',
        'token',
        'platform',
        'device_info',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function fidele()
    {
        return $this->belongsTo(Fidele::class);
    }
}
