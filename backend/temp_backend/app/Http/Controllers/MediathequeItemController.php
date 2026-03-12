<?php

namespace App\Http\Controllers;

use App\Models\MediathequeItem;
use Illuminate\Http\Request;

class MediathequeItemController extends Controller
{
    public function index(Request $request)
    {
        $query = MediathequeItem::with('createdBy')->orderByDesc('date_publication')->orderByDesc('created_at');

        if ($request->filled('type')) {
            $query->where('type', $request->type);
        }
        if ($request->filled('serie')) {
            $query->where('serie_or_categorie', $request->serie);
        }

        $perPage = $request->input('per_page', 20);
        return response()->json($query->paginate($perPage));
    }

    public function store(Request $request)
    {
        if ($request->user()?->role === 'fidele') {
            return response()->json(['message' => 'Accès refusé.'], 403);
        }

        $validated = $request->validate([
            'titre' => 'required|string|max:255',
            'type' => 'required|in:video,audio,note_predication,ressource_biblique',
            'url_or_path' => 'required|string',
            'description' => 'nullable|string',
            'date_publication' => 'nullable|date',
            'duree_secondes' => 'nullable|integer|min:0',
            'auteur' => 'nullable|string|max:255',
            'serie_or_categorie' => 'nullable|string|max:100',
        ]);

        $validated['created_by'] = $request->user()?->id;
        $item = MediathequeItem::create($validated);
        return response()->json($item->load('createdBy'), 201);
    }

    public function show($id)
    {
        return response()->json(MediathequeItem::with('createdBy')->findOrFail($id));
    }

    public function update(Request $request, $id)
    {
        if ($request->user()?->role === 'fidele') {
            return response()->json(['message' => 'Accès refusé.'], 403);
        }

        $item = MediathequeItem::findOrFail($id);
        $validated = $request->validate([
            'titre' => 'sometimes|string|max:255',
            'type' => 'sometimes|in:video,audio,note_predication,ressource_biblique',
            'url_or_path' => 'sometimes|string',
            'description' => 'nullable|string',
            'date_publication' => 'nullable|date',
            'duree_secondes' => 'nullable|integer|min:0',
            'auteur' => 'nullable|string|max:255',
            'serie_or_categorie' => 'nullable|string|max:100',
        ]);
        $item->update($validated);
        return response()->json($item->fresh()->load('createdBy'));
    }

    public function destroy(Request $request, $id)
    {
        if ($request->user()?->role === 'fidele') {
            return response()->json(['message' => 'Accès refusé.'], 403);
        }

        MediathequeItem::findOrFail($id)->delete();
        return response()->json(['message' => 'Élément supprimé.']);
    }
}
