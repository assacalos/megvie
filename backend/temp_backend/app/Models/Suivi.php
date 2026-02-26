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
        'nature_echange',
        'motif_echange',
        'resume_echange',
        'date',
        'observation',
        'commentaire',
    ];

    protected $casts = [
        'date' => 'date',
    ];

    public function fidele()
    {
        return $this->belongsTo(Fidele::class);
    }
}

