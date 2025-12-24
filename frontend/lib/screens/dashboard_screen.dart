import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/fidele_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FideleProvider>(context, listen: false).fetchStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final fideleProvider = Provider.of<FideleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (mounted) context.go('/login');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF7B2CBF)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MEG-VIE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gestion des Fidèles',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Tableau de bord'),
              onTap: () {
                Navigator.pop(context);
                context.go('/dashboard');
              },
            ),
            ExpansionTile(
              leading: const Icon(Icons.people),
              title: const Text('Enrolés'),
              children: [
                ListTile(
                  title: const Text('Enrôlement'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/fideles/enregistrement');
                  },
                ),
                ListTile(
                  title: const Text('Liste'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/fideles');
                  },
                ),
              ],
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Sous-admins'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Pasteurs'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.family_restroom),
              title: const Text('Familles'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.handshake),
              title: const Text('Parrains'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Profil'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message
            Text(
              'Bienvenue ${authProvider.user?.name ?? ''}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vous avez la capacité d\'enregistrer et de faire le suivi de vos fidèles',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            // Stats cards
            Consumer<FideleProvider>(
              builder: (context, provider, child) {
                final stats = provider.stats ?? {};
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
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
                    _StatCard(
                      title: 'Nombre de suivis',
                      value: '${stats['suivis'] ?? 0}',
                      color: Colors.purple,
                    ),
                    _StatCard(
                      title: 'Nombres des administrateurs',
                      value: '${stats['administrateurs'] ?? 0}',
                      color: Colors.red,
                      subtitle: 'y compris pasteurs, parrains, familles',
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('/fideles/enregistrement');
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouvel Enregistrement'),
        backgroundColor: const Color(0xFF7B2CBF),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final String? subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
          ],
        ),
      ),
    );
  }
}
