<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class UserController extends Controller
{
    public function index(Request $request)
    {
        // Seuls les administrateurs peuvent voir tous les utilisateurs
        $user = $request->user();
        if (!$user || !in_array($user->role, ['admin', 'sous_admin'])) {
            return response()->json([
                'message' => 'Accès refusé. Seuls les administrateurs peuvent voir les utilisateurs.'
            ], 403);
        }
        
        $query = User::query();
        
        // Filtrer par rôle si spécifié
        if ($request->has('role')) {
            $query->where('role', $request->role);
        }
        
        $users = $query->get();
        return response()->json($users);
    }

    public function store(Request $request)
    {
        // Seuls les administrateurs peuvent créer des utilisateurs
        $user = $request->user();
        if (!$user || !in_array($user->role, ['admin', 'sous_admin'])) {
            return response()->json([
                'message' => 'Accès refusé. Seuls les administrateurs peuvent créer des utilisateurs.'
            ], 403);
        }
        
        $validated = $request->validate([
            'name' => 'nullable|string|max:255',
            'nom' => 'required|string|max:255',
            'prenoms' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:6',
            'telephone' => 'nullable|string',
            'lieu_de_residence' => 'nullable|string|max:255',
            'description' => 'nullable|string',
            'profession' => 'nullable|string',
            'entreprise' => 'nullable|string',
            'role' => 'required|string|in:admin,sous_admin,pasteur,famille,parrain,service_social,travailleur',
            'type_connexion' => 'nullable|string',
        ]);

        // Construire le nom complet si nom et prenoms sont fournis
        $name = $validated['name'] ?? null;
        if (!$name && isset($validated['nom']) && isset($validated['prenoms'])) {
            $name = trim($validated['nom'] . ' ' . $validated['prenoms']);
        } elseif (!$name && isset($validated['nom'])) {
            $name = $validated['nom'];
        }

        $email = $validated['email'];

        $userData = [
            'name' => $name ?? $email,
            'nom' => $validated['nom'],
            'prenoms' => $validated['prenoms'],
            'email' => $email,
            'telephone' => $validated['telephone'] ?? null,
            'lieu_de_residence' => $validated['lieu_de_residence'] ?? null,
            'description' => $validated['description'] ?? null,
            'profession' => $validated['profession'] ?? null,
            'entreprise' => $validated['entreprise'] ?? null,
            'role' => $validated['role'],
            'type_connexion' => $validated['type_connexion'] ?? null,
        ];

        // Hash le mot de passe
        $userData['password'] = Hash::make($validated['password']);

        $user = User::create($userData);

        // Ne pas retourner le mot de passe
        $user->makeHidden('password');

        return response()->json($user, 201);
    }

    public function show($id)
    {
        $user = User::findOrFail($id);
        $user->makeHidden('password');
        return response()->json($user);
    }

    public function update(Request $request, $id)
    {
        // Seuls les administrateurs peuvent modifier des utilisateurs
        $currentUser = $request->user();
        if (!$currentUser || !in_array($currentUser->role, ['admin', 'sous_admin'])) {
            return response()->json([
                'message' => 'Accès refusé. Seuls les administrateurs peuvent modifier des utilisateurs.'
            ], 403);
        }
        
        $user = User::findOrFail($id);

        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'nom' => 'sometimes|string|max:255',
            'prenoms' => 'sometimes|string|max:255',
            'email' => 'sometimes|email|unique:users,email,' . $id,
            'password' => 'sometimes|string|min:6',
            'telephone' => 'sometimes|string',
            'lieu_de_residence' => 'sometimes|string|max:255',
            'description' => 'sometimes|string',
            'profession' => 'sometimes|string',
            'entreprise' => 'sometimes|string',
            'role' => 'sometimes|string|in:admin,sous_admin,pasteur,famille,parrain,service_social,travailleur',
            'type_connexion' => 'sometimes|string',
        ]);

        if (isset($validated['password'])) {
            $validated['password'] = Hash::make($validated['password']);
        }

        $user->update($validated);
        $user->makeHidden('password');

        return response()->json($user);
    }

    public function destroy(Request $request, $id)
    {
        // Seuls les administrateurs peuvent supprimer des utilisateurs
        $currentUser = $request->user();
        if (!$currentUser || !in_array($currentUser->role, ['admin', 'sous_admin'])) {
            return response()->json([
                'message' => 'Accès refusé. Seuls les administrateurs peuvent supprimer des utilisateurs.'
            ], 403);
        }
        
        $user = User::findOrFail($id);
        $user->delete();

        return response()->json(['message' => 'Utilisateur supprimé avec succès']);
    }
}

