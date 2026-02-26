<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('fideles', function (Blueprint $table) {
            $table->string('famille_mois')->nullable()->after('famille_id');
        });
    }

    public function down(): void
    {
        Schema::table('fideles', function (Blueprint $table) {
            $table->dropColumn('famille_mois');
        });
    }
};
