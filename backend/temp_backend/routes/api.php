<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\FideleController;
use App\Http\Controllers\SmsController;
use App\Http\Controllers\SuiviController;
use App\Http\Controllers\ActionController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\AnnonceController;
use App\Http\Controllers\DocumentController;
use App\Http\Controllers\OperationFinanciereController;
use App\Http\Controllers\RendezVousController;
use App\Http\Controllers\MediathequeItemController;
use App\Http\Controllers\RequetePriereController;
use App\Http\Controllers\TemoignageController;
use App\Http\Controllers\PushTokenController;
use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request;

// Routes publiques
Route::post('/login', [AuthController::class, 'login']);

// Routes protégées
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', [AuthController::class, 'user']);
    Route::post('/logout', [AuthController::class, 'logout']);

    // Mon espace fidèle (rôle fidèle)
    Route::get('/me/fidele', [FideleController::class, 'meFidele']);

    // Fidèles
    Route::get('/fideles', [FideleController::class, 'index']);
    Route::post('/fideles', [FideleController::class, 'store']);
    Route::get('/fideles/stats', [FideleController::class, 'stats']);
    Route::get('/fideles/export', [FideleController::class, 'export']);
    Route::get('/fideles/{id}', [FideleController::class, 'show']);
    Route::post('/fideles/{id}', [FideleController::class, 'update']); // POST pour accepter FormData
    Route::put('/fideles/{id}', [FideleController::class, 'update']);
    Route::delete('/fideles/{id}', [FideleController::class, 'destroy']);

    // SMS en masse (protégé Sanctum)
    Route::post('/send-bulk-sms', [SmsController::class, 'sendBulk']);

    // Suivis
    Route::post('/suivis', [SuiviController::class, 'store']);
    Route::put('/suivis/{id}', [SuiviController::class, 'update']);
    Route::delete('/suivis/{id}', [SuiviController::class, 'destroy']);

    // Actions
    Route::post('/actions', [ActionController::class, 'store']);
    Route::put('/actions/{id}', [ActionController::class, 'update']);
    Route::delete('/actions/{id}', [ActionController::class, 'destroy']);

    // Annonces / actualités (autres rôles + fidèles peuvent interagir / partager ; fidèles peuvent créer des actualités)
    Route::get('/annonces', [AnnonceController::class, 'index']);
    Route::post('/annonces', [AnnonceController::class, 'store']);
    Route::get('/annonces/{id}/comments', [AnnonceController::class, 'comments']);
    Route::post('/annonces/{id}/like', [AnnonceController::class, 'like']);
    Route::post('/annonces/{id}/comment', [AnnonceController::class, 'comment']);
    Route::post('/annonces/{id}/partager', [AnnonceController::class, 'partager']);
    Route::get('/annonces/{id}', [AnnonceController::class, 'show']);
    Route::put('/annonces/{id}', [AnnonceController::class, 'update']);
    Route::delete('/annonces/{id}', [AnnonceController::class, 'destroy']);

    // Documents
    Route::get('/documents', [DocumentController::class, 'index']);
    Route::post('/documents', [DocumentController::class, 'store']);
    Route::get('/documents/{id}/download', [DocumentController::class, 'download']);
    Route::get('/documents/{id}', [DocumentController::class, 'show']);
    Route::delete('/documents/{id}', [DocumentController::class, 'destroy']);

    // Opérations financières (dîmes / offrandes)
    Route::get('/operations-financieres', [OperationFinanciereController::class, 'index']);
    Route::post('/operations-financieres', [OperationFinanciereController::class, 'store']);
    Route::get('/operations-financieres/stats', [OperationFinanciereController::class, 'stats']);
    Route::get('/operations-financieres/{id}', [OperationFinanciereController::class, 'show']);
    Route::delete('/operations-financieres/{id}', [OperationFinanciereController::class, 'destroy']);

    // Rendez-vous / prière
    Route::get('/rendez-vous', [RendezVousController::class, 'index']);
    Route::post('/rendez-vous', [RendezVousController::class, 'store']);
    Route::get('/rendez-vous/{id}', [RendezVousController::class, 'show']);
    Route::put('/rendez-vous/{id}', [RendezVousController::class, 'update']);
    Route::delete('/rendez-vous/{id}', [RendezVousController::class, 'destroy']);

    // Médiathèque spirituelle
    Route::get('/mediatheque', [MediathequeItemController::class, 'index']);
    Route::post('/mediatheque', [MediathequeItemController::class, 'store']);
    Route::get('/mediatheque/{id}', [MediathequeItemController::class, 'show']);
    Route::put('/mediatheque/{id}', [MediathequeItemController::class, 'update']);
    Route::delete('/mediatheque/{id}', [MediathequeItemController::class, 'destroy']);

    // Requêtes de prière
    Route::get('/requetes-priere', [RequetePriereController::class, 'index']);
    Route::post('/requetes-priere', [RequetePriereController::class, 'store']);
    Route::get('/requetes-priere/{id}', [RequetePriereController::class, 'show']);
    Route::put('/requetes-priere/{id}', [RequetePriereController::class, 'update']);
    Route::delete('/requetes-priere/{id}', [RequetePriereController::class, 'destroy']);

    // Témoignages
    Route::get('/temoignages', [TemoignageController::class, 'index']);
    Route::post('/temoignages', [TemoignageController::class, 'store']);
    Route::get('/temoignages/{id}', [TemoignageController::class, 'show']);
    Route::put('/temoignages/{id}', [TemoignageController::class, 'update']);
    Route::delete('/temoignages/{id}', [TemoignageController::class, 'destroy']);

    // Notifications push (enregistrement du token)
    Route::post('/push-tokens', [PushTokenController::class, 'store']);
    Route::delete('/push-tokens', [PushTokenController::class, 'destroy']);

    // Utilisateurs
    Route::get('/users', [UserController::class, 'index']); // Peut filtrer par ?role=pasteur
    Route::post('/users', [UserController::class, 'store']);
    Route::get('/users/{id}', [UserController::class, 'show']);
    Route::put('/users/{id}', [UserController::class, 'update']);
    Route::delete('/users/{id}', [UserController::class, 'destroy']);
    
    // Routes de compatibilité (redirigent vers /users avec filtre)
    Route::get('/pasteurs', function (Request $request) {
        $controller = new UserController();
        return $controller->index($request->merge(['role' => 'pasteur']));
    });
    Route::get('/familles', function (Request $request) {
        $controller = new UserController();
        return $controller->index($request->merge(['role' => 'famille']));
    });
    Route::get('/parrains', function (Request $request) {
        $controller = new UserController();
        return $controller->index($request->merge(['role' => 'parrain']));
    });
    Route::get('/service-sociaux', function (Request $request) {
        $controller = new UserController();
        return $controller->index($request->merge(['role' => 'service_social']));
    });
    Route::get('/travailleurs', function (Request $request) {
        $controller = new UserController();
        return $controller->index($request->merge(['role' => 'travailleur']));
    });
});

