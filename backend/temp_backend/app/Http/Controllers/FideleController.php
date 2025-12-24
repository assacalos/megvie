<?php

namespace App\Http\Controllers;

use App\Models\Fidele;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class FideleController extends Controller
{
    public function index(Request $request)
    {
        $query = Fidele::with(['parrain', 'pasteur', 'chefDisc', 'famille', 'corpsMetier']);

        // Recherche par texte
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('nom', 'like', "%{$search}%")
                  ->orWhere('prenoms', 'like', "%{$search}%")
                  ->orWhere('lieu_residence', 'like', "%{$search}%");
            });
        }

        // Filtre par tranche d'âge
        if ($request->has('tranche_age') && $request->tranche_age !== 'tous') {
            $query->where('tranche_age', $request->tranche_age);
        }

        // Filtre par date
        if ($request->has('date_debut')) {
            $query->where('date_arrivee', '>=', $request->date_debut);
        }
        if ($request->has('date_fin')) {
            $query->where('date_arrivee', '<=', $request->date_fin);
        }

        // Filtre par profession
        if ($request->has('corps_metier_id')) {
            $query->where('corps_metier_id', $request->corps_metier_id);
        }

        $fideles = $query->orderBy('created_at', 'desc')->paginate(20);

        return response()->json($fideles);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'nom' => 'required|string',
            'prenoms' => 'required|string',
            'tranche_age' => 'nullable|string',
            'lieu_residence' => 'nullable|string',
            'comment_connu' => 'nullable|string',
            'but_visite' => 'nullable|string',
            'qui_invite' => 'nullable|string',
            'frequente_eglise' => 'nullable|string',
            'souhaite_appartenir' => 'nullable|boolean',
            'date_arrivee' => 'nullable|date',
            'appartient_famille' => 'nullable|string',
            'statut' => 'nullable|in:fidele,nouvel_ame',
            'profession' => 'nullable|string',
            'photo' => 'nullable|image|max:2048',
            'facebook' => 'nullable|string',
            'contacts' => 'nullable|string',
            'whatsapp' => 'nullable|string',
            'instagram' => 'nullable|string',
            'email' => 'nullable|email',
            'parrain_id' => 'nullable|exists:parrains,id',
            'pasteur_id' => 'nullable|exists:pasteurs,id',
            'chef_disc_id' => 'nullable|exists:chef_discs,id',
            'famille_id' => 'nullable|exists:familles,id',
            'formation' => 'nullable|string',
            'annee_experience' => 'nullable|integer',
            'corps_metier_id' => 'nullable|exists:corps_metiers,id',
        ]);

        if ($request->hasFile('photo')) {
            $validated['photo'] = $request->file('photo')->store('photos', 'public');
        }

        // Convertir les valeurs booléennes
        if (isset($validated['souhaite_appartenir'])) {
            $validated['souhaite_appartenir'] = filter_var($validated['souhaite_appartenir'], FILTER_VALIDATE_BOOLEAN);
        }

        $fidele = Fidele::create($validated);

        return response()->json($fidele->load(['parrain', 'pasteur', 'chefDisc', 'famille', 'corpsMetier']), 201);
    }

    public function show($id)
    {
        $fidele = Fidele::with(['parrain', 'pasteur', 'chefDisc', 'famille', 'corpsMetier', 'suivis', 'actions'])
            ->findOrFail($id);

        return response()->json($fidele);
    }

    public function update(Request $request, $id)
    {
        $fidele = Fidele::findOrFail($id);

        $validated = $request->validate([
            'nom' => 'sometimes|string',
            'prenoms' => 'sometimes|string',
            'tranche_age' => 'nullable|string',
            'lieu_residence' => 'nullable|string',
            'profession' => 'nullable|string',
            'photo' => 'nullable|image|max:2048',
            'facebook' => 'nullable|string',
            'contacts' => 'nullable|string',
            'whatsapp' => 'nullable|string',
            'instagram' => 'nullable|string',
            'email' => 'nullable|email',
            'parrain_id' => 'nullable|exists:parrains,id',
            'pasteur_id' => 'nullable|exists:pasteurs,id',
            'chef_disc_id' => 'nullable|exists:chef_discs,id',
            'famille_id' => 'nullable|exists:familles,id',
            'formation' => 'nullable|string',
            'annee_experience' => 'nullable|integer',
            'corps_metier_id' => 'nullable|exists:corps_metiers,id',
        ]);

        if ($request->hasFile('photo')) {
            if ($fidele->photo) {
                Storage::disk('public')->delete($fidele->photo);
            }
            $validated['photo'] = $request->file('photo')->store('photos', 'public');
        }

        // Convertir les IDs en entiers si présents
        foreach (['parrain_id', 'pasteur_id', 'chef_disc_id', 'famille_id', 'corps_metier_id'] as $field) {
            if (isset($validated[$field]) && $validated[$field] === '') {
                $validated[$field] = null;
            }
        }

        $fidele->update($validated);

        return response()->json($fidele->fresh()->load(['parrain', 'pasteur', 'chefDisc', 'famille', 'corpsMetier']));
    }

    public function destroy($id)
    {
        $fidele = Fidele::findOrFail($id);
        
        if ($fidele->photo) {
            Storage::disk('public')->delete($fidele->photo);
        }
        
        $fidele->delete();

        return response()->json(['message' => 'Fidèle supprimé avec succès']);
    }

    public function stats()
    {
        $stats = [
            'total' => Fidele::count(),
            'fideles' => Fidele::where('statut', 'fidele')->count(),
            'nouvelles_ames' => Fidele::where('statut', 'nouvel_ame')->count(),
            'baptises' => 0, // À implémenter selon vos besoins
            'suivis' => Fidele::has('suivis')->count(),
        ];

        return response()->json($stats);
    }

    public function export()
    {
        $fideles = Fidele::with(['parrain', 'pasteur', 'famille', 'corpsMetier'])->get();

        return response()->json($fideles);
    }
}

