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
    ];

    public function parrain()
    {
        return $this->belongsTo(Parrain::class);
    }

    public function pasteur()
    {
        return $this->belongsTo(Pasteur::class);
    }

    public function chefDisc()
    {
        return $this->belongsTo(ChefDisc::class);
    }

    public function famille()
    {
        return $this->belongsTo(Famille::class);
    }

    public function corpsMetier()
    {
        return $this->belongsTo(CorpsMetier::class);
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

