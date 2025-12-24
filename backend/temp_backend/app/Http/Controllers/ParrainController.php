<?php

namespace App\Http\Controllers;

use App\Models\Parrain;
use Illuminate\Http\Request;

class ParrainController extends Controller
{
    public function index()
    {
        $parrains = Parrain::all();
        return response()->json($parrains);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'nom' => 'required|string',
            'prenoms' => 'required|string',
            'email' => 'nullable|email',
            'telephone' => 'nullable|string',
        ]);

        $parrain = Parrain::create($validated);
        return response()->json($parrain, 201);
    }
}

