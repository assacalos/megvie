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
            'name' => 'Ouattara Cheick',
            'email' => 'cheick@megvie.org',
            'password' => Hash::make('0788944363'),
            'role' => 'admin',
        ]);

        /* // Créer quelques pasteurs
        User::create([
            'nom' => 'LUC-EVRA',
            'prenoms' => 'PST',
            'name' => 'LUC-EVRA PST',
            'email' => 'pasteur@megvie.org',
            'password' => Hash::make('password'),
            'telephone' => '+225 07 00 00 00 00',
            'role' => 'pasteur',
        ]);

        // Créer quelques familles
        User::create([
            'nom' => 'Salomon',
            'prenoms' => '',
            'name' => 'Salomon',
            'email' => 'salomon@megvie.org',
            'password' => Hash::make('password'),
            'role' => 'famille',
        ]);
        User::create([
            'nom' => 'David',
            'prenoms' => '',
            'name' => 'David',
            'email' => 'david@megvie.org',
            'password' => Hash::make('password'),
            'role' => 'famille',
        ]);
        User::create([
            'nom' => 'Moïse',
            'prenoms' => '',
            'name' => 'Moïse',
            'email' => 'moise@megvie.org',
            'password' => Hash::make('password'),
            'role' => 'famille',
        ]);

        // Créer quelques parrains
        User::create([
            'nom' => 'Doe',
            'prenoms' => 'John',
            'name' => 'John Doe',
            'email' => 'john@example.com',
            'password' => Hash::make('password'),
            'role' => 'parrain',
        ]); */
    }
}

