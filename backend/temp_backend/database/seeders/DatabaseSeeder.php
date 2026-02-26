<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

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
    }
}

