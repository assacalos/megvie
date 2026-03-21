<?php

namespace App\Http\Controllers;

use App\Models\Annonce;
use App\Models\AnnonceComment;
use App\Models\AnnonceLike;
use App\Models\AnnoncePartage;
use Illuminate\Http\Request;

class AnnonceController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $query = Annonce::with('createdBy')
            ->withCount(['likes', 'comments', 'partages'])
            ->orderByDesc('is_pinned')
            ->orderByDesc('date_publication');

        if ($user && $user->role === 'fidele') {
            $query->where('date_publication', '<=', now()->toDateString());
            $query->where(function ($q) {
                $q->whereNull('date_fin_affichage')->orWhere('date_fin_affichage', '>=', now()->toDateString());
            });
        }

        if ($request->has('type')) {
            $query->where('type', $request->type);
        }

        $perPage = $request->input('per_page', 20);
        $paginator = $query->paginate($perPage);
        $userId = $user?->id;

        $paginator->getCollection()->transform(function ($annonce) use ($userId) {
            $a = $annonce->toArray();
            $a['user_has_liked'] = $userId ? AnnonceLike::where('annonce_id', $annonce->id)->where('user_id', $userId)->exists() : false;
            $a['user_has_shared'] = $userId ? AnnoncePartage::where('annonce_id', $annonce->id)->where('user_id', $userId)->exists() : false;
            return $a;
        });

        return response()->json($paginator);
    }

    public function store(Request $request)
    {
        $user = $request->user();
        $isFidele = $user && $user->role === 'fidele';

        if ($isFidele) {
            $request->validate(['type' => 'required|in:actualite']);
        }

        $validated = $request->validate([
            'titre' => 'required|string|max:255',
            'contenu' => 'required|string',
            'type' => 'nullable|in:annonce,actualite',
            'date_publication' => 'nullable|date',
            'date_fin_affichage' => 'nullable|date|after_or_equal:date_publication',
            'is_pinned' => 'nullable|boolean',
        ]);

        if ($isFidele) {
            $validated['type'] = 'actualite';
            $validated['is_pinned'] = false;
        } elseif (! isset($validated['type'])) {
            $validated['type'] = 'annonce';
        }

        $validated['date_publication'] = $validated['date_publication'] ?? now()->toDateString();
        $validated['created_by'] = $user?->id;

        $annonce = Annonce::create($validated);
        $annonce->load('createdBy');
        $annonce->loadCount(['likes', 'comments', 'partages']);
        $data = $annonce->toArray();
        $data['user_has_liked'] = false;
        $data['user_has_shared'] = false;
        return response()->json($data, 201);
    }

    public function show(Request $request, $id)
    {
        $annonce = Annonce::with('createdBy')
            ->withCount(['likes', 'comments', 'partages'])
            ->findOrFail($id);

        $user = $request->user();
        if ($user && $user->role === 'fidele') {
            if ($annonce->date_publication->isFuture() ||
                ($annonce->date_fin_affichage && $annonce->date_fin_affichage->isPast())) {
                return response()->json(['message' => 'Annonce non disponible.'], 404);
            }
        }

        $annonce->load(['comments' => fn ($q) => $q->with('user')]);
        $data = $annonce->toArray();
        $data['user_has_liked'] = $user ? AnnonceLike::where('annonce_id', $id)->where('user_id', $user->id)->exists() : false;
        $data['user_has_shared'] = $user ? AnnoncePartage::where('annonce_id', $id)->where('user_id', $user->id)->exists() : false;

        return response()->json($data);
    }

    public function update(Request $request, $id)
    {
        $annonce = Annonce::findOrFail($id);
        $user = $request->user();

        if ($user && $user->role === 'fidele') {
            if ($annonce->created_by != $user->id || $annonce->type !== 'actualite') {
                return response()->json(['message' => 'Accès refusé.'], 403);
            }
        } elseif ($this->isFidele($request)) {
            return response()->json(['message' => 'Accès refusé.'], 403);
        }

        $validated = $request->validate([
            'titre' => 'sometimes|string|max:255',
            'contenu' => 'sometimes|string',
            'type' => 'sometimes|in:annonce,actualite',
            'date_publication' => 'sometimes|date',
            'date_fin_affichage' => 'nullable|date',
            'is_pinned' => 'sometimes|boolean',
        ]);

        if ($user && $user->role === 'fidele') {
            unset($validated['type'], $validated['is_pinned']);
        }

        $annonce->update($validated);
        $fresh = $annonce->fresh()->load('createdBy');
        $fresh->loadCount(['likes', 'comments', 'partages']);
        $data = $fresh->toArray();
        $data['user_has_liked'] = $user ? AnnonceLike::where('annonce_id', $id)->where('user_id', $user->id)->exists() : false;
        $data['user_has_shared'] = $user ? AnnoncePartage::where('annonce_id', $id)->where('user_id', $user->id)->exists() : false;
        return response()->json($data);
    }

    public function destroy(Request $request, $id)
    {
        $annonce = Annonce::findOrFail($id);
        $user = $request->user();

        if ($user && $user->role === 'fidele') {
            if ($annonce->created_by != $user->id || $annonce->type !== 'actualite') {
                return response()->json(['message' => 'Accès refusé.'], 403);
            }
        } elseif ($this->isFidele($request)) {
            return response()->json(['message' => 'Accès refusé.'], 403);
        }

        $annonce->delete();
        return response()->json(['message' => 'Annonce supprimée.']);
    }

    /** Toggle like pour l'utilisateur connecté (fidèle ou autre). */
    public function like(Request $request, $id)
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Non authentifié.'], 401);
        }
        $annonce = Annonce::findOrFail($id);
        if ($user->role === 'fidele') {
            if ($annonce->date_publication->isFuture() || ($annonce->date_fin_affichage && $annonce->date_fin_affichage->isPast())) {
                return response()->json(['message' => 'Annonce non disponible.'], 404);
            }
        }
        $like = AnnonceLike::where('annonce_id', $id)->where('user_id', $user->id)->first();
        if ($like) {
            $like->delete();
            $liked = false;
        } else {
            AnnonceLike::create(['annonce_id' => $id, 'user_id' => $user->id]);
            $liked = true;
        }
        $count = AnnonceLike::where('annonce_id', $id)->count();
        return response()->json(['liked' => $liked, 'likes_count' => $count]);
    }

    /** Ajouter un commentaire (fidèle ou autre rôle). */
    public function comment(Request $request, $id)
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Non authentifié.'], 401);
        }
        $annonce = Annonce::findOrFail($id);
        if ($user->role === 'fidele') {
            if ($annonce->date_publication->isFuture() || ($annonce->date_fin_affichage && $annonce->date_fin_affichage->isPast())) {
                return response()->json(['message' => 'Annonce non disponible.'], 404);
            }
        }
        $validated = $request->validate(['contenu' => 'required|string|max:2000']);
        $c = AnnonceComment::create([
            'annonce_id' => $id,
            'user_id' => $user->id,
            'contenu' => $validated['contenu'],
        ]);
        $c->load('user');
        return response()->json($c, 201);
    }

    /** Marquer comme partagé par l'utilisateur (idempotent). */
    public function partager(Request $request, $id)
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Non authentifié.'], 401);
        }
        $annonce = Annonce::findOrFail($id);
        if ($user->role === 'fidele') {
            if ($annonce->date_publication->isFuture() || ($annonce->date_fin_affichage && $annonce->date_fin_affichage->isPast())) {
                return response()->json(['message' => 'Annonce non disponible.'], 404);
            }
        }
        AnnoncePartage::firstOrCreate(['annonce_id' => $id, 'user_id' => $user->id]);
        $count = AnnoncePartage::where('annonce_id', $id)->count();
        return response()->json(['shared' => true, 'partages_count' => $count]);
    }

    /** Liste des commentaires d'une annonce (pour rafraîchissement). */
    public function comments(Request $request, $id)
    {
        $annonce = Annonce::findOrFail($id);
        $user = $request->user();
        if ($user && $user->role === 'fidele') {
            if ($annonce->date_publication->isFuture() || ($annonce->date_fin_affichage && $annonce->date_fin_affichage->isPast())) {
                return response()->json(['message' => 'Annonce non disponible.'], 404);
            }
        }
        $comments = AnnonceComment::where('annonce_id', $id)->with('user')->orderBy('created_at')->get();
        return response()->json($comments);
    }

    private function isFidele(Request $request): bool
    {
        return $request->user()?->role === 'fidele';
    }
}
