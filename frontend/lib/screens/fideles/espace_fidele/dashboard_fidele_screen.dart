import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/fidele_provider.dart';
import '../../../models/fidele.dart';

/// Tableau de bord réservé aux fidèles (rôle fidèle).
/// Affiche un résumé : profil, suivis, famille.
class DashboardFideleScreen extends StatefulWidget {
  const DashboardFideleScreen({super.key});

  @override
  State<DashboardFideleScreen> createState() => _DashboardFideleScreenState();
}

class _DashboardFideleScreenState extends State<DashboardFideleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FideleProvider>(context, listen: false).fetchMyProfilFidele();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon espace fidèle'),
        backgroundColor: const Color(0xFF7B2CBF),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (mounted) context.go('/login');
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context, authProvider),
      body: Consumer<FideleProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.selectedFidele == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final fidele = provider.selectedFidele;
          if (fidele == null && provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.grey[600]),
                    const SizedBox(height: 16),
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: () => provider.fetchMyProfilFidele(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (fidele == null) {
            return const Center(child: Text('Aucune fiche fidèle associée à votre compte.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Bienvenue ${fidele.fullName}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Consultez votre profil, vos suivis et les informations de votre famille.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                _DashboardCard(
                  title: 'Mon profil',
                  subtitle: 'Informations personnelles et coordonnées',
                  icon: Icons.person,
                  color: const Color(0xFF7B2CBF),
                  onTap: () => context.push('/espace-fidele/profil'),
                ),
                const SizedBox(height: 12),
                _DashboardCard(
                  title: 'Mes suivis',
                  subtitle: '${fidele.suivis?.length ?? 0} suivi(s) enregistré(s)',
                  icon: Icons.assignment,
                  color: Colors.indigo,
                  onTap: () => context.push('/espace-fidele/suivis'),
                ),
                const SizedBox(height: 12),
                _DashboardCard(
                  title: 'Ma famille',
                  subtitle: _getFamilleSubtitle(fidele),
                  icon: Icons.family_restroom,
                  color: Colors.teal,
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _DashboardCard(
                  title: 'Mon parcours',
                  subtitle: _getParcoursSubtitle(fidele),
                  icon: Icons.flag,
                  color: Colors.orange,
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _DashboardCard(
                  title: 'Annonces & Actualités',
                  subtitle: 'Les dernières annonces de l\'église',
                  icon: Icons.campaign,
                  color: Colors.deepPurple,
                  onTap: () => context.push('/espace-fidele/annonces'),
                ),
                const SizedBox(height: 12),
                _DashboardCard(
                  title: 'Documents',
                  subtitle: 'Règlement, formulaires',
                  icon: Icons.folder_open,
                  color: Colors.brown,
                  onTap: () => context.push('/espace-fidele/documents'),
                ),
                const SizedBox(height: 12),
                _DashboardCard(
                  title: 'Dîmes & Offrandes',
                  subtitle: 'Déclarer ou consulter mes dons',
                  icon: Icons.volunteer_activism,
                  color: Colors.green,
                  onTap: () => context.push('/espace-fidele/dimes'),
                ),
                const SizedBox(height: 12),
                _DashboardCard(
                  title: 'Rendez-vous / Prière',
                  subtitle: 'Demander un rendez-vous pastoral',
                  icon: Icons.event_available,
                  color: Colors.blue,
                  onTap: () => context.push('/espace-fidele/rendez-vous'),
                ),
                const SizedBox(height: 12),
                _DashboardCard(
                  title: 'Médiathèque spirituelle',
                  subtitle: 'Cultes, prédications, ressources',
                  icon: Icons.video_library,
                  color: Colors.purple,
                  onTap: () => context.push('/espace-fidele/mediatheque'),
                ),
                const SizedBox(height: 12),
                _DashboardCard(
                  title: 'Prière & Témoignage',
                  subtitle: 'Requêtes de prière et témoignages',
                  icon: Icons.favorite,
                  color: Colors.red,
                  onTap: () => context.push('/espace-fidele/priere-temoignages'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getFamilleSubtitle(Fidele fidele) {
    if (fidele.famille != null) {
      final f = fidele.famille!;
      return f['nom'] != null ? '${f['nom']} ${f['prenoms'] ?? ''}' : 'Famille assignée';
    }
    return 'Aucune famille assignée';
  }

  String _getParcoursSubtitle(Fidele fidele) {
    final parts = <String>[];
    if (fidele.baptiseEau == true) parts.add('Baptême d\'eau');
    if (fidele.baptiseSaintEsprit == true) parts.add('Baptême du Saint-Esprit');
    if (fidele.cureDAme == true) parts.add('Guérison');
    if (parts.isEmpty) return 'Parcours en cours';
    return parts.join(' • ');
  }

  Drawer _buildDrawer(BuildContext context, AuthProvider authProvider) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF7B2CBF)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MEG-VIE',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Espace fidèle',
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
              context.go('/espace-fidele');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Mon profil'),
            onTap: () {
              Navigator.pop(context);
              context.push('/espace-fidele/profil');
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Mes suivis'),
            onTap: () {
              Navigator.pop(context);
              context.push('/espace-fidele/suivis');
            },
          ),
          ListTile(
            leading: const Icon(Icons.campaign),
            title: const Text('Annonces'),
            onTap: () {
              Navigator.pop(context);
              context.push('/espace-fidele/annonces');
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder_open),
            title: const Text('Documents'),
            onTap: () {
              Navigator.pop(context);
              context.push('/espace-fidele/documents');
            },
          ),
          ListTile(
            leading: const Icon(Icons.volunteer_activism),
            title: const Text('Dîmes & Offrandes'),
            onTap: () {
              Navigator.pop(context);
              context.push('/espace-fidele/dimes');
            },
          ),
          ListTile(
            leading: const Icon(Icons.event_available),
            title: const Text('Rendez-vous'),
            onTap: () {
              Navigator.pop(context);
              context.push('/espace-fidele/rendez-vous');
            },
          ),
          ListTile(
            leading: const Icon(Icons.video_library),
            title: const Text('Médiathèque'),
            onTap: () {
              Navigator.pop(context);
              context.push('/espace-fidele/mediatheque');
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Prière & Témoignage'),
            onTap: () {
              Navigator.pop(context);
              context.push('/espace-fidele/priere-temoignages');
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Mon compte'),
            onTap: () {
              Navigator.pop(context);
              context.push('/profile');
            },
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
