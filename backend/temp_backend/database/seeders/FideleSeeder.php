<?php

namespace Database\Seeders;

use App\Models\Fidele;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class FideleSeeder extends Seeder
{
    public function run(): void
    {
        if (User::where('email', 'fidele@megvie.org')->exists()) {
            $this->command->info('Utilisateur fidèle (fidele@megvie.org) déjà présent. Rien à faire.');
            return;
        }

        $parrain = User::where('email', 'parrain@megvie.org')->first();
        $famille = User::where('email', 'fevrier@megvie.org')->first();
        $pasteur = User::where('email', 'pasteur@megvie.org')->first();

        $fidele = Fidele::create([
            'nom' => 'Dupont',
            'prenoms' => 'Jean Marie',
            'tranche_age' => '25-35',
            'lieu_residence' => 'Lomé',
            'statut' => 'fidele',
            'profession' => 'Enseignant',
            'contacts' => '+228 90 12 34 56',
            'whatsapp' => '+228 90 12 34 56',
            'email' => 'jean.dupont@megvie.org',
            'souhaite_appartenir' => true,
            'date_arrivee' => '2024-01-15',
            'baptise_eau' => true,
            'baptise_saint_esprit' => true,
            'parrain_id' => $parrain?->id,
            'famille_id' => $famille?->id,
            'pasteur_id' => $pasteur?->id,
        ]);

        User::create([
            'name' => 'Jean Marie Dupont',
            'nom' => 'Dupont',
            'prenoms' => 'Jean Marie',
            'email' => 'fidele@megvie.org',
            'password' => Hash::make('password'),
            'role' => 'fidele',
            'fidele_id' => $fidele->id,
        ]);

        $this->command->info('Fidèle de test créé. Connexion : fidele@megvie.org / password');
    }
}
