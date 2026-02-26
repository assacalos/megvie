<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'nom',
        'prenoms',
        'email',
        'password',
        'telephone',
        'lieu_de_residence',
        'zone_suivi',
        'description',
        'profession',
        'entreprise',
        'role',
        'famille_id', // Pour les parrains : famille à laquelle ils sont rattachés
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    /**
     * Famille à laquelle le parrain est rattaché (uniquement pour role=parrain).
     */
    public function famille()
    {
        return $this->belongsTo(User::class, 'famille_id')->where('role', 'famille');
    }

    /**
     * Parrains rattachés à cette famille (pour role=famille).
     */
    public function parrains()
    {
        return $this->hasMany(User::class, 'famille_id')->where('role', 'parrain');
    }
}

