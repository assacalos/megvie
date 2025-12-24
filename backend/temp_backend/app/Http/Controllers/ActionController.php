<?php

namespace App\Http\Controllers;

use App\Models\Action;
use Illuminate\Http\Request;

class ActionController extends Controller
{
    public function store(Request $request)
    {
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
        $action = Action::findOrFail($id);
        $action->delete();

        return response()->json(['message' => 'Action supprimée avec succès']);
    }
}

