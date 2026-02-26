<?php

namespace App\Http\Controllers;

use App\Models\Suivi;
use Illuminate\Http\Request;

class SuiviController extends Controller
{
    public function store(Request $request)
    {
        // Admin = observateur uniquement : pas de création de suivi
        if ($request->user()?->role === 'admin') {
            return response()->json(['message' => 'Accès refusé. L\'administrateur est en mode observateur.'], 403);
        }

        $validated = $request->validate([
            'fidele_id' => 'required|exists:fideles,id',
            'nature_echange' => 'nullable|string|in:physique,telephonique',
            'motif_echange' => 'nullable|string',
            'resume_echange' => 'nullable|string',
            'date' => 'required|date',
            'observation' => 'nullable|string',
        ]);

        $suivi = Suivi::create($validated);

        return response()->json($suivi->load('fidele'), 201);
    }

    public function update(Request $request, $id)
    {
        // Admin = observateur uniquement
        if ($request->user()?->role === 'admin') {
            return response()->json(['message' => 'Accès refusé. L\'administrateur est en mode observateur.'], 403);
        }

        $suivi = Suivi::findOrFail($id);

        $validated = $request->validate([
            'nature_echange' => 'nullable|string|in:physique,telephonique',
            'motif_echange' => 'nullable|string',
            'resume_echange' => 'nullable|string',
            'date' => 'sometimes|date',
            'observation' => 'nullable|string',
        ]);

        $suivi->update($validated);

        return response()->json($suivi->load('fidele'));
    }

    public function destroy($id)
    {
        // Admin = observateur uniquement
        if (request()->user()?->role === 'admin') {
            return response()->json(['message' => 'Accès refusé. L\'administrateur est en mode observateur.'], 403);
        }

        $suivi = Suivi::findOrFail($id);
        $suivi->delete();

        return response()->json(['message' => 'Suivi supprimé avec succès']);
    }
}

