<?php

namespace App\Console\Commands;

use App\Models\Fidele;
use Illuminate\Console\Command;

class ImportFidelesCsvCommand extends Command
{
    protected $signature = 'fideles:import-csv
                            {file : Chemin vers le fichier CSV (ex: storage/app/Export_enroles.csv)}
                            {--dry-run : Afficher ce qui serait importé sans insérer}
                            {--delimiter=; : Délimiteur des champs (défaut: point-virgule)}
                            {--encoding= : Encodage du fichier (ex: Windows-1252). Détection auto si vide.}';

    protected $description = 'Importe les fidèles depuis un CSV exporté de l\'ancienne application (délimiteur ;)';

    public function handle(): int
    {
        $path = $this->argument('file');
        $dryRun = $this->option('dry-run');
        $delimiter = $this->option('delimiter');
        $encoding = $this->option('encoding');

        if (!is_file($path) || !is_readable($path)) {
            $this->error("Fichier introuvable ou illisible : {$path}");
            return self::FAILURE;
        }

        $this->info('Lecture du fichier : ' . realpath($path));
        $rows = $this->readCsv($path, $delimiter, $encoding);

        if (empty($rows)) {
            $this->warn('Aucune ligne de données trouvée.');
            return self::SUCCESS;
        }

        $header = array_shift($rows);
        $header = array_map(fn ($c) => trim((string) $c, " \t\"\r\n"), $header);
        $index = $this->mapHeaderToIndex($header);

        if ($index === null) {
            $this->error('En-têtes attendus non trouvés. Colonnes reçues : ' . implode(', ', $header));
            return self::FAILURE;
        }

        $bar = $this->output->createProgressBar(count($rows));
        $bar->start();

        $inserted = 0;
        $skipped = 0;
        $errors = [];

        foreach ($rows as $num => $rawRow) {
            $lineNum = $num + 2; // 1-based + header
            $row = $this->parseRow($rawRow, $delimiter);
            if (count($row) < 5) {
                $skipped++;
                $bar->advance();
                continue;
            }

            $data = $this->rowToFideleData($row, $index);
            if ($data === null) {
                $skipped++;
                $bar->advance();
                continue;
            }

            if (!$dryRun) {
                try {
                    Fidele::create($data);
                    $inserted++;
                } catch (\Throwable $e) {
                    $errors[] = "Ligne {$lineNum}: " . $e->getMessage();
                }
            } else {
                $inserted++;
            }
            $bar->advance();
        }

        $bar->finish();
        $this->newLine(2);

        $this->info("Lignes traitées : " . count($rows));
        $this->info(($dryRun ? 'Simulation : ' : '') . "{$inserted} fidèle(s) importé(s).");
        if ($skipped > 0) {
            $this->warn("{$skipped} ligne(s) ignorée(s).");
        }
        if (!empty($errors)) {
            foreach (array_slice($errors, 0, 10) as $err) {
                $this->error($err);
            }
            if (count($errors) > 10) {
                $this->error('... et ' . (count($errors) - 10) . ' autre(s) erreur(s).');
            }
        }

        return empty($errors) ? self::SUCCESS : self::FAILURE;
    }

    private function readCsv(string $path, string $delimiter, ?string $encoding = null): array
    {
        $raw = file_get_contents($path);
        if ($raw === false) {
            return [];
        }
        if ($encoding !== null && $encoding !== '') {
            $converted = @mb_convert_encoding($raw, 'UTF-8', $encoding);
            if ($converted !== false) {
                $raw = $converted;
            }
        } else {
            // Détection : si le fichier contient des caractères typiques Latin-1 mal interprétés en UTF-8, convertir depuis Windows-1252
            if (preg_match('/[\x80-\xFF]/', $raw) && !mb_check_encoding($raw, 'UTF-8')) {
                $converted = @mb_convert_encoding($raw, 'UTF-8', 'Windows-1252');
                if ($converted !== false) {
                    $raw = $converted;
                }
            }
        }
        $lines = preg_split('/\r\n|\r|\n/', $raw);
        if ($lines === false) {
            return [];
        }
        $out = [];
        foreach ($lines as $line) {
            $line = trim($line, "\r\n");
            if ($line === '') {
                continue;
            }
            $out[] = str_getcsv($line, $delimiter, '"', '');
        }
        return $out;
    }

    private function mapHeaderToIndex(array $header): ?array
    {
        $normalize = fn ($h) => strtoupper(trim(preg_replace('/[\s\'\']+/', ' ', (string) $h)));
        $normalizedHeader = array_map($normalize, $header);

        $wanted = [
            'ID', 'NOM', 'PRENOMS', 'CONTACTS', 'HABITATION', 'PROFESSION',
            'DATE DU BAPTEME DU SAINT ESPRIT',
            'DATE DU BAPTEME D EAU',  // D'EAU sans apostrophe après normalisation
            'FAMILLE', 'ENROLE LE',
        ];
        $index = [];
        foreach ($wanted as $col) {
            $key = $col;
            $normCol = $normalize($col);
            $pos = array_search($col, $header, true);
            if ($pos === false) {
                $pos = array_search($normCol, $normalizedHeader, true);
            }
            if ($pos === false && $col === 'DATE DU BAPTEME D EAU') {
                $pos = array_search('DATE DU BAPTEME D EAU', $normalizedHeader, true);
                if ($pos === false) {
                    foreach ($normalizedHeader as $i => $h) {
                        if (str_contains($h, 'BAPTEME') && str_contains($h, 'EAU') && !str_contains($h, 'ESPRIT')) {
                            $pos = $i;
                            break;
                        }
                    }
                }
            }
            $index[$key] = $pos !== false ? $pos : null;
        }
        if ($index['NOM'] === null || $index['PRENOMS'] === null) {
            return null;
        }
        return $index;
    }

    private function parseRow(array $rawRow, string $delimiter): array
    {
        return array_map(function ($cell) {
            $v = trim((string) $cell, " \t\"\r\n");
            return $v === '' ? null : $v;
        }, $rawRow);
    }

    private function rowToFideleData(array $row, array $index): ?array
    {
        $get = function (string $key) use ($row, $index) {
            $i = $index[$key] ?? null;
            if ($i === null) return null;
            return $row[$i] ?? null;
        };

        $nom = $get('NOM');
        $prenoms = $get('PRENOMS');
        if ($nom === null && $prenoms === null) {
            return null;
        }

        $dateBaptemeSaintEsprit = $this->parseDate($get('DATE DU BAPTEME DU SAINT ESPRIT'));
        $dateBaptemeEau = $this->parseDate($get('DATE DU BAPTEME D EAU'));
        $enroleLe = $this->parseEnroleDate($get('ENROLE LE'));

        return [
            'nom' => $nom ?? '',
            'prenoms' => $prenoms ?? '',
            'contacts' => $get('CONTACTS'),
            'lieu_residence' => $get('HABITATION'),
            'profession' => $get('PROFESSION'),
            'baptise_saint_esprit' => $dateBaptemeSaintEsprit ? true : null,
            'baptise_eau' => $dateBaptemeEau ? true : null,
            'date_arrivee' => $enroleLe,
            'statut' => 'fidele',
        ];
    }

    private function parseDate(?string $value): ?\DateTimeInterface
    {
        if ($value === null || $value === '' || str_starts_with((string) $value, '0000-00-00')) {
            return null;
        }
        try {
            $dt = \Carbon\Carbon::parse($value);
            return $dt->year > 1900 ? $dt : null;
        } catch (\Throwable $e) {
            return null;
        }
    }

    private function parseEnroleDate(?string $value): ?string
    {
        if ($value === null || $value === '') {
            return null;
        }
        $value = trim($value);
        $len = strlen($value);
        // Numéro de téléphone ou valeur aberrante (ex: "0758812192", "11", "3")
        if (preg_match('/^\d+$/', $value)) {
            if ($len >= 9 || $len <= 2) {
                return null;
            }
            if ($len === 8) {
                // DDMMYYYY
                $d = substr($value, 0, 2);
                $m = substr($value, 2, 2);
                $y = substr($value, 4, 4);
                if ((int) $y >= 1990 && (int) $y <= 2030 && (int) $m >= 1 && (int) $m <= 12 && (int) $d >= 1 && (int) $d <= 31) {
                    return sprintf('%04d-%02d-%02d', (int) $y, (int) $m, (int) $d);
                }
            }
            if ($len === 4) {
                $y = (int) $value;
                if ($y >= 1990 && $y <= 2030) {
                    return $value . '-01-01';
                }
            }
            // 3, 5, 6, 7 chiffres : ambigu (Carbon peut produire année -1)
            return null;
        }
        // AAAA-MM
        if (preg_match('/^\d{4}-\d{2}$/', $value)) {
            return $value . '-01';
        }
        // MM.AAAA ou MM/AAAA
        if (preg_match('/^(\d{1,2})[.\/](\d{4})$/', $value, $m)) {
            $month = (int) $m[1];
            $year = (int) $m[2];
            if ($month >= 1 && $month <= 12 && $year >= 1990 && $year <= 2030) {
                return sprintf('%04d-%02d-01', $year, $month);
            }
        }
        // AAAA uniquement
        if (preg_match('/^\d{4}$/', $value)) {
            $y = (int) $value;
            if ($y >= 1990 && $y <= 2030) {
                return $value . '-01-01';
            }
        }
        try {
            $dt = \Carbon\Carbon::parse($value);
            $y = (int) $dt->format('Y');
            // MySQL n'accepte pas les dates avant 1000 ni année négative
            if ($y < 1000 || $y > 2100) {
                return null;
            }
            return $dt->format('Y-m-d');
        } catch (\Throwable $e) {
            return null;
        }
    }
}
