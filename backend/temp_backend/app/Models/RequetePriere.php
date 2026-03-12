<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RequetePriere extends Model
{
    use HasFactory;

    protected $table = 'requetes_priere';

    protected $fillable = [
        'fidele_id',
        'contenu',
        'statut',
        'is_anonyme',
    ];

    public function fidele()
    {
        return $this->belongsTo(Fidele::class);
    }
}
