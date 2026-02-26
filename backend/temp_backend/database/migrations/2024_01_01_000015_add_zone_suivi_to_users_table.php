<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Zone de suivi (quartiers séparés par des virgules).
     * Permet de comparer avec le lieu d'habitation du fidèle pour l'afficher chez le pasteur.
     */
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->text('zone_suivi')->nullable()->after('lieu_de_residence');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('zone_suivi');
        });
    }
};
