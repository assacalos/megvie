<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AnnoncePartage extends Model
{
    protected $fillable = ['annonce_id', 'user_id'];

    public function annonce()
    {
        return $this->belongsTo(Annonce::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
