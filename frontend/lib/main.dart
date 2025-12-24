import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'providers/fidele_provider.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/fideles/list_fideles_screen.dart';
import 'screens/fideles/enregistrement_screen.dart';
import 'screens/fideles/detail_fidele_screen.dart';

void main() {
  // Initialiser l'API service avec l'URL de base
  // TODO: Remplacer par votre URL de base Laravel
  ApiService().init('http://localhost:8000');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FideleProvider()),
      ],
      child: MaterialApp.router(
        title: 'MEG-VIE',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.purple,
          primaryColor: const Color(0xFF7B2CBF),
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          fontFamily: 'Roboto',
        ),
        routerConfig: _router,
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/fideles',
      builder: (context, state) => const ListFidelesScreen(),
    ),
    GoRoute(
      path: '/fideles/enregistrement',
      builder: (context, state) => const EnregistrementScreen(),
    ),
    GoRoute(
      path: '/fideles/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return DetailFideleScreen(fideleId: id);
      },
    ),
  ],
);
