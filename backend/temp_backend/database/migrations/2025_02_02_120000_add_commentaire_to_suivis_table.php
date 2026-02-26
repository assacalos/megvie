<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('suivis', function (Blueprint $table) {
            $table->text('commentaire')->nullable()->after('observation');
        });
    }

    public function down(): void
    {
        Schema::table('suivis', function (Blueprint $table) {
            $table->dropColumn('commentaire');
        });
    }
};
