<?php

namespace App\Services;

interface SmsGatewayInterface
{
    /**
     * Envoie un SMS à un numéro.
     * @param string $to Numéro au format international (ex: +22890123456)
     * @param string $message Contenu du SMS
     * @return bool Succès ou échec
     */
    public function send(string $to, string $message): bool;

    /**
     * Vérifie si la clé API est configurée.
     */
    public function isConfigured(): bool;
}
