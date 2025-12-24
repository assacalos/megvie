<?php

namespace App\Http\Controllers;

use App\Models\CorpsMetier;
use Illuminate\Http\Request;

class CorpsMetierController extends Controller
{
    public function index()
    {
        $corpsMetiers = CorpsMetier::all();
        return response()->json($corpsMetiers);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'nom' => 'required|string',
            'description' => 'nullable|string',
        ]);

        $corpsMetier = CorpsMetier::create($validated);
        return response()->json($corpsMetier, 201);
    }

    public function update(Request $request, $id)
    {
        $corpsMetier = CorpsMetier::findOrFail($id);

        $validated = $request->validate([
            'nom' => 'sometimes|string',
            'description' => 'nullable|string',
        ]);

        $corpsMetier->update($validated);
        return response()->json($corpsMetier);
    }
}

