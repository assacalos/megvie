<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AnnonceComment extends Model
{
    protected $fillable = ['annonce_id', 'user_id', 'contenu'];

    public function annonce()
    {
        return $this->belongsTo(Annonce::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
