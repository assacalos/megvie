<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * Gateway SMS compatible Termii / Africa's Talking.
 * Utilise SMS_API_KEY et optionnellement SMS_API_URL dans .env.
 * Exemple .env:
 *   SMS_API_KEY=your_api_key
 *   SMS_API_URL=https://api.termii.com/api/sms/send  (ou URL Africa's Talking)
 */
class TermiiSmsGateway implements SmsGatewayInterface
{
    protected string $apiKey;
    protected ?string $apiUrl;

    public function __construct()
    {
        $this->apiKey = config('services.sms.api_key', '');
        $this->apiUrl = config('services.sms.api_url');
    }

    public function isConfigured(): bool
    {
        return ! empty($this->apiKey);
    }

    public function send(string $to, string $message): bool
    {
        if (! $this->isConfigured()) {
            Log::warning('SMS: API key not configured, skipping send');
            return false;
        }

        $to = $this->normalizePhone($to);
        if (empty($to)) {
            return false;
        }

        try {
            // Termii-style payload (à adapter selon l'API réelle)
            $payload = [
                'to' => $to,
                'sms' => $message,
                'api_key' => $this->apiKey,
            ];

            if ($this->apiUrl) {
                $response = Http::timeout(15)->post($this->apiUrl, $payload);
                if ($response->successful()) {
                    return true;
                }
                Log::warning('SMS send failed', ['to' => $to, 'response' => $response->body()]);
                return false;
            }

            // Pas d'URL configurée : mode simulation (log uniquement)
            Log::info('SMS (simulation)', ['to' => $to, 'message' => substr($message, 0, 50) . '...']);
            return true;
        } catch (\Throwable $e) {
            Log::error('SMS exception: ' . $e->getMessage(), ['to' => $to]);
            return false;
        }
    }

    protected function normalizePhone(string $phone): string
    {
        $phone = preg_replace('/\s+/', '', $phone);
        if (str_starts_with($phone, '00')) {
            $phone = '+' . substr($phone, 2);
        }
        if (strlen($phone) >= 8 && ! str_starts_with($phone, '+')) {
            $phone = '+228' . $phone; // Togo par défaut, à adapter
        }
        return $phone;
    }
}
