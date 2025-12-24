<?php

namespace App\Http\Controllers;

use App\Models\Suivi;
use Illuminate\Http\Request;

class SuiviController extends Controller
{
    public function store(Request $request)
    {
        $validated = $request->validate([
            'fidele_id' => 'required|exists:fideles,id',
            'statut' => 'nullable|in:pas_interesse,injoignable,confirme,visite_prochaine_fois',
            'date' => 'required|date',
            'observation' => 'nullable|string',
        ]);

        $suivi = Suivi::create($validated);

        return response()->json($suivi->load('fidele'), 201);
    }

    public function update(Request $request, $id)
    {
        $suivi = Suivi::findOrFail($id);

        $validated = $request->validate([
            'statut' => 'sometimes|in:pas_interesse,injoignable,confirme,visite_prochaine_fois',
            'date' => 'sometimes|date',
            'observation' => 'nullable|string',
        ]);

        $suivi->update($validated);

        return response()->json($suivi->load('fidele'));
    }

    public function destroy($id)
    {
        $suivi = Suivi::findOrFail($id);
        $suivi->delete();

        return response()->json(['message' => 'Suivi supprimé avec succès']);
    }
}

