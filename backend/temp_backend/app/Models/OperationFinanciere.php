<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OperationFinanciere extends Model
{
    use HasFactory;

    protected $table = 'operations_financieres';

    protected $fillable = [
        'fidele_id',
        'type',
        'montant',
        'devise',
        'date_operation',
        'mode_paiement',
        'reference',
        'note',
        'enregistre_par',
    ];

    protected $casts = [
        'montant' => 'decimal:2',
        'date_operation' => 'date',
    ];

    public function fidele()
    {
        return $this->belongsTo(Fidele::class);
    }

    public function enregistrePar()
    {
        return $this->belongsTo(User::class, 'enregistre_par');
    }
}
