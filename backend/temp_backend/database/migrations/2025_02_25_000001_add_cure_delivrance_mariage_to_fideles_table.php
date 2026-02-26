<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('fideles', function (Blueprint $table) {
            $table->boolean('cure_d_ame')->nullable()->after('baptise_saint_esprit');
            $table->boolean('delivrance')->nullable()->after('cure_d_ame');
            $table->boolean('mariage')->nullable()->after('delivrance');
        });
    }

    public function down(): void
    {
        Schema::table('fideles', function (Blueprint $table) {
            $table->dropColumn(['cure_d_ame', 'delivrance', 'mariage']);
        });
    }
};
