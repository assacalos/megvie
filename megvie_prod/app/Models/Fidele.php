<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Fidele extends Model
{
    use HasFactory;

    protected $fillable = [
        'nom',
        'prenoms',
        'tranche_age',
        'lieu_residence',
        'comment_connu',
        'but_visite',
        'qui_invite',
        'frequente_eglise',
        'souhaite_appartenir',
        'date_arrivee',
        'appartient_famille',
        'statut',
        'profession',
        'photo',
        'facebook',
        'contacts',
        'whatsapp',
        'instagram',
        'email',
        'parrain_id',
        'pasteur_id',
        'chef_disc_id',
        'famille_id',
        'formation',
        'annee_experience',
        'corps_metier_id',
    ];

    protected $casts = [
        'date_arrivee' => 'date',
        'souhaite_appartenir' => 'boolean',
        'appartient_famille' => 'boolean',
    ];

    public function parrain()
    {
        return $this->belongsTo(User::class, 'parrain_id')->where('role', 'parrain');
    }

    public function pasteur()
    {
        return $this->belongsTo(User::class, 'pasteur_id')->where('role', 'pasteur');
    }

    public function chefDisc()
    {
        return $this->belongsTo(User::class, 'chef_disc_id')->where('role', 'chef_disc');
    }

    public function famille()
    {
        return $this->belongsTo(User::class, 'famille_id')->where('role', 'famille');
    }

    public function corpsMetier()
    {
        return $this->belongsTo(User::class, 'corps_metier_id')->where('role', 'corps_metier');
    }

    public function suivis()
    {
        return $this->hasMany(Suivi::class);
    }

    public function actions()
    {
        return $this->hasMany(Action::class);
    }
}

