<?php

namespace App\Http\Controllers;

use App\Models\Pasteur;
use Illuminate\Http\Request;

class PasteurController extends Controller
{
    public function index()
    {
        $pasteurs = Pasteur::all();
        return response()->json($pasteurs);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'nom' => 'required|string',
            'prenoms' => 'required|string',
            'email' => 'nullable|email',
            'telephone' => 'nullable|string',
        ]);

        $pasteur = Pasteur::create($validated);
        return response()->json($pasteur, 201);
    }
}

