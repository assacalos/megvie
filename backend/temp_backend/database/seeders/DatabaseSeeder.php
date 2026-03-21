<?php

namespace Database\Seeders;

use App\Models\Fidele;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Créer un utilisateur admin
        User::create([
            'name' => 'Admin',
            'email' => 'admin@megvie.org',
            'password' => Hash::make('password'),
            'role' => 'admin',
        ]);

             // Créer quelques pasteurs
        User::create([
            'nom' => 'LUC-EVRA',
            'prenoms' => 'PST',
            'name' => 'LUC-EVRA PST',
            'email' => 'pasteur@megvie.org',
            'password' => Hash::make('password'),
            'telephone' => '+225 07 00 00 00 00',
            'lieu_de_residence' => 'Abidjan',
            'zone_suivi' => 'abobo, yopougon, port-bouet',
            'description' => 'Description du pasteur',
            'profession' => 'Pasteur',
            'entreprise' => 'Entreprise',
            'role' => 'pasteur',
        ]);
        User::create([
            'nom' => 'Sous Admin',
            'prenoms' => '',
            'name' => 'Sous Admin',
            'email' => 'sous_admin@megvie.org',
            'password' => Hash::make('password'),
            'telephone' => '+225 07 00 00 00 00',
            'lieu_de_residence' => 'Abidjan',
            'zone_suivi' => 'abobo, yopougon, port-bouet',
            'description' => 'Description du sous admin',
            'profession' => 'Sous Admin',
            'entreprise' => 'Entreprise',
            'role' => 'sous_admin',
        ]);

        // Créer quelques familles
        User::create([
            'nom' => 'Fevrier',
            'prenoms' => '',
            'name' => 'Fevrier',
            'email' => 'fevrier@megvie.org',
            'password' => Hash::make('password'),
            'lieu_de_residence' => 'Abidjan',
            'zone_suivi' => 'Zone 1',
            'description' => 'Description de la famille',
            'profession' => 'Famille',
            'entreprise' => 'Entreprise',
            'role' => 'famille',
        ]);
        User::create([
            'nom' => 'Travailleur',
            'prenoms' => '',
            'name' => 'Travailleur',
            'email' => 'travailleur@megvie.org',
            'password' => Hash::make('password'),
            'lieu_de_residence' => 'Abidjan',
            'zone_suivi' => 'abobo, yopougon, port-bouet',
            'description' => 'Description de la famille',
            'profession' => 'Travailleur',
            'entreprise' => 'Entreprise',
            'role' => 'travailleur',
        ]);
        User::create([
            'nom' => 'Service Social',
            'prenoms' => '',
            'name' => 'Service Social',
            'email' => 'service_social@megvie.org',
            'password' => Hash::make('password'),
            'lieu_de_residence' => 'Abidjan',
            'zone_suivi' => 'abobo, yopougon, port-bouet',
            'description' => 'Description de la famille',
            'profession' => 'Service Social',
            'entreprise' => 'Entreprise',
            'role' => 'service_social',
        ]);

        // Créer quelques parrains
        User::create([
            'nom' => 'Parrain Doe',
            'prenoms' => 'John',
            'name' => 'Parrain Doe',
            'email' => 'parrain@megvie.org',
            'password' => Hash::make('password'),
            'lieu_de_residence' => 'Abidjan',
            'zone_suivi' => 'abobo, yopougon, port-bouet',
            'description' => 'Description du parrain',
            'profession' => 'Parrain',
            'entreprise' => 'Entreprise',
            'role' => 'parrain',
        ]);

        // Créer un fidèle de test + utilisateur pour se connecter en tant que fidèle
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
    }
}

