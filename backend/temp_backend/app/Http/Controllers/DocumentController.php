<?php

namespace App\Http\Controllers;

use App\Models\Document;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class DocumentController extends Controller
{
    public function index(Request $request)
    {
        $query = Document::with('createdBy')->orderByDesc('created_at');

        if ($request->has('type')) {
            $query->where('type', $request->type);
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
            'description' => 'nullable|string',
            'type' => 'nullable|in:reglement,formulaire,autre',
            'fichier' => 'required|file|max:20480',
        ]);

        $file = $request->file('fichier');
        $path = $file->store('documents', 'public');

        $doc = Document::create([
            'titre' => $validated['titre'],
            'description' => $validated['description'] ?? null,
            'type' => $validated['type'] ?? 'autre',
            'file_path' => $path,
            'file_name' => $file->getClientOriginalName(),
            'mime_type' => $file->getMimeType(),
            'file_size' => $file->getSize(),
            'created_by' => $request->user()?->id,
        ]);

        return response()->json($doc->load('createdBy'), 201);
    }

    public function show($id)
    {
        return response()->json(Document::with('createdBy')->findOrFail($id));
    }

    public function download($id)
    {
        $doc = Document::findOrFail($id);
        if (! Storage::disk('public')->exists($doc->file_path)) {
            return response()->json(['message' => 'Fichier introuvable.'], 404);
        }
        return Storage::disk('public')->download($doc->file_path, $doc->file_name);
    }

    public function destroy(Request $request, $id)
    {
        if ($request->user()?->role === 'fidele') {
            return response()->json(['message' => 'Accès refusé.'], 403);
        }

        $doc = Document::findOrFail($id);
        Storage::disk('public')->delete($doc->file_path);
        $doc->delete();
        return response()->json(['message' => 'Document supprimé.']);
    }
}
