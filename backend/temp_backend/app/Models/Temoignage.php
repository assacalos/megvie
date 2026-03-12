<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Temoignage extends Model
{
    use HasFactory;

    protected $fillable = [
        'fidele_id',
        'titre',
        'contenu',
        'statut',
        'approuve_par',
        'date_approbation',
    ];

    protected $casts = [
        'date_approbation' => 'datetime',
    ];

    public function fidele()
    {
        return $this->belongsTo(Fidele::class);
    }

    public function approuvePar()
    {
        return $this->belongsTo(User::class, 'approuve_par');
    }
}
