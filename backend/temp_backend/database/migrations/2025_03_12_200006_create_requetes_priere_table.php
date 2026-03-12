<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('requetes_priere', function (Blueprint $table) {
            $table->id();
            $table->foreignId('fidele_id')->nullable()->constrained('fideles')->nullOnDelete();
            $table->text('contenu');
            $table->string('statut')->default('nouvelle'); // nouvelle, en_priere, traitee
            $table->boolean('is_anonyme')->default(false);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('requetes_priere');
    }
};
