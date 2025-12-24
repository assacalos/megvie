<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('suivis', function (Blueprint $table) {
            $table->id();
            $table->foreignId('fidele_id')->constrained()->cascadeOnDelete();
            $table->enum('statut', ['pas_interesse', 'injoignable', 'confirme', 'visite_prochaine_fois'])->nullable();
            $table->date('date');
            $table->text('observation')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('suivis');
    }
};

