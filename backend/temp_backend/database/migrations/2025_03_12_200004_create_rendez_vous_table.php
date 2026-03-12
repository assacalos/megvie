<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('rendez_vous', function (Blueprint $table) {
            $table->id();
            $table->foreignId('fidele_id')->constrained('fideles')->cascadeOnDelete();
            $table->string('type')->default('pastoral'); // pastoral, priere, autre
            $table->string('sujet');
            $table->date('date_souhaitee')->nullable();
            $table->time('heure_souhaitee')->nullable();
            $table->string('statut')->default('en_attente'); // en_attente, confirme, annule, effectue
            $table->text('note_fidele')->nullable();
            $table->text('note_pasteur')->nullable();
            $table->foreignId('assigne_a')->nullable()->constrained('users')->nullOnDelete();
            $table->dateTime('date_effectif')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('rendez_vous');
    }
};
