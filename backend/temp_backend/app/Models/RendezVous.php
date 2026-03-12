<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RendezVous extends Model
{
    use HasFactory;

    protected $table = 'rendez_vous';

    protected $fillable = [
        'fidele_id',
        'type',
        'sujet',
        'date_souhaitee',
        'heure_souhaitee',
        'statut',
        'note_fidele',
        'note_pasteur',
        'assigne_a',
        'date_effectif',
    ];

    protected $casts = [
        'date_souhaitee' => 'date',
        'date_effectif' => 'datetime',
    ];

    public function fidele()
    {
        return $this->belongsTo(Fidele::class);
    }

    public function assigneA()
    {
        return $this->belongsTo(User::class, 'assigne_a');
    }
}
