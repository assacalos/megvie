# MEG-VIE - Application de Gestion des Fidèles

cd
## Structure du Projet

- `backend/` - Application Laravel (API REST)
- `frontend/` - Application Flutter (Mobile & Web)

## Technologies

- **Backend**: Laravel 10+
- **Frontend**: Flutter 3.x
- **Base de données**: MySQL/PostgreSQL

## Installation

### Backend (Laravel)

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan serve
```

### Frontend (Flutter)

```bash
cd frontend
flutter pub get
flutter run
```

## Fonctionnalités

- Authentification
- Gestion des fidèles (enregistrement, liste, détails, mise à jour)
- Gestion des pasteurs
- Gestion des familles
- Gestion des parrains
- Suivi des fidèles
- Gestion des professions/corps de métiers
- Suivi socio-professionnel
- Export de données

