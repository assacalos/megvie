<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('fideles', function (Blueprint $table) {
            $table->id();
            $table->string('nom');
            $table->string('prenoms');
            $table->string('tranche_age')->nullable();
            $table->string('lieu_residence')->nullable();
            $table->string('comment_connu')->nullable();
            $table->string('but_visite')->nullable();
            $table->string('qui_invite')->nullable();
            $table->string('frequente_eglise')->nullable();
            $table->boolean('souhaite_appartenir')->default(false);
            $table->date('date_arrivee')->nullable();
            $table->boolean('appartient_famille')->nullable();
            $table->enum('statut', ['fidele', 'nouvel_ame'])->default('nouvel_ame');
            $table->string('profession')->nullable();
            $table->string('photo')->nullable();
            $table->string('facebook')->nullable();
            $table->string('contacts')->nullable();
            $table->string('whatsapp')->nullable();
            $table->string('instagram')->nullable();
            $table->string('email')->nullable();
            $table->foreignId('parrain_id')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('pasteur_id')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('chef_disc_id')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('famille_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('formation')->nullable();
            $table->integer('annee_experience')->nullable();
            $table->foreignId('corps_metier_id')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('fideles');
    }
};

