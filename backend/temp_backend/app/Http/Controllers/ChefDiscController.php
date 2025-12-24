<?php

namespace App\Http\Controllers;

use App\Models\ChefDisc;
use Illuminate\Http\Request;

class ChefDiscController extends Controller
{
    public function index()
    {
        $chefDiscs = ChefDisc::all();
        return response()->json($chefDiscs);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'nom' => 'required|string',
            'prenoms' => 'required|string',
            'email' => 'nullable|email',
            'telephone' => 'nullable|string',
        ]);

        $chefDisc = ChefDisc::create($validated);
        return response()->json($chefDisc, 201);
    }
}

