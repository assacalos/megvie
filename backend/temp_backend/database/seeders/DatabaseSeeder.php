<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use App\Models\User;
use App\Models\Pasteur;
use App\Models\Famille;
use App\Models\Parrain;
use App\Models\ChefDisc;
use App\Models\CorpsMetier;

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
        Pasteur::create([
            'nom' => 'LUC-EVRA',
            'prenoms' => 'PST',
            'email' => 'pasteur@megvie.org',
            'telephone' => '+225 07 00 00 00 00',
        ]);

        // Créer quelques familles
        Famille::create(['nom' => 'Salomon']);
        Famille::create(['nom' => 'David']);
        Famille::create(['nom' => 'Moïse']);

        // Créer quelques parrains
        Parrain::create([
            'nom' => 'Doe',
            'prenoms' => 'John',
            'email' => 'john@example.com',
        ]);

        // Créer quelques chefs de disc
        ChefDisc::create([
            'nom' => 'Smith',
            'prenoms' => 'Jane',
            'email' => 'jane@example.com',
        ]);

        // Créer quelques corps de métiers
        CorpsMetier::create(['nom' => 'Consultant financier']);
        CorpsMetier::create(['nom' => 'Enseignant']);
        CorpsMetier::create(['nom' => 'Médecin']);
    }
}

