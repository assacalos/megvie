<?php

namespace App\Http\Controllers;

use App\Models\RequetePriere;
use Illuminate\Http\Request;

class RequetePriereController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $query = RequetePriere::with('fidele')->orderByDesc('created_at');

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
            'contenu' => 'required|string',
            'is_anonyme' => 'nullable|boolean',
        ]);

        $validated['fidele_id'] = ($validated['is_anonyme'] ?? false) ? null : ($user?->fidele_id ?? null);
        $validated['statut'] = 'nouvelle';

        $req = RequetePriere::create($validated);
        return response()->json($req->load('fidele'), 201);
    }

    public function show(Request $request, $id)
    {
        $req = RequetePriere::with('fidele')->findOrFail($id);

        $user = $request->user();
        if ($user && $user->role === 'fidele' && $user->fidele_id != $req->fidele_id) {
            return response()->json(['message' => 'Accès refusé.'], 403);
        }

        return response()->json($req);
    }

    public function update(Request $request, $id)
    {
        $req = RequetePriere::findOrFail($id);
        $user = $request->user();

        if ($user && $user->role === 'fidele') {
            if ($user->fidele_id != $req->fidele_id) {
                return response()->json(['message' => 'Accès refusé.'], 403);
            }
            return response()->json(['message' => 'Modification non autorisée.'], 403);
        }

        $validated = $request->validate([
            'statut' => 'required|in:nouvelle,en_priere,traitee',
        ]);
        $req->update($validated);
        return response()->json($req->fresh()->load('fidele'));
    }

    public function destroy(Request $request, $id)
    {
        $req = RequetePriere::findOrFail($id);
        $user = $request->user();
        if ($user && $user->role === 'fidele' && $user->fidele_id != $req->fidele_id) {
            return response()->json(['message' => 'Accès refusé.'], 403);
        }
        $req->delete();
        return response()->json(['message' => 'Requête supprimée.']);
    }
}
