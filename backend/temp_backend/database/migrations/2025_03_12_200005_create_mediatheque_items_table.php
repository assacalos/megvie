<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('mediatheque_items', function (Blueprint $table) {
            $table->id();
            $table->string('titre');
            $table->string('type'); // video, audio, note_predication, ressource_biblique
            $table->string('url_or_path');
            $table->text('description')->nullable();
            $table->date('date_publication')->nullable();
            $table->unsignedInteger('duree_secondes')->nullable();
            $table->string('auteur')->nullable();
            $table->string('serie_or_categorie')->nullable();
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('mediatheque_items');
    }
};
