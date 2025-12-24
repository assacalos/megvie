<?php

namespace App\Http\Controllers;

use App\Models\Famille;
use Illuminate\Http\Request;

class FamilleController extends Controller
{
    public function index()
    {
        $familles = Famille::all();
        return response()->json($familles);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'nom' => 'required|string',
            'description' => 'nullable|string',
        ]);

        $famille = Famille::create($validated);
        return response()->json($famille, 201);
    }
}

