<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\FideleController;
use App\Http\Controllers\SuiviController;
use App\Http\Controllers\ActionController;
use App\Http\Controllers\UserController;
use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request;

// Routes publiques
Route::post('/login', [AuthController::class, 'login']);

// Routes protégées
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', [AuthController::class, 'user']);
    Route::post('/logout', [AuthController::class, 'logout']);

    // Fidèles
    Route::get('/fideles', [FideleController::class, 'index']);
    Route::post('/fideles', [FideleController::class, 'store']);
    Route::get('/fideles/stats', [FideleController::class, 'stats']);
    Route::get('/fideles/export', [FideleController::class, 'export']);
    Route::get('/fideles/{id}', [FideleController::class, 'show']);
    Route::post('/fideles/{id}', [FideleController::class, 'update']); // POST pour accepter FormData
    Route::put('/fideles/{id}', [FideleController::class, 'update']);
    Route::delete('/fideles/{id}', [FideleController::class, 'destroy']);

    // Suivis
    Route::post('/suivis', [SuiviController::class, 'store']);
    Route::put('/suivis/{id}', [SuiviController::class, 'update']);
    Route::delete('/suivis/{id}', [SuiviController::class, 'destroy']);

    // Actions
    Route::post('/actions', [ActionController::class, 'store']);
    Route::put('/actions/{id}', [ActionController::class, 'update']);
    Route::delete('/actions/{id}', [ActionController::class, 'destroy']);

    // Utilisateurs (Tous les rôles : admin, pasteur, famille, parrain, service_social, travailleur)
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

