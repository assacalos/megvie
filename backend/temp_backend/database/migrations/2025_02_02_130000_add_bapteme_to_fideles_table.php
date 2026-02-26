<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('fideles', function (Blueprint $table) {
            $table->boolean('baptise_eau')->nullable()->after('corps_metier_id');
            $table->boolean('baptise_saint_esprit')->nullable()->after('baptise_eau');
        });
    }

    public function down(): void
    {
        Schema::table('fideles', function (Blueprint $table) {
            $table->dropColumn(['baptise_eau', 'baptise_saint_esprit']);
        });
    }
};
