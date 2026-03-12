import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'providers/fidele_provider.dart';
import 'providers/reference_provider.dart';
import 'providers/content_provider.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/fideles/list_fideles_screen.dart';
import 'screens/fideles/enregistrement_screen.dart';
import 'screens/fideles/detail_fidele_screen.dart';
import 'screens/fideles/detail_suivi_screen.dart';
import 'screens/roles/form_role_screen.dart';
import 'screens/roles/list_roles_screen.dart';
import 'screens/fideles/espace_fidele/dashboard_fidele_screen.dart';
import 'screens/fideles/espace_fidele/mon_profil_fidele_screen.dart';
import 'screens/fideles/espace_fidele/mes_suivis_fidele_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/content/annonces_screen.dart';
import 'screens/content/documents_screen.dart';
import 'screens/content/finances_screen.dart';
import 'screens/content/rendez_vous_screen.dart';
import 'screens/content/mediatheque_screen.dart';
import 'screens/content/priere_temoignages_screen.dart';
import 'utils/constants.dart';
import 'widgets/app_lifecycle_handler.dart';
import 'services/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppConstants.init();
  ApiService().init(AppConstants.getBaseUrl());

  try {
    await PushNotificationService().init();
  } catch (_) {}

  // Restaurer la session
  final authProvider = AuthProvider();
  await authProvider.init();

  runApp(MyApp(authProvider: authProvider));
}

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;

  const MyApp({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => FideleProvider()),
        ChangeNotifierProvider(create: (_) => ReferenceProvider()),
        ChangeNotifierProvider(create: (_) => ContentProvider()),
      ],
      child: Builder(
        builder: (context) {
          return AppLifecycleHandler(
            child: MaterialApp.router(
              title: 'MEG-VIE',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primarySwatch: Colors.purple,
                primaryColor: const Color(0xFF7B2CBF),
                scaffoldBackgroundColor: const Color(0xFFF5F5F5),
                fontFamily: 'Roboto',
              ),
              routerConfig: _createRouter(context),
            ),
          );
        },
      ),
    );
  }

  GoRouter _createRouter(BuildContext context) {
    return GoRouter(
      refreshListenable: authProvider,
      redirect: (context, state) {
        final auth = context.read<AuthProvider>();
        if (!auth.isInitialized) return null;
        final isLogin = state.uri.path == '/login';
        if (!auth.isAuthenticated && !isLogin) return '/login';
        if (auth.isAuthenticated && isLogin) {
          if (auth.user?.isFidele == true) return '/espace-fidele';
          return '/dashboard';
        }
        // Fidèle ne doit pas accéder au dashboard admin
        if (auth.user?.isFidele == true && state.uri.path == '/dashboard') {
          return '/espace-fidele';
        }
        // Non-fidèle ne doit pas accéder à l'espace fidèle
        if (auth.user != null && !auth.user!.isFidele && state.uri.path.startsWith('/espace-fidele')) {
          return '/dashboard';
        }
        return null;
      },
      initialLocation: '/login',
      routes: [
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
        GoRoute(path: '/fideles', builder: (_, __) => const ListFidelesScreen()),
        GoRoute(path: '/fideles/enregistrement', builder: (_, __) => const EnregistrementScreen()),
        GoRoute(
          path: '/fideles/suivis/detail',
          builder: (_, state) {
            final extra = state.extra as Map<String, dynamic>?;
            if (extra == null) return const Scaffold(body: Center(child: Text('Données manquantes')));
            return DetailSuiviScreen(
              fideleId: extra['fideleId'] as int,
              fideleNom: extra['fideleNom'] as String?,
              suivi: extra['suivi'] as Map<String, dynamic>,
            );
          },
        ),
        GoRoute(
          path: '/fideles/:id',
          builder: (_, state) {
            final id = int.parse(state.pathParameters['id']!);
            return DetailFideleScreen(fideleId: id);
          },
        ),
        GoRoute(path: '/roles', builder: (_, __) => const ListRolesScreen()),
        GoRoute(path: '/roles/nouveau', builder: (_, __) => const FormRoleScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        // Contenu & Communication (admin et autres rôles)
        GoRoute(path: '/annonces', builder: (_, __) => const AnnoncesScreen()),
        GoRoute(path: '/documents', builder: (_, __) => const DocumentsScreen()),
        GoRoute(path: '/finances', builder: (_, __) => const FinancesScreen()),
        GoRoute(path: '/rendez-vous', builder: (_, __) => const RendezVousScreen()),
        GoRoute(path: '/mediatheque', builder: (_, __) => const MediathequeScreen()),
        GoRoute(path: '/priere-temoignages', builder: (_, __) => const PriereTemoignagesScreen()),
        // Espace fidèle (rôle fidèle)
        GoRoute(path: '/espace-fidele', builder: (_, __) => const DashboardFideleScreen()),
        GoRoute(path: '/espace-fidele/profil', builder: (_, __) => const MonProfilFideleScreen()),
        GoRoute(path: '/espace-fidele/suivis', builder: (_, __) => const MesSuivisFideleScreen()),
        GoRoute(path: '/espace-fidele/annonces', builder: (_, __) => const AnnoncesScreen()),
        GoRoute(path: '/espace-fidele/documents', builder: (_, __) => const DocumentsScreen()),
        GoRoute(path: '/espace-fidele/dimes', builder: (_, __) => const FinancesScreen()),
        GoRoute(path: '/espace-fidele/rendez-vous', builder: (_, __) => const RendezVousScreen()),
        GoRoute(path: '/espace-fidele/mediatheque', builder: (_, __) => const MediathequeScreen()),
        GoRoute(path: '/espace-fidele/priere-temoignages', builder: (_, __) => const PriereTemoignagesScreen()),
      ],
    );
  }
}
