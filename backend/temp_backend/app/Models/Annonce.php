<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Annonce extends Model
{
    use HasFactory;

    protected $table = 'annonces';

    protected $fillable = [
        'titre',
        'contenu',
        'type',
        'date_publication',
        'date_fin_affichage',
        'is_pinned',
        'created_by',
    ];

    protected $casts = [
        'date_publication' => 'date',
        'date_fin_affichage' => 'date',
        'is_pinned' => 'boolean',
    ];

    public function createdBy()
    {
        return $this->belongsTo(User::class, 'created_by');
    }
}
