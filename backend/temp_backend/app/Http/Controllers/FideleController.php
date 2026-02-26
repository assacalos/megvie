<?php

namespace App\Http\Controllers;

use App\Models\Fidele;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class FideleController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user(); // Utilisateur connecté
        $query = Fidele::with(['parrain', 'pasteur', 'chefDisc', 'famille', 'corpsMetier']);

        // Filtrer selon le rôle de l'utilisateur connecté
        if ($user) {
            $role = $user->role;
            
            switch ($role) {
                case 'admin':
                case 'sous_admin':
                case 'service_social':
                    // Administrateurs et services sociaux voient tous les fidèles
                    break;
                    
                case 'famille':
                    // Les familles voient uniquement les fidèles de leur famille
                    $query->where('famille_id', $user->id);
                    break;
                    
                case 'parrain':
                    // Les parrains voient uniquement les fidèles qu'ils parrainent
                    $query->where('parrain_id', $user->id);
                    break;
                    
                case 'pasteur':
                    // Les pasteurs voient les fidèles assignés (pasteur_id) OU dont le lieu d'habitation
                    // correspond à au moins un quartier de leur zone de suivi
                    $query->where(function ($q) use ($user) {
                        $q->where('pasteur_id', $user->id);
                        if (!empty(trim($user->zone_suivi ?? ''))) {
                            $quartiers = array_filter(array_map('trim', explode(',', $user->zone_suivi)));
                            foreach ($quartiers as $quartier) {
                                if ($quartier !== '') {
                                    $q->orWhereRaw('LOWER(lieu_residence) LIKE ?', ['%' . mb_strtolower($quartier) . '%']);
                                }
                            }
                        }
                    });
                    break;
            }
        }

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
        // Admin = observateur uniquement : pas de création
        if ($request->user()?->role === 'admin') {
            return response()->json(['message' => 'Accès refusé. L\'administrateur est en mode observateur.'], 403);
        }

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
            'appartient_famille' => 'nullable|boolean',
            'statut' => 'nullable|in:fidele,nouvel_ame',
            'profession' => 'nullable|string',
            'photo' => 'nullable|image|max:2048',
            'facebook' => 'nullable|string',
            'contacts' => 'nullable|string',
            'whatsapp' => 'nullable|string',
            'instagram' => 'nullable|string',
            'email' => 'nullable|email',
            'parrain_id' => 'nullable|exists:users,id',
            'pasteur_id' => 'nullable|exists:users,id',
            'chef_disc_id' => 'nullable|exists:users,id',
            'famille_id' => 'nullable|exists:users,id',
            'famille_mois' => 'nullable|string|max:50',
            'formation' => 'nullable|string',
            'annee_experience' => 'nullable|integer',
            'corps_metier_id' => 'nullable|exists:users,id',
            'baptise_eau' => 'nullable|boolean',
            'baptise_saint_esprit' => 'nullable|boolean',
            'cure_d_ame' => 'nullable|boolean',
            'delivrance' => 'nullable|boolean',
            'mariage' => 'nullable|boolean',
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
        // Admin = observateur uniquement : pas de modification
        if ($request->user()?->role === 'admin') {
            return response()->json(['message' => 'Accès refusé. L\'administrateur est en mode observateur.'], 403);
        }

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
            'parrain_id' => 'nullable|exists:users,id',
            'pasteur_id' => 'nullable|exists:users,id',
            'chef_disc_id' => 'nullable|exists:users,id',
            'famille_id' => 'nullable|exists:users,id',
            'famille_mois' => 'nullable|string|max:50',
            'formation' => 'nullable|string',
            'annee_experience' => 'nullable|integer',
            'corps_metier_id' => 'nullable|exists:users,id',
            'baptise_eau' => 'nullable|boolean',
            'baptise_saint_esprit' => 'nullable|boolean',
            'cure_d_ame' => 'nullable|boolean',
            'delivrance' => 'nullable|boolean',
            'mariage' => 'nullable|boolean',
        ]);

        if ($request->hasFile('photo')) {
            if ($fidele->photo) {
                Storage::disk('public')->delete($fidele->photo);
            }
            $validated['photo'] = $request->file('photo')->store('photos', 'public');
        }

        // Convertir les booléens baptême et pasteur
        foreach (['baptise_eau', 'baptise_saint_esprit', 'cure_d_ame', 'delivrance', 'mariage'] as $field) {
            if (array_key_exists($field, $validated) && $validated[$field] !== null) {
                $validated[$field] = filter_var($validated[$field], FILTER_VALIDATE_BOOLEAN);
            }
        }

        // Convertir les IDs en entiers si présents
        foreach (['parrain_id', 'pasteur_id', 'chef_disc_id', 'famille_id', 'corps_metier_id'] as $field) {
            if (isset($validated[$field]) && $validated[$field] === '') {
                $validated[$field] = null;
            }
        }

        // Dates de mise à jour selon les champs modifiés
        $now = now();
        $validated['date_derniere_mise_a_jour'] = $now;
        $pasteurFields = ['baptise_eau', 'baptise_saint_esprit', 'cure_d_ame', 'delivrance', 'mariage'];
        $parrainageFields = ['parrain_id', 'pasteur_id', 'famille_id'];
        $socioProFields = ['formation', 'annee_experience', 'corps_metier_id'];
        if (count(array_intersect_key(array_flip($pasteurFields), $validated)) > 0) {
            $validated['date_mise_a_jour_pasteur'] = $now;
        }
        if (count(array_intersect_key(array_flip($parrainageFields), $validated)) > 0) {
            $validated['date_mise_a_jour_parrainage'] = $now;
        }
        if (count(array_intersect_key(array_flip($socioProFields), $validated)) > 0) {
            $validated['date_mise_a_jour_socio_pro'] = $now;
        }

        $fidele->update($validated);

        return response()->json($fidele->fresh()->load(['parrain', 'pasteur', 'chefDisc', 'famille', 'corpsMetier']));
    }

    public function destroy($id)
    {
        // Admin = observateur uniquement : pas de suppression
        $user = request()->user();
        if ($user && $user->role === 'admin') {
            return response()->json(['message' => 'Accès refusé. L\'administrateur est en mode observateur.'], 403);
        }

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
            'sans_famille' => Fidele::where(function ($q) {
                $q->whereNull('famille_mois')->orWhere('famille_mois', '');
            })->count(),
            'sans_parrain' => Fidele::whereNull('parrain_id')->count(),
            'sans_pasteur' => Fidele::whereNull('pasteur_id')->count(),
        ];

        return response()->json($stats);
    }

    public function export()
    {
        $fideles = Fidele::with(['parrain', 'pasteur', 'famille', 'corpsMetier'])->get();

        return response()->json($fideles);
    }
}

