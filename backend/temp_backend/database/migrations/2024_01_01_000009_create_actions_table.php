<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('actions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('fidele_id')->constrained()->cascadeOnDelete();
            $table->enum('type', ['action_sociale', 'attribution_marche', 'accompagnement_projet'])->nullable();
            $table->date('date');
            $table->decimal('montant', 10, 2)->nullable();
            $table->text('description')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('actions');
    }
};

