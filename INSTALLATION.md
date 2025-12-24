# Guide d'Installation - MEG-VIE

## Prérequis

- PHP >= 8.1
- Composer
- MySQL/PostgreSQL
- Flutter SDK >= 3.0.0
- Node.js (optionnel, pour les assets)

## Installation du Backend (Laravel)

1. Naviguez vers le dossier backend :
```bash
cd backend
```

2. Installez les dépendances PHP :
```bash
composer install
```

3. Copiez le fichier d'environnement :
```bash
cp .env.example .env
```

4. Générez la clé d'application :
```bash
php artisan key:generate
```

5. Configurez votre base de données dans le fichier `.env` :
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=megvie
DB_USERNAME=root
DB_PASSWORD=votre_mot_de_passe
```

6. Créez la base de données :
```sql
CREATE DATABASE megvie;
```

7. Exécutez les migrations :
```bash
php artisan migrate
```

8. (Optionnel) Créez un utilisateur de test :
```bash
php artisan tinker
```
Puis dans tinker :
```php
$user = new App\Models\User();
$user->name = 'Admin';
$user->email = 'admin@megvie.org';
$user->password = Hash::make('password');
$user->role = 'admin';
$user->save();
```

9. Démarrez le serveur de développement :
```bash
php artisan serve
```

Le backend sera accessible sur `http://localhost:8000`

## Installation du Frontend (Flutter)

1. Naviguez vers le dossier frontend :
```bash
cd frontend
```

2. Installez les dépendances Flutter :
```bash
flutter pub get
```

3. Configurez l'URL de l'API dans `lib/main.dart` :
```dart
ApiService().init('http://localhost:8000');
```

4. Pour le web :
```bash
flutter run -d chrome
```

5. Pour Android :
```bash
flutter run
```

6. Pour iOS (sur Mac uniquement) :
```bash
flutter run -d ios
```

## Configuration CORS

Si vous rencontrez des problèmes CORS, assurez-vous que le middleware CORS est bien configuré dans `backend/app/Http/Middleware/Cors.php` et que les routes API sont correctement configurées.

## Structure des dossiers

```
MEGVIE/
├── backend/          # Application Laravel
│   ├── app/
│   ├── database/
│   ├── routes/
│   └── ...
├── frontend/         # Application Flutter
│   ├── lib/
│   ├── assets/
│   └── ...
└── README.md
```

## Prochaines étapes

1. Configurez le stockage des fichiers (photos) dans Laravel
2. Ajoutez la gestion des permissions et rôles
3. Implémentez l'export de données
4. Ajoutez les tests unitaires et d'intégration
5. Configurez le déploiement

