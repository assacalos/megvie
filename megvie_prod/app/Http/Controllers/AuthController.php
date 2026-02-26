<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        try {
            Log::info('=== DÉBUT LOGIN ===');
            Log::info('Requête reçue:', [
                'email' => $request->email,
                'has_password' => !empty($request->password),
                'type_connexion' => $request->type_connexion,
                'all_data' => $request->all(),
            ]);

            $request->validate([
                'email' => 'required|email',
                'password' => 'required',
                'type_connexion' => 'nullable|string',
            ]);

            Log::info('Validation réussie');

            $user = User::where('email', $request->email)->first();

            Log::info('Utilisateur recherché:', [
                'user_found' => $user !== null,
                'user_id' => $user?->id,
                'user_email' => $user?->email,
            ]);

            if (!$user) {
                Log::warning('Utilisateur non trouvé:', ['email' => $request->email]);
                throw ValidationException::withMessages([
                    'email' => ['Les identifiants fournis sont incorrects.'],
                ]);
            }

            $passwordCheck = Hash::check($request->password, $user->password);
            Log::info('Vérification du mot de passe:', ['password_valid' => $passwordCheck]);

            if (!$passwordCheck) {
                Log::warning('Mot de passe incorrect pour:', ['email' => $request->email]);
                throw ValidationException::withMessages([
                    'email' => ['Les identifiants fournis sont incorrects.'],
                ]);
            }

            Log::info('Création du token...');
            $token = $user->createToken('auth-token')->plainTextToken;
            Log::info('Token créé avec succès');

            $response = [
                'user' => $user,
                'token' => $token,
            ];

            Log::info('Réponse de login:', [
                'user_id' => $user->id,
                'token_length' => strlen($token),
            ]);
            Log::info('=== FIN LOGIN (SUCCÈS) ===');

            return response()->json($response);
        } catch (ValidationException $e) {
            Log::error('Erreur de validation:', [
                'errors' => $e->errors(),
            ]);
            throw $e;
        } catch (\Exception $e) {
            Log::error('=== ERREUR LOGIN ===');
            Log::error('Message:', ['message' => $e->getMessage()]);
            Log::error('Fichier:', ['file' => $e->getFile()]);
            Log::error('Ligne:', ['line' => $e->getLine()]);
            Log::error('Trace:', ['trace' => $e->getTraceAsString()]);
            Log::error('=== FIN ERREUR LOGIN ===');

            return response()->json([
                'error' => 'Erreur serveur lors de la connexion',
                'message' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
            ], 500);
        }
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Déconnexion réussie']);
    }

    public function user(Request $request)
    {
        return response()->json($request->user());
    }
}

