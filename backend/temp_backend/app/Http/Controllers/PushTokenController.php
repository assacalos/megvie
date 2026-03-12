<?php

namespace App\Http\Controllers;

use App\Models\PushToken;
use Illuminate\Http\Request;

class PushTokenController extends Controller
{
    public function store(Request $request)
    {
        $user = $request->user();

        $validated = $request->validate([
            'token' => 'required|string|max:500',
            'platform' => 'nullable|in:android,ios',
            'device_info' => 'nullable|string|max:255',
        ]);

        $existing = PushToken::where('token', $validated['token'])->first();
        if ($existing) {
            $existing->update([
                'user_id' => $user?->id,
                'fidele_id' => $user?->fidele_id,
                'platform' => $validated['platform'] ?? null,
                'device_info' => $validated['device_info'] ?? null,
            ]);
            return response()->json($existing, 200);
        }

        $pt = PushToken::create([
            'user_id' => $user?->id,
            'fidele_id' => $user?->fidele_id,
            'token' => $validated['token'],
            'platform' => $validated['platform'] ?? null,
            'device_info' => $validated['device_info'] ?? null,
        ]);

        return response()->json($pt, 201);
    }

    public function destroy(Request $request)
    {
        $token = $request->input('token');
        if (! $token) {
            return response()->json(['message' => 'Token requis.'], 422);
        }
        PushToken::where('token', $token)->delete();
        return response()->json(['message' => 'Token supprimé.']);
    }
}
