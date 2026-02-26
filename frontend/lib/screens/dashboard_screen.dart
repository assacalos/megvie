import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/fidele_provider.dart';
import '../services/export_service.dart';

// Admin et sous_admin peuvent voir le menu "Gestion des rôles" (sous_admin seul peut modifier)
bool _canSeeRoles(String? role) {
  return role == 'admin' || role == 'sous_admin';
}

// Fonction pour obtenir le message de bienvenue selon le rôle
String _getWelcomeMessage(String? role) {
  switch (role) {
    case 'admin':
      return 'Vue observateur : consultez les données, les statistiques et exportez ou imprimez.';
    case 'sous_admin':
      return 'Vous avez la capacité d\'enregistrer et de faire le suivi de tous les fidèles';
    case 'pasteur':
      return 'Vous pouvez enregistrer et suivre les fidèles de votre lieu de résidence';
    case 'famille':
      return 'Vous pouvez enregistrer et suivre les fidèles de votre famille';
    case 'parrain':
      return 'Vous pouvez enregistrer et suivre les fidèles que vous parrainez';
    case 'service_social':
      return 'Vous pouvez enregistrer et faire le suivi de tous les fidèles';
    case 'travailleur':
      return 'Vous pouvez enregistrer et suivre les fidèles';
    default:
      return 'Vous pouvez enregistrer et faire le suivi de vos fidèles';
  }
}

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
                if (authProvider.user?.role != 'admin')
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
            // Gestion des rôles - Visible par admin (vue) et sous_admin (gestion)
            if (_canSeeRoles(authProvider.user?.role))
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Gestion des Rôles'),
                subtitle: const Text('Pasteurs, Familles, Parrains, etc.'),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/roles');
                },
              ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Profil'),
              onTap: () {
                Navigator.pop(context);
                context.go('/profile');
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message adapté selon le rôle
            Text(
              'Bienvenue ${authProvider.user?.name ?? ''}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _getWelcomeMessage(authProvider.user?.role),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            // Stats cards
            Consumer<FideleProvider>(
              builder: (context, provider, child) {
                final stats = provider.stats ?? {};
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GridView.count(
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
                    _StatCard(
                      title: 'Sans famille',
                      value: '${stats['sans_famille'] ?? 0}',
                      color: Colors.orange,
                    ),
                    _StatCard(
                      title: 'Sans parrain',
                      value: '${stats['sans_parrain'] ?? 0}',
                      color: Colors.teal,
                    ),
                    _StatCard(
                      title: 'Sans pasteur',
                      value: '${stats['sans_pasteur'] ?? 0}',
                      color: Colors.indigo,
                    ),
                  ],
                ),
                    // Pour l'admin observateur : exporter / imprimer les statistiques
                    if (authProvider.user?.role == 'admin') ...[
                      const SizedBox(height: 24),
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Exporter / Imprimer',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'En tant qu\'observateur, vous pouvez exporter les statistiques ou la liste des fidèles.',
                                style: TextStyle(fontSize: 13, color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () async {
                                        await ExportService.exportStatsToCSV(
                                          Map<String, dynamic>.from(stats),
                                        );
                                      },
                                      icon: const Icon(Icons.bar_chart),
                                      label: const Text('Exporter les statistiques'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () async {
                                        final all =
                                            await provider.fetchAllFidelesForExport();
                                        if (context.mounted && all.isNotEmpty) {
                                          await ExportService.exportFidelesToCSV(all);
                                        } else if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Aucun fidèle à exporter'),
                                              backgroundColor: Colors.orange,
                                            ),
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.list),
                                      label: const Text('Exporter la liste'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: authProvider.user?.role == 'admin'
          ? null
          : FloatingActionButton(
        onPressed: () {
          context.go('/fideles/enregistrement');
        },
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFF7B2CBF),
        foregroundColor: Colors.white,
        tooltip: 'Nouvel enregistrement',
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
