<?php

namespace App\Http\Controllers;

use App\Models\OperationFinanciere;
use Illuminate\Http\Request;

class OperationFinanciereController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $query = OperationFinanciere::with(['fidele', 'enregistrePar'])->orderByDesc('date_operation');

        if ($user && $user->role === 'fidele' && $user->fidele_id) {
            $query->where('fidele_id', $user->fidele_id);
        }

        if ($request->filled('fidele_id')) {
            $query->where('fidele_id', $request->fidele_id);
        }
        if ($request->filled('type')) {
            $query->where('type', $request->type);
        }
        if ($request->filled('date_debut')) {
            $query->where('date_operation', '>=', $request->date_debut);
        }
        if ($request->filled('date_fin')) {
            $query->where('date_operation', '<=', $request->date_fin);
        }

        $perPage = $request->input('per_page', 20);
        return response()->json($query->paginate($perPage));
    }

    public function store(Request $request)
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Non authentifié.'], 401);
        }

        $validated = $request->validate([
            'fidele_id' => 'nullable|exists:fideles,id',
            'type' => 'required|in:dime,offrande,don',
            'montant' => 'required|numeric|min:0',
            'devise' => 'nullable|string|max:3',
            'date_operation' => 'nullable|date',
            'mode_paiement' => 'nullable|in:especes,mobile_money,virement,autre',
            'reference' => 'nullable|string|max:100',
            'note' => 'nullable|string',
        ]);

        if ($user->role === 'fidele') {
            $validated['fidele_id'] = $user->fidele_id;
            $validated['enregistre_par'] = $user->id;
        } else {
            if (empty($validated['fidele_id'])) {
                return response()->json(['message' => 'fidele_id requis.'], 422);
            }
            $validated['enregistre_par'] = $user->id;
        }

        $validated['date_operation'] = $validated['date_operation'] ?? now()->toDateString();
        $validated['devise'] = $validated['devise'] ?? 'XOF';
        $validated['mode_paiement'] = $validated['mode_paiement'] ?? 'especes';

        $op = OperationFinanciere::create($validated);
        return response()->json($op->load(['fidele', 'enregistrePar']), 201);
    }

    public function show(Request $request, $id)
    {
        $op = OperationFinanciere::with(['fidele', 'enregistrePar'])->findOrFail($id);

        $user = $request->user();
        if ($user && $user->role === 'fidele' && $user->fidele_id != $op->fidele_id) {
            return response()->json(['message' => 'Accès refusé.'], 403);
        }

        return response()->json($op);
    }

    public function stats(Request $request)
    {
        $user = $request->user();
        $query = OperationFinanciere::query();

        if ($user && $user->role === 'fidele' && $user->fidele_id) {
            $query->where('fidele_id', $user->fidele_id);
        }
        if ($request->filled('fidele_id')) {
            $query->where('fidele_id', $request->fidele_id);
        }
        if ($request->filled('date_debut')) {
            $query->where('date_operation', '>=', $request->date_debut);
        }
        if ($request->filled('date_fin')) {
            $query->where('date_operation', '<=', $request->date_fin);
        }

        $total = $query->sum('montant');
        $byType = (clone $query)->selectRaw('type, sum(montant) as total')->groupBy('type')->pluck('total', 'type');

        return response()->json([
            'total' => (float) $total,
            'par_type' => $byType,
            'nombre_operations' => (clone $query)->count(),
        ]);
    }

    public function destroy(Request $request, $id)
    {
        if ($request->user()?->role === 'fidele') {
            return response()->json(['message' => 'Accès refusé.'], 403);
        }

        OperationFinanciere::findOrFail($id)->delete();
        return response()->json(['message' => 'Opération supprimée.']);
    }
}
