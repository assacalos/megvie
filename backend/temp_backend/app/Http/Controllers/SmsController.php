<?php

namespace App\Http\Controllers;

use App\Models\Fidele;
use App\Models\SmsLog;
use App\Services\SmsGatewayInterface;
use Illuminate\Http\Request;

class SmsController extends Controller
{
    public function __construct(
        protected SmsGatewayInterface $smsGateway
    ) {}

    /**
     * Envoi de SMS en masse à une liste de fidèles.
     * Body: { "fidele_ids": [1, 2, 3], "message": "Texte du SMS" }
     */
    public function sendBulk(Request $request)
    {
        $user = $request->user();
        if (! $user || ! in_array($user->role, ['sous_admin', 'pasteur'])) {
            return response()->json([
                'message' => 'Accès refusé. Droits insuffisants pour envoyer des SMS.',
            ], 403);
        }

        $validated = $request->validate([
            'fidele_ids' => 'required|array',
            'fidele_ids.*' => 'integer|exists:fideles,id',
            'message' => 'required|string|max:1600',
        ]);

        $fideleIds = $validated['fidele_ids'];
        $message = trim($validated['message']);

        if (empty($message)) {
            return response()->json(['message' => 'Le message ne peut pas être vide.'], 422);
        }

        $fideles = Fidele::whereIn('id', $fideleIds)->get();
        $phones = [];
        foreach ($fideles as $fidele) {
            $phone = $this->getPhoneFromFidele($fidele);
            if ($phone !== null && $phone !== '') {
                $phones[$fidele->id] = $phone;
            }
        }

        $sent = 0;
        $failed = 0;
        foreach ($phones as $fideleId => $to) {
            if ($this->smsGateway->send($to, $message)) {
                $sent++;
            } else {
                $failed++;
            }
        }

        $recipientCount = count($phones);
        $status = $failed === 0 ? 'sent' : ($sent === 0 ? 'failed' : 'partial');

        SmsLog::create([
            'user_id' => $user->id,
            'message' => $message,
            'recipient_count' => $recipientCount,
            'status' => $status,
        ]);

        return response()->json([
            'message' => 'Envoi terminé.',
            'recipient_count' => $recipientCount,
            'sent' => $sent,
            'failed' => $failed,
            'status' => $status,
            'skipped_no_phone' => count($fideleIds) - $recipientCount,
        ], 200);
    }

    /**
     * Récupère le numéro de téléphone du fidèle (contacts ou whatsapp).
     */
    protected function getPhoneFromFidele(Fidele $fidele): ?string
    {
        $raw = $fidele->contacts ?? $fidele->whatsapp ?? null;
        if ($raw === null || trim((string) $raw) === '') {
            return null;
        }
        $phone = preg_replace('/\s+/', '', (string) $raw);
        return $phone !== '' ? $phone : null;
    }
}
