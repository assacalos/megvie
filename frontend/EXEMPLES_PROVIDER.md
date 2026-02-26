# 💡 Exemples Pratiques : Provider dans Votre Projet

Ce document contient des exemples concrets tirés de votre code pour mieux comprendre Provider.

---

## 📝 Exemple 1 : Connexion Utilisateur

### Code dans `login_screen.dart` (ligne 29-34)

```dart
Future<void> _handleLogin() async {
  // 1. Récupère le AuthProvider (sans écouter les changements)
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  
  // 2. Appelle la méthode login
  final success = await authProvider.login(
    _emailController.text.trim(),
    _passwordController.text,
  );
  
  // 3. Si succès, navigue vers le dashboard
  if (success && mounted) {
    context.go('/dashboard');
  }
}
```

**Explication** :
- `Provider.of<AuthProvider>(context, listen: false)` : Récupère le provider sans écouter
- `listen: false` : Important ici car on appelle juste une méthode, on n'affiche pas de données
- `authProvider.login(...)` : Appelle la méthode qui va faire la requête API

---

## 📝 Exemple 2 : Afficher l'État de Chargement

### Code dans `login_screen.dart` (ligne 223-245)

```dart
child: Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    // Ce widget se met à jour automatiquement quand authProvider.isLoading change
    if (authProvider.isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }
    return const Text(
      'CONNEXION',
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  },
),
```

**Explication** :
- `Consumer<AuthProvider>` : Écoute uniquement les changements de `AuthProvider`
- `builder: (context, authProvider, child)` : Reçoit le provider en paramètre
- Quand `authProvider.isLoading` change, ce widget se reconstruit automatiquement
- Si `isLoading = true` → Affiche un loader
- Si `isLoading = false` → Affiche le texte "CONNEXION"

**Flux** :
1. Utilisateur clique sur "CONNEXION"
2. `authProvider.login()` est appelé
3. Dans `login()`, `_isLoading = true` puis `notifyListeners()`
4. `Consumer` détecte le changement et reconstruit le widget
5. Le loader s'affiche
6. Quand la connexion finit, `_isLoading = false` puis `notifyListeners()`
7. Le texte "CONNEXION" s'affiche

---

## 📝 Exemple 3 : Afficher le Nom de l'Utilisateur

### Code dans `dashboard_screen.dart` (ligne 25-26, 129)

```dart
@override
Widget build(BuildContext context) {
  // Récupère le AuthProvider ET écoute les changements
  final authProvider = Provider.of<AuthProvider>(context);
  final fideleProvider = Provider.of<FideleProvider>(context);

  return Scaffold(
    body: Text(
      'Bienvenue ${authProvider.user?.name ?? ''}',
      // Si authProvider.user change, ce Text se mettra à jour automatiquement
    ),
  );
}
```

**Explication** :
- `Provider.of<AuthProvider>(context)` : Sans `listen: false`, donc écoute les changements
- `authProvider.user?.name` : Accède au nom de l'utilisateur
- `?? ''` : Si `user` est null, affiche une chaîne vide
- Si l'utilisateur se déconnecte et se reconnecte, ce texte se mettra à jour automatiquement

---

## 📝 Exemple 4 : Charger des Données au Démarrage

### Code dans `dashboard_screen.dart` (ligne 16-21)

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Charge les statistiques après que le widget soit construit
    Provider.of<FideleProvider>(context, listen: false).fetchStats();
  });
}
```

**Explication** :
- `initState()` : Appelé quand le widget est créé
- `addPostFrameCallback` : Attend que le widget soit complètement construit
- `listen: false` : On appelle juste une méthode, pas besoin d'écouter
- `fetchStats()` : Charge les statistiques depuis l'API

**Pourquoi `addPostFrameCallback` ?**
- Si vous appelez `Provider.of` directement dans `initState()`, le `context` n'est pas encore prêt
- `addPostFrameCallback` attend que tout soit construit avant d'exécuter le code

---

## 📝 Exemple 5 : Afficher des Données avec Consumer

### Code dans `dashboard_screen.dart` (ligne 139-174)

```dart
Consumer<FideleProvider>(
  builder: (context, provider, child) {
    // Récupère les stats depuis le provider
    final stats = provider.stats ?? {};
    
    return GridView.count(
      crossAxisCount: 2,
      children: [
        _StatCard(
          title: 'Nombres d\'enrolés',
          value: '${stats['total'] ?? 0}',
          color: Colors.blue,
        ),
        _StatCard(
          title: 'Nombres de baptisés',
          value: '${stats['baptises'] ?? 0}',
          color: const Color(0xFF1A237E),
        ),
        // ... autres cartes
      ],
    );
  },
)
```

**Explication** :
- `Consumer<FideleProvider>` : Écoute uniquement les changements de `FideleProvider`
- `provider.stats` : Accède aux statistiques
- `?? {}` : Si `stats` est null, utilise un Map vide
- Quand `fetchStats()` est appelé et que les données arrivent, ce widget se met à jour automatiquement

**Flux** :
1. `initState()` appelle `fetchStats()`
2. `fetchStats()` fait la requête API
3. Quand les données arrivent, `_stats = response.data` puis `notifyListeners()`
4. `Consumer` détecte le changement et reconstruit le widget
5. Les cartes affichent les nouvelles statistiques

---

## 📝 Exemple 6 : Déconnexion

### Code dans `dashboard_screen.dart` (ligne 35-38)

```dart
IconButton(
  icon: const Icon(Icons.logout),
  onPressed: () async {
    // Appelle la méthode logout
    await authProvider.logout();
    // Navigue vers la page de connexion
    if (mounted) context.go('/login');
  },
)
```

**Explication** :
- `authProvider.logout()` : Appelle la méthode qui nettoie les données
- Dans `AuthProvider.logout()` :
  ```dart
  _user = null;
  _token = null;
  notifyListeners(); // Dit à tous les widgets de se mettre à jour
  ```
- Tous les widgets qui utilisent `authProvider.user` se mettront à jour automatiquement

---

## 📝 Exemple 7 : Comment les Données Changent dans AuthProvider

### Code dans `auth_provider.dart` (ligne 39-88)

```dart
Future<bool> login(String email, String password) async {
  // 1. Met isLoading à true
  _isLoading = true;
  _error = null;
  notifyListeners(); // ⚠️ Dit à tous les widgets d'écouter de se mettre à jour
  
  try {
    // 2. Fait la requête API
    final response = await apiService.post('/api/login', data: {...});
    
    if (response.statusCode == 200) {
      // 3. Si succès, sauvegarde les données
      _token = response.data['token'];
      _user = User.fromJson(response.data['user']);
      
      // 4. Sauvegarde dans le stockage local
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      
      // 5. Met isLoading à false
      _isLoading = false;
      notifyListeners(); // ⚠️ Dit à nouveau aux widgets de se mettre à jour
      return true;
    }
  } catch (e) {
    // 6. En cas d'erreur
    _error = 'Erreur de connexion';
    _isLoading = false;
    notifyListeners(); // ⚠️ Dit aux widgets de se mettre à jour
    return false;
  }
}
```

**Points clés** :
- `_isLoading = true` puis `notifyListeners()` → Le loader s'affiche
- `_user = ...` puis `notifyListeners()` → Le nom de l'utilisateur s'affiche
- `_error = ...` puis `notifyListeners()` → Le message d'erreur s'affiche
- **Sans `notifyListeners()`**, rien ne se mettrait à jour !

---

## 📝 Exemple 8 : Utiliser Plusieurs Providers

### Code dans `dashboard_screen.dart` (ligne 25-26)

```dart
@override
Widget build(BuildContext context) {
  // Récupère plusieurs providers
  final authProvider = Provider.of<AuthProvider>(context);
  final fideleProvider = Provider.of<FideleProvider>(context);
  
  return Scaffold(
    // Utilise authProvider pour le nom
    body: Text('Bienvenue ${authProvider.user?.name}'),
    // Utilise fideleProvider pour les stats
    // ...
  );
}
```

**Explication** :
- Vous pouvez utiliser autant de providers que vous voulez
- Chaque `Provider.of` récupère un provider différent
- Chacun écoute les changements de son provider respectif

---

## 🎯 Résumé des Patterns

| Situation | Code à utiliser |
|-----------|-----------------|
| Appeler une méthode | `Provider.of<T>(context, listen: false).methode()` |
| Afficher une donnée | `Provider.of<T>(context).donnee` |
| Widget qui se met à jour | `Consumer<T>(builder: (context, provider, child) {...})` |
| Charger au démarrage | `addPostFrameCallback((_) { Provider.of<T>(context, listen: false).charger(); })` |

---

## ⚠️ Erreurs Courantes

### ❌ Oubli de `notifyListeners()`
```dart
void updateUser(User newUser) {
  _user = newUser;
  // ❌ Oublié ! Les widgets ne se mettront pas à jour
}
```

### ✅ Correct
```dart
void updateUser(User newUser) {
  _user = newUser;
  notifyListeners(); // ✅ Les widgets se mettront à jour
}
```

### ❌ Utiliser `listen: false` pour afficher
```dart
final authProvider = Provider.of<AuthProvider>(context, listen: false);
Text('${authProvider.user?.name}'); // ❌ Ne se mettra pas à jour
```

### ✅ Correct
```dart
final authProvider = Provider.of<AuthProvider>(context);
Text('${authProvider.user?.name}'); // ✅ Se mettra à jour
```

---

## 🎓 Conclusion

Provider est simple :
1. **Enregistrez** dans `main.dart`
2. **Utilisez** `Provider.of` ou `Consumer`
3. **Appelez** `notifyListeners()` après chaque modification

C'est tout ! 🚀

