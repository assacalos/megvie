<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Famille extends Model
{
    use HasFactory;

    protected $fillable = [
        'nom',
        'description',
    ];

    public function fideles()
    {
        return $this->hasMany(Fidele::class);
    }
}

