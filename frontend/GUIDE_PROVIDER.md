# 📚 Guide Complet : Comment Provider Fonctionne dans Flutter

## 🎯 Introduction

Provider est un système de **gestion d'état** pour Flutter. Il permet de partager des données entre plusieurs écrans sans avoir à les passer manuellement.

---

## 1️⃣ Les Concepts de Base

### Qu'est-ce qu'un Provider ?

Un **Provider** est comme un **magasin centralisé** où vous stockez des données accessibles partout dans votre application.

**Analogie** : Imaginez un tableau d'affichage dans une école. Tous les élèves peuvent le voir et le mettre à jour. C'est exactement ce que fait Provider !

### Qu'est-ce que ChangeNotifier ?

`ChangeNotifier` est une classe qui permet de **notifier** tous les widgets qui écoutent quand les données changent.

```dart
class AuthProvider with ChangeNotifier {
  // Les données privées (commencent par _)
  User? _user;
  bool _isLoading = false;
  
  // Les getters publics (pour lire les données)
  User? get user => _user;
  bool get isLoading => _isLoading;
  
  // Quand on change les données, on appelle notifyListeners()
  void updateUser(User newUser) {
    _user = newUser;
    notifyListeners(); // ⚠️ IMPORTANT : Dit à tous les widgets d'écouter de se mettre à jour
  }
}
```

---

## 2️⃣ Structure de Votre Projet

Vous avez **3 Providers** dans votre projet :

### 📦 AuthProvider
**Rôle** : Gère l'authentification (connexion, déconnexion, utilisateur connecté)

**Données stockées** :
- `_user` : L'utilisateur connecté
- `_token` : Le token d'authentification
- `_isLoading` : Si une opération est en cours
- `_error` : Les messages d'erreur

### 📦 FideleProvider
**Rôle** : Gère les fidèles (liste, création, modification, suppression)

**Données stockées** :
- `_fideles` : Liste de tous les fidèles
- `_selectedFidele` : Le fidèle actuellement sélectionné
- `_isLoading` : Si une opération est en cours
- `_stats` : Les statistiques

### 📦 ReferenceProvider
**Rôle** : Gère les données de référence (pasteurs, familles, parrains, etc.)

**Données stockées** :
- `_parrains` : Liste des parrains
- `_pasteurs` : Liste des pasteurs
- `_familles` : Liste des familles
- etc.

---

## 3️⃣ Comment Provider est Configuré

### Étape 1 : Enregistrement des Providers

Dans `main.dart`, vous enregistrez tous vos providers :

```dart
return MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => FideleProvider()),
    ChangeNotifierProvider(create: (_) => ReferenceProvider()),
  ],
  child: MaterialApp.router(...),
);
```

**Explication** :
- `MultiProvider` : Permet d'enregistrer plusieurs providers
- `ChangeNotifierProvider` : Crée une instance de votre provider
- `create: (_) => AuthProvider()` : Crée une nouvelle instance quand c'est nécessaire

**Résultat** : Tous les widgets de votre app peuvent maintenant accéder à ces providers !

---

## 4️⃣ Comment Utiliser Provider dans un Écran

### Méthode 1 : `Provider.of<T>(context)`

**Quand l'utiliser** : Quand vous voulez **lire** les données OU **appeler une méthode** sans écouter les changements.

**Exemple dans `login_screen.dart`** :

```dart
Future<void> _handleLogin() async {
  // Récupère le AuthProvider (sans écouter les changements)
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  
  // Appelle la méthode login
  final success = await authProvider.login(
    _emailController.text.trim(),
    _passwordController.text,
  );
  
  if (success) {
    context.go('/dashboard');
  }
}
```

**Points importants** :
- `listen: false` : Ne se met PAS à jour automatiquement quand les données changent
- Utilisé pour **appeler des méthodes** (login, logout, etc.)

### Méthode 2 : `Provider.of<T>(context)` SANS `listen: false`

**Quand l'utiliser** : Quand vous voulez **lire** les données ET **écouter les changements**.

**Exemple dans `dashboard_screen.dart`** :

```dart
@override
Widget build(BuildContext context) {
  // Récupère le AuthProvider ET écoute les changements
  final authProvider = Provider.of<AuthProvider>(context);
  
  return Scaffold(
    body: Text('Bienvenue ${authProvider.user?.name ?? ''}'),
    // Si authProvider.user change, ce widget se mettra à jour automatiquement !
  );
}
```

**Points importants** :
- Sans `listen: false` : Se met à jour automatiquement quand les données changent
- Utilisé pour **afficher des données** qui peuvent changer

### Méthode 3 : `Consumer<T>`

**Quand l'utiliser** : Quand vous voulez **optimiser les performances** en n'écoutant que certaines parties.

**Exemple dans `login_screen.dart`** :

```dart
child: Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    // Ce widget se met à jour SEULEMENT quand authProvider change
    if (authProvider.isLoading) {
      return CircularProgressIndicator();
    }
    return Text('CONNEXION');
  },
),
```

**Avantage** : Seul le widget à l'intérieur de `Consumer` se met à jour, pas tout l'écran !

---

## 5️⃣ Exemple Complet : Le Flux de Connexion

Voici comment tout fonctionne ensemble lors d'une connexion :

### Étape 1 : L'utilisateur clique sur "CONNEXION"

```dart
// Dans login_screen.dart
ElevatedButton(
  onPressed: () {
    _handleLogin(); // Appelle la fonction de connexion
  },
)
```

### Étape 2 : La fonction `_handleLogin()` est appelée

```dart
Future<void> _handleLogin() async {
  // 1. Récupère le AuthProvider
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  
  // 2. Appelle la méthode login
  final success = await authProvider.login(
    _emailController.text.trim(),
    _passwordController.text,
  );
}
```

### Étape 3 : Dans `AuthProvider.login()`

```dart
Future<bool> login(String email, String password) async {
  // 1. Met isLoading à true
  _isLoading = true;
  notifyListeners(); // ⚠️ Dit à tous les widgets d'écouter de se mettre à jour
  
  // 2. Fait la requête API
  final response = await apiService.post('/api/login', data: {...});
  
  // 3. Si succès, sauvegarde les données
  _token = response.data['token'];
  _user = User.fromJson(response.data['user']);
  _isLoading = false;
  notifyListeners(); // ⚠️ Dit à nouveau aux widgets de se mettre à jour
}
```

### Étape 4 : Le bouton se met à jour automatiquement

```dart
// Dans login_screen.dart
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    // Ce widget se met à jour automatiquement quand authProvider.isLoading change !
    if (authProvider.isLoading) {
      return CircularProgressIndicator(); // Affiche un loader
    }
    return Text('CONNEXION'); // Affiche le texte normal
  },
)
```

**Résultat** : Sans rien faire de plus, le bouton affiche un loader pendant la connexion !

---

## 6️⃣ Les Patterns Courants

### Pattern 1 : Lire une donnée

```dart
final authProvider = Provider.of<AuthProvider>(context);
Text('Bonjour ${authProvider.user?.name}');
```

### Pattern 2 : Appeler une méthode

```dart
final authProvider = Provider.of<AuthProvider>(context, listen: false);
await authProvider.logout();
```

### Pattern 3 : Écouter les changements (optimisé)

```dart
Consumer<FideleProvider>(
  builder: (context, provider, child) {
    return Text('Nombre de fidèles: ${provider.fideles.length}');
  },
)
```

### Pattern 4 : Charger des données au démarrage

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Charge les données après que le widget soit construit
    Provider.of<FideleProvider>(context, listen: false).fetchFideles();
  });
}
```

---

## 7️⃣ Résumé Visuel

```
┌─────────────────────────────────────────┐
│         main.dart                      │
│  MultiProvider (enregistre tous les    │
│  providers au démarrage)               │
└─────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│      AuthProvider                       │
│  - _user                                │
│  - _token                               │
│  - login()                              │
│  - logout()                             │
└─────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│      login_screen.dart                  │
│  Provider.of<AuthProvider>()           │
│  → Appelle authProvider.login()        │
└─────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│      dashboard_screen.dart              │
│  Provider.of<AuthProvider>()           │
│  → Affiche authProvider.user?.name     │
└─────────────────────────────────────────┘
```

---

## 8️⃣ Points Clés à Retenir

✅ **`notifyListeners()`** : À appeler après chaque modification de données
✅ **`listen: false`** : Pour appeler des méthodes sans écouter les changements
✅ **`Consumer`** : Pour optimiser les performances
✅ **Les données privées** : Commencent par `_` (ex: `_user`)
✅ **Les getters publics** : Pour lire les données (ex: `get user`)

---

## 9️⃣ Questions Fréquentes

### Q : Pourquoi utiliser `listen: false` ?
**R** : Pour éviter que le widget se reconstruise inutilement. Si vous appelez juste une méthode, vous n'avez pas besoin d'écouter les changements.

### Q : Quand utiliser `Consumer` vs `Provider.of` ?
**R** : 
- `Provider.of` : Pour lire/appeler dans le code (dans une fonction)
- `Consumer` : Pour afficher dans le build (dans le widget tree)

### Q : Que se passe-t-il si j'oublie `notifyListeners()` ?
**R** : Les widgets ne se mettront pas à jour ! C'est une erreur courante.

---

## 🎓 Conclusion

Provider est un système simple mais puissant :
1. **Enregistrez** vos providers dans `main.dart`
2. **Utilisez** `Provider.of` ou `Consumer` pour accéder aux données
3. **Appelez** `notifyListeners()` après chaque modification

C'est tout ! 🎉

