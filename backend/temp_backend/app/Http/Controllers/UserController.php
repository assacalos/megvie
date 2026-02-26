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

        // Pour les parrains : filtrer par famille si famille_id fourni
        if ($request->role === 'parrain' && $request->filled('famille_id')) {
            $query->where('famille_id', $request->famille_id);
        }

        // Charger la relation famille pour les parrains
        if ($request->role === 'parrain') {
            $query->with('famille');
        }
        
        $users = $query->get();
        return response()->json($users);
    }

    public function store(Request $request)
    {
        // Seul le sous-admin peut créer des utilisateurs (admin = observateur)
        $user = $request->user();
        if (!$user || $user->role !== 'sous_admin') {
            return response()->json([
                'message' => 'Accès refusé. Seul le sous-administrateur peut créer des utilisateurs.'
            ], 403);
        }
        
        $rules = [
            'name' => 'nullable|string|max:255',
            'nom' => 'required|string|max:255',
            'prenoms' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:6',
            'telephone' => 'nullable|string',
            'lieu_de_residence' => 'nullable|string|max:255',
            'zone_suivi' => 'nullable|string|max:500',
            'description' => 'nullable|string',
            'profession' => 'nullable|string',
            'entreprise' => 'nullable|string',
            'role' => 'required|string|in:admin,sous_admin,pasteur,famille,parrain,service_social,travailleur',
        ];
        if ($request->input('role') === 'parrain') {
            $rules['famille_id'] = 'required|exists:users,id';
        } else {
            $rules['famille_id'] = 'nullable|exists:users,id';
        }
        $validated = $request->validate($rules);

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
            'zone_suivi' => $validated['zone_suivi'] ?? null,
            'description' => $validated['description'] ?? null,
            'profession' => $validated['profession'] ?? null,
            'entreprise' => $validated['entreprise'] ?? null,
            'role' => $validated['role'],
            'famille_id' => $validated['famille_id'] ?? null,
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
        $user = User::with('famille')->findOrFail($id);
        $user->makeHidden('password');
        return response()->json($user);
    }

    public function update(Request $request, $id)
    {
        // Seul le sous-admin peut modifier des utilisateurs (admin = observateur)
        $currentUser = $request->user();
        if (!$currentUser || $currentUser->role !== 'sous_admin') {
            return response()->json([
                'message' => 'Accès refusé. Seul le sous-administrateur peut modifier des utilisateurs.'
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
            'zone_suivi' => 'sometimes|nullable|string|max:500',
            'description' => 'sometimes|string',
            'profession' => 'sometimes|string',
            'entreprise' => 'sometimes|string',
            'role' => 'sometimes|string|in:admin,sous_admin,pasteur,famille,parrain,service_social,travailleur',
            'famille_id' => 'nullable|exists:users,id',
        ]);

        if (isset($validated['password'])) {
            $validated['password'] = Hash::make($validated['password']);
        }
        // Si le rôle devient ou reste parrain, conserver famille_id ; sinon le mettre à null
        if (array_key_exists('role', $validated) && $validated['role'] !== 'parrain') {
            $validated['famille_id'] = null;
        }

        $user->update($validated);
        $user->makeHidden('password');

        return response()->json($user);
    }

    public function destroy(Request $request, $id)
    {
        // Seul le sous-admin peut supprimer des utilisateurs (admin = observateur)
        $currentUser = $request->user();
        if (!$currentUser || $currentUser->role !== 'sous_admin') {
            return response()->json([
                'message' => 'Accès refusé. Seul le sous-administrateur peut supprimer des utilisateurs.'
            ], 403);
        }
        
        $user = User::findOrFail($id);
        $user->delete();

        return response()->json(['message' => 'Utilisateur supprimé avec succès']);
    }
}

