<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CorpsMetier extends Model
{
    protected $fillable = [
        'nom',
        'description',
    ];

    public function fideles()
    {
        return $this->hasMany(Fidele::class);
    }
}

