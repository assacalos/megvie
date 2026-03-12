<?php

namespace App\Http\Controllers;

use App\Models\Annonce;
use Illuminate\Http\Request;

class AnnonceController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $query = Annonce::with('createdBy')->orderByDesc('is_pinned')->orderByDesc('date_publication');

        if ($user && $user->role === 'fidele') {
            $query->where('date_publication', '<=', now()->toDateString());
            $query->where(function ($q) {
                $q->whereNull('date_fin_affichage')->orWhere('date_fin_affichage', '>=', now()->toDateString());
            });
        }

        if ($request->has('type')) {
            $query->where('type', $request->type);
        }

        $perPage = $request->input('per_page', 20);
        return response()->json($query->paginate($perPage));
    }

    public function store(Request $request)
    {
        if ($this->isFidele($request)) {
            return response()->json(['message' => 'Accès refusé.'], 403);
        }

        $validated = $request->validate([
            'titre' => 'required|string|max:255',
            'contenu' => 'required|string',
            'type' => 'nullable|in:annonce,actualite',
            'date_publication' => 'nullable|date',
            'date_fin_affichage' => 'nullable|date|after_or_equal:date_publication',
            'is_pinned' => 'nullable|boolean',
        ]);

        $validated['date_publication'] = $validated['date_publication'] ?? now()->toDateString();
        $validated['created_by'] = $request->user()?->id;

        $annonce = Annonce::create($validated);
        return response()->json($annonce->load('createdBy'), 201);
    }

    public function show(Request $request, $id)
    {
        $annonce = Annonce::with('createdBy')->findOrFail($id);

        $user = $request->user();
        if ($user && $user->role === 'fidele') {
            if ($annonce->date_publication->isFuture() ||
                ($annonce->date_fin_affichage && $annonce->date_fin_affichage->isPast())) {
                return response()->json(['message' => 'Annonce non disponible.'], 404);
            }
        }

        return response()->json($annonce);
    }

    public function update(Request $request, $id)
    {
        if ($this->isFidele($request)) {
            return response()->json(['message' => 'Accès refusé.'], 403);
        }

        $annonce = Annonce::findOrFail($id);
        $validated = $request->validate([
            'titre' => 'sometimes|string|max:255',
            'contenu' => 'sometimes|string',
            'type' => 'sometimes|in:annonce,actualite',
            'date_publication' => 'sometimes|date',
            'date_fin_affichage' => 'nullable|date',
            'is_pinned' => 'sometimes|boolean',
        ]);

        $annonce->update($validated);
        return response()->json($annonce->fresh()->load('createdBy'));
    }

    public function destroy(Request $request, $id)
    {
        if ($this->isFidele($request)) {
            return response()->json(['message' => 'Accès refusé.'], 403);
        }

        Annonce::findOrFail($id)->delete();
        return response()->json(['message' => 'Annonce supprimée.']);
    }

    private function isFidele(Request $request): bool
    {
        return $request->user()?->role === 'fidele';
    }
}
