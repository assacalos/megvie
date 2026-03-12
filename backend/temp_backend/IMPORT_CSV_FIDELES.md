# Import des fidèles depuis Export_enroles.csv

## Prérequis

- Fichier CSV exporté de l’ancienne application (délimiteur **point-virgule** `;`, champs entre guillemets).
- En-têtes attendus :  
  `ID`, `NOM`, `PRENOMS`, `CONTACTS`, `HABITATION`, `PROFESSION`,  
  `DATE DU BAPTEME DU SAINT ESPRIT`, `DATE DU BAPTEME D'EAU`, `FAMILLE`, `ENROLE LE`.

## Étapes

### 1. Copier le fichier CSV

Placez `Export_enroles.csv` dans le projet, par exemple :

```bash
# Depuis la racine du backend
copy "C:\chemin\vers\Export_enroles.csv" storage\app\Export_enroles.csv
```

Ou sous Linux/Mac :

```bash
cp /chemin/vers/Export_enroles.csv storage/app/Export_enroles.csv
```

### 2. Test sans écriture (recommandé)

Pour vérifier le parsing et le nombre de lignes qui seraient importées :

```bash
php artisan fideles:import-csv storage/app/Export_enroles.csv --dry-run
```

### 3. Lancer l’import

```bash
php artisan fideles:import-csv storage/app/Export_enroles.csv
```

Vous pouvez aussi indiquer un chemin absolu :

```bash
php artisan fideles:import-csv "C:\Users\...\Export_enroles.csv"
```

### 4. Options

| Option | Description |
|--------|-------------|
| `--dry-run` | Affiche le résultat sans insérer en base. |
| `--delimiter=;` | Délimiteur (défaut : `;`). |

Exemple avec un autre délimiteur :

```bash
php artisan fideles:import-csv storage/app/Export_enroles.csv --delimiter=","
```

## Mapping des colonnes CSV → base

| CSV | Champ en base | Remarque |
|-----|----------------|----------|
| NOM | `nom` | Trim des espaces. |
| PRENOMS | `prenoms` | Trim. |
| CONTACTS | `contacts` | Trim. |
| HABITATION | `lieu_residence` | Trim. |
| PROFESSION | `profession` | Trim. |
| DATE DU BAPTEME DU SAINT ESPRIT | `baptise_saint_esprit` | Si date valide (pas `0000-00-00`) → `true`, sinon `null`. |
| DATE DU BAPTEME D'EAU | `baptise_eau` | Même règle. |
| ENROLE LE | `date_arrivee` | Format `AAAA-MM` converti en `AAAA-MM-01`. |
| FAMILLE | — | Non importé (à lier manuellement si besoin). |
| ID | — | Non réutilisé ; les nouveaux enregistrements ont un nouvel ID. |

## Gestion des erreurs

- Les lignes sans NOM ni PRENOMS sont ignorées.
- Les dates `0000-00-00 00:00:00` sont traitées comme absentes (pas de baptême enregistré).
- Toute exception à l’insertion est affichée en fin d’exécution (au plus 10 erreurs détaillées).
- En cas d’erreur, la commande retourne un code d’échec (utile en script).

## Environ 1086 lignes

La commande lit le fichier ligne par ligne et insère en base. Pour ~1086 lignes, l’exécution reste rapide. En cas de fichier très volumineux, un import par lots (chunks) pourrait être ajouté plus tard.
