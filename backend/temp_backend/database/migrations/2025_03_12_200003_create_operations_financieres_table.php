<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('operations_financieres', function (Blueprint $table) {
            $table->id();
            $table->foreignId('fidele_id')->constrained('fideles')->cascadeOnDelete();
            $table->string('type'); // dime, offrande, don
            $table->decimal('montant', 12, 2);
            $table->string('devise', 3)->default('XOF');
            $table->date('date_operation');
            $table->string('mode_paiement')->default('especes'); // especes, mobile_money, virement, autre
            $table->string('reference')->nullable();
            $table->text('note')->nullable();
            $table->foreignId('enregistre_par')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('operations_financieres');
    }
};
