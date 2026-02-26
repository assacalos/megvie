<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('fideles', function (Blueprint $table) {
            $table->dateTime('date_mise_a_jour_pasteur')->nullable()->after('mariage');
            $table->dateTime('date_mise_a_jour_parrainage')->nullable()->after('date_mise_a_jour_pasteur');
            $table->dateTime('date_mise_a_jour_socio_pro')->nullable()->after('date_mise_a_jour_parrainage');
            $table->dateTime('date_derniere_mise_a_jour')->nullable()->after('date_mise_a_jour_socio_pro');
        });
    }

    public function down(): void
    {
        Schema::table('fideles', function (Blueprint $table) {
            $table->dropColumn([
                'date_mise_a_jour_pasteur',
                'date_mise_a_jour_parrainage',
                'date_mise_a_jour_socio_pro',
                'date_derniere_mise_a_jour',
            ]);
        });
    }
};
