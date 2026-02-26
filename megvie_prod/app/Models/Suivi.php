<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Suivi extends Model
{
    use HasFactory;

    protected $fillable = [
        'fidele_id',
        'statut',
        'date',
        'observation',
    ];

    protected $casts = [
        'date' => 'date',
    ];

    public function fidele()
    {
        return $this->belongsTo(Fidele::class);
    }
}

