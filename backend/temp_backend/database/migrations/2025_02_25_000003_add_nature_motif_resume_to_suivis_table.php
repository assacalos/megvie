<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('suivis', function (Blueprint $table) {
            $table->string('nature_echange', 50)->nullable()->after('statut'); // 'physique', 'telephonique'
            $table->text('motif_echange')->nullable()->after('nature_echange');
            $table->text('resume_echange')->nullable()->after('motif_echange');
        });
    }

    public function down(): void
    {
        Schema::table('suivis', function (Blueprint $table) {
            $table->dropColumn(['nature_echange', 'motif_echange', 'resume_echange']);
        });
    }
};
