<?php

namespace App\Http\Controllers;

use App\Models\Action;
use Illuminate\Http\Request;

class ActionController extends Controller
{
    public function store(Request $request)
    {
        // Admin = observateur uniquement
        if ($request->user()?->role === 'admin') {
            return response()->json(['message' => 'Accès refusé. L\'administrateur est en mode observateur.'], 403);
        }

        $validated = $request->validate([
            'fidele_id' => 'required|exists:fideles,id',
            'type' => 'nullable|in:action_sociale,attribution_marche,accompagnement_projet',
            'date' => 'required|date',
            'montant' => 'nullable|numeric',
            'description' => 'nullable|string',
        ]);

        $action = Action::create($validated);

        return response()->json($action->load('fidele'), 201);
    }

    public function update(Request $request, $id)
    {
        // Admin = observateur uniquement
        if ($request->user()?->role === 'admin') {
            return response()->json(['message' => 'Accès refusé. L\'administrateur est en mode observateur.'], 403);
        }

        $action = Action::findOrFail($id);

        $validated = $request->validate([
            'type' => 'sometimes|in:action_sociale,attribution_marche,accompagnement_projet',
            'date' => 'sometimes|date',
            'montant' => 'nullable|numeric',
            'description' => 'nullable|string',
        ]);

        $action->update($validated);

        return response()->json($action->load('fidele'));
    }

    public function destroy($id)
    {
        // Admin = observateur uniquement
        if (request()->user()?->role === 'admin') {
            return response()->json(['message' => 'Accès refusé. L\'administrateur est en mode observateur.'], 403);
        }

        $action = Action::findOrFail($id);
        $action->delete();

        return response()->json(['message' => 'Action supprimée avec succès']);
    }
}

