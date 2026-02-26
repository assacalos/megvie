<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('nom')->nullable()->after('name');
            $table->string('prenoms')->nullable()->after('nom');
            $table->string('telephone')->nullable()->after('email');
            $table->string('lieu_de_residence')->nullable()->after('telephone');
            $table->text('description')->nullable()->after('lieu_de_residence');
            $table->string('profession')->nullable()->after('description');
            $table->string('entreprise')->nullable()->after('profession');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['nom', 'prenoms', 'telephone', 'lieu_de_residence', 'description', 'profession', 'entreprise']);
        });
    }
};

