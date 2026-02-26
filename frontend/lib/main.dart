import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'providers/fidele_provider.dart';
import 'providers/reference_provider.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/fideles/list_fideles_screen.dart';
import 'screens/fideles/enregistrement_screen.dart';
import 'screens/fideles/detail_fidele_screen.dart';
import 'screens/roles/form_role_screen.dart';
import 'screens/roles/list_roles_screen.dart';
import 'screens/profile_screen.dart';
import 'utils/constants.dart';
import 'widgets/app_lifecycle_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppConstants.init();
  ApiService().init(AppConstants.getBaseUrl());

  // Restaurer la session : l'utilisateur reste connecté tant qu'il ne se déconnecte pas
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
        if (auth.isAuthenticated && isLogin) return '/dashboard';
        return null;
      },
      initialLocation: '/login',
      routes: [
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
        GoRoute(path: '/fideles', builder: (_, __) => const ListFidelesScreen()),
        GoRoute(path: '/fideles/enregistrement', builder: (_, __) => const EnregistrementScreen()),
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
      ],
    );
  }
}
