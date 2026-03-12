<?php

namespace App\Http\Controllers;

use App\Models\Temoignage;
use Illuminate\Http\Request;

class TemoignageController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $query = Temoignage::with(['fidele', 'approuvePar'])->orderByDesc('created_at');

        if ($user && $user->role === 'fidele' && $user->fidele_id) {
            $query->where('fidele_id', $user->fidele_id);
        }
        if ($request->filled('statut')) {
            $query->where('statut', $request->statut);
        }

        $perPage = $request->input('per_page', 20);
        return response()->json($query->paginate($perPage));
    }

    public function store(Request $request)
    {
        $user = $request->user();

        $validated = $request->validate([
            'titre' => 'required|string|max:255',
            'contenu' => 'required|string',
        ]);

        $validated['fidele_id'] = $user?->fidele_id;
        $validated['statut'] = 'en_attente';

        $tem = Temoignage::create($validated);
        return response()->json($tem->load('fidele'), 201);
    }

    public function show(Request $request, $id)
    {
        $tem = Temoignage::with(['fidele', 'approuvePar'])->findOrFail($id);

        $user = $request->user();
        if ($user && $user->role === 'fidele' && $user->fidele_id != $tem->fidele_id) {
            return response()->json(['message' => 'Accès refusé.'], 403);
        }

        return response()->json($tem);
    }

    public function update(Request $request, $id)
    {
        $tem = Temoignage::findOrFail($id);
        $user = $request->user();

        if ($user && $user->role === 'fidele') {
            if ($user->fidele_id != $tem->fidele_id) {
                return response()->json(['message' => 'Accès refusé.'], 403);
            }
            $validated = $request->validate([
                'titre' => 'sometimes|string|max:255',
                'contenu' => 'sometimes|string',
            ]);
            if ($tem->statut !== 'en_attente') {
                return response()->json(['message' => 'Témoignage déjà traité.'], 403);
            }
        } else {
            $validated = $request->validate([
                'statut' => 'required|in:en_attente,approuve,rejete',
            ]);
            if (($validated['statut'] ?? null) === 'approuve') {
                $validated['approuve_par'] = $user?->id;
                $validated['date_approbation'] = now();
            }
        }

        $tem->update($validated);
        return response()->json($tem->fresh()->load(['fidele', 'approuvePar']));
    }

    public function destroy(Request $request, $id)
    {
        $tem = Temoignage::findOrFail($id);
        $user = $request->user();
        if ($user && $user->role === 'fidele' && $user->fidele_id != $tem->fidele_id) {
            return response()->json(['message' => 'Accès refusé.'], 403);
        }
        $tem->delete();
        return response()->json(['message' => 'Témoignage supprimé.']);
    }
}
