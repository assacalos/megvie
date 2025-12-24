<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\FideleController;
use App\Http\Controllers\SuiviController;
use App\Http\Controllers\ActionController;
use App\Http\Controllers\PasteurController;
use App\Http\Controllers\FamilleController;
use App\Http\Controllers\ParrainController;
use App\Http\Controllers\ChefDiscController;
use App\Http\Controllers\CorpsMetierController;
use Illuminate\Support\Facades\Route;

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

    // Pasteurs
    Route::get('/pasteurs', [PasteurController::class, 'index']);
    Route::post('/pasteurs', [PasteurController::class, 'store']);

    // Familles
    Route::get('/familles', [FamilleController::class, 'index']);
    Route::post('/familles', [FamilleController::class, 'store']);

    // Parrains
    Route::get('/parrains', [ParrainController::class, 'index']);
    Route::post('/parrains', [ParrainController::class, 'store']);

    // Chef Disc
    Route::get('/chef-discs', [ChefDiscController::class, 'index']);
    Route::post('/chef-discs', [ChefDiscController::class, 'store']);

    // Corps de métiers
    Route::get('/corps-metiers', [CorpsMetierController::class, 'index']);
    Route::post('/corps-metiers', [CorpsMetierController::class, 'store']);
    Route::put('/corps-metiers/{id}', [CorpsMetierController::class, 'update']);
});

