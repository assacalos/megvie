<?php

namespace App\Http\Controllers;

use App\Models\RendezVous;
use Illuminate\Http\Request;

class RendezVousController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $query = RendezVous::with(['fidele', 'assigneA'])->orderByDesc('created_at');

        if ($user && $user->role === 'fidele' && $user->fidele_id) {
            $query->where('fidele_id', $user->fidele_id);
        }
        if ($request->filled('fidele_id')) {
            $query->where('fidele_id', $request->fidele_id);
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
        if (! $user) {
            return response()->json(['message' => 'Non authentifié.'], 401);
        }

        $validated = $request->validate([
            'fidele_id' => 'nullable|exists:fideles,id',
            'type' => 'required|in:pastoral,priere,autre',
            'sujet' => 'required|string|max:255',
            'date_souhaitee' => 'nullable|date',
            'heure_souhaitee' => 'nullable|string|max:10',
            'note_fidele' => 'nullable|string',
        ]);

        if ($user->role === 'fidele') {
            $validated['fidele_id'] = $user->fidele_id;
        } else {
            if (empty($validated['fidele_id'])) {
                return response()->json(['message' => 'fidele_id requis.'], 422);
            }
        }

        $validated['statut'] = 'en_attente';

        $rdv = RendezVous::create($validated);
        return response()->json($rdv->load(['fidele', 'assigneA']), 201);
    }

    public function show(Request $request, $id)
    {
        $rdv = RendezVous::with(['fidele', 'assigneA'])->findOrFail($id);

        $user = $request->user();
        if ($user && $user->role === 'fidele' && $user->fidele_id != $rdv->fidele_id) {
            return response()->json(['message' => 'Accès refusé.'], 403);
        }

        return response()->json($rdv);
    }

    public function update(Request $request, $id)
    {
        $rdv = RendezVous::findOrFail($id);
        $user = $request->user();

        if ($user && $user->role === 'fidele') {
            if ($user->fidele_id != $rdv->fidele_id) {
                return response()->json(['message' => 'Accès refusé.'], 403);
            }
            $validated = $request->validate([
                'note_fidele' => 'sometimes|nullable|string',
            ]);
        } else {
            $validated = $request->validate([
                'statut' => 'sometimes|in:en_attente,confirme,annule,effectue',
                'note_pasteur' => 'nullable|string',
                'assigne_a' => 'nullable|exists:users,id',
                'date_effectif' => 'nullable|date',
            ]);
        }

        $rdv->update($validated);
        return response()->json($rdv->fresh()->load(['fidele', 'assigneA']));
    }

    public function destroy(Request $request, $id)
    {
        $rdv = RendezVous::findOrFail($id);
        $user = $request->user();
        if ($user && $user->role === 'fidele' && $user->fidele_id != $rdv->fidele_id) {
            return response()->json(['message' => 'Accès refusé.'], 403);
        }
        $rdv->delete();
        return response()->json(['message' => 'Rendez-vous supprimé.']);
    }
}
