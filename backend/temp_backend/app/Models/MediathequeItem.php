<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MediathequeItem extends Model
{
    use HasFactory;

    protected $table = 'mediatheque_items';

    protected $fillable = [
        'titre',
        'type',
        'url_or_path',
        'description',
        'date_publication',
        'duree_secondes',
        'auteur',
        'serie_or_categorie',
        'created_by',
    ];

    protected $casts = [
        'date_publication' => 'date',
    ];

    public function createdBy()
    {
        return $this->belongsTo(User::class, 'created_by');
    }
}
