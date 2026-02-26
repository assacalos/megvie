import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/reference_provider.dart';
import '../../providers/auth_provider.dart';

// Seul le sous-admin peut créer/modifier des rôles (admin = observateur)
bool _isSousAdmin(String? role) {
  return role == 'sous_admin';
}

// Admin et sous_admin peuvent voir la liste des rôles
bool _canSeeRoles(String? role) {
  return role == 'admin' || role == 'sous_admin';
}

enum RoleType {
  administrateur,
  pasteur,
  famille,
  parrain,
  serviceSocial,
  travailleur,
}

class ListRolesScreen extends StatefulWidget {
  const ListRolesScreen({super.key});

  @override
  State<ListRolesScreen> createState() => _ListRolesScreenState();
}

class _ListRolesScreenState extends State<ListRolesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ReferenceProvider>(context, listen: false);
      provider.fetchAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getRoleLabel(RoleType role) {
    switch (role) {
      case RoleType.administrateur:
        return 'Administrateurs';
      case RoleType.pasteur:
        return 'Pasteurs';
      case RoleType.famille:
        return 'Familles';
      case RoleType.parrain:
        return 'Parrains';
      case RoleType.serviceSocial:
        return 'Services Sociaux';
      case RoleType.travailleur:
        return 'Travailleurs';
    }
  }

  IconData _getRoleIcon(RoleType role) {
    switch (role) {
      case RoleType.administrateur:
        return Icons.admin_panel_settings;
      case RoleType.pasteur:
        return Icons.church;
      case RoleType.famille:
        return Icons.family_restroom;
      case RoleType.parrain:
        return Icons.handshake;
      case RoleType.serviceSocial:
        return Icons.volunteer_activism;
      case RoleType.travailleur:
        return Icons.badge;
    }
  }

  Widget _buildPersonCard(Map<String, dynamic> item, RoleType role) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF7B2CBF),
          child: Icon(_getRoleIcon(role), color: Colors.white),
        ),
        title: Text(
          item['nom'] != null && item['prenoms'] != null
              ? '${item['nom']} ${item['prenoms']}'
              : item['name'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item['email'] != null) Text('Email: ${item['email']}'),
            if (item['telephone'] != null) Text('Tél: ${item['telephone']}'),
            if (role == RoleType.parrain && item['famille'] != null)
              Text(
                'Famille: ${item['famille']['nom'] ?? item['famille']['name'] ?? ''}',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildFamilleCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF7B2CBF),
          child: const Icon(Icons.family_restroom, color: Colors.white),
        ),
        title: Text(
          item['nom'] ?? item['name'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle:
            item['description'] != null ? Text(item['description']) : null,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildTravailleurCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF7B2CBF),
          child: const Icon(Icons.badge, color: Colors.white),
        ),
        title: Text(
          item['nom'] != null && item['prenoms'] != null
              ? '${item['nom']} ${item['prenoms']}'
              : item['name'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item['email'] != null) Text('Email: ${item['email']}'),
            if (item['telephone'] != null) Text('Tél: ${item['telephone']}'),
            if (item['profession'] != null)
              Text('Profession: ${item['profession']}'),
            if (item['entreprise'] != null)
              Text('Entreprise: ${item['entreprise']}'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildServiceSocialCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF7B2CBF),
          child: const Icon(Icons.volunteer_activism, color: Colors.white),
        ),
        title: Text(
          item['nom'] != null && item['prenoms'] != null
              ? '${item['nom']} ${item['prenoms']}'
              : item['name'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item['email'] != null) Text('Email: ${item['email']}'),
            if (item['telephone'] != null) Text('Tél: ${item['telephone']}'),
            if (item['description'] != null)
              Text('Description: ${item['description']}'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF7B2CBF),
          child: const Icon(Icons.admin_panel_settings, color: Colors.white),
        ),
        title: Text(
          item['name'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${item['email'] ?? ''}'),
            Text('Rôle: ${item['role'] ?? 'admin'}'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildList(RoleType role) {
    return Consumer<ReferenceProvider>(
      builder: (context, provider, child) {
        List<Map<String, dynamic>> items = [];
        bool isLoading = false;

        switch (role) {
          case RoleType.administrateur:
            items = provider.users;
            isLoading = provider.isLoading;
            break;
          case RoleType.pasteur:
            items = provider.pasteurs;
            isLoading = provider.isLoading;
            break;
          case RoleType.famille:
            items = provider.familles;
            isLoading = provider.isLoading;
            break;
          case RoleType.parrain:
            items = provider.parrains;
            isLoading = provider.isLoading;
            break;
          case RoleType.serviceSocial:
            items = provider.serviceSociaux;
            isLoading = provider.isLoading;
            break;
          case RoleType.travailleur:
            items = provider.travailleurs;
            isLoading = provider.isLoading;
            break;
        }

        if (isLoading && items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getRoleIcon(role),
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucun ${_getRoleLabel(role).toLowerCase()} enregistré',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => context.go('/roles/nouveau'),
                  child: const Text('Ajouter'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            switch (role) {
              case RoleType.administrateur:
                await provider.fetchUsers();
                break;
              case RoleType.pasteur:
                await provider.fetchPasteurs();
                break;
              case RoleType.famille:
                await provider.fetchFamilles();
                break;
              case RoleType.parrain:
                await provider.fetchParrains();
                break;
              case RoleType.serviceSocial:
                await provider.fetchServiceSociaux();
                break;
              case RoleType.travailleur:
                await provider.fetchTravailleurs();
                break;
            }
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              if (role == RoleType.administrateur) {
                return _buildUserCard(item);
              } else if (role == RoleType.famille) {
                return _buildFamilleCard(item);
              } else if (role == RoleType.travailleur) {
                return _buildTravailleurCard(item);
              } else if (role == RoleType.serviceSocial) {
                return _buildServiceSocialCard(item);
              } else {
                return _buildPersonCard(item, role);
              }
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Vérifier si l'utilisateur est administrateur
    if (!_canSeeRoles(authProvider.user?.role)) {
      // Rediriger vers le dashboard si ce n'est pas un admin
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Accès refusé. Seuls les administrateurs peuvent gérer les rôles.'),
              backgroundColor: Colors.red,
            ),
          );
          context.go('/dashboard');
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Rôles'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(
              icon: Icon(_getRoleIcon(RoleType.administrateur)),
              text: _getRoleLabel(RoleType.administrateur),
            ),
            Tab(
              icon: Icon(_getRoleIcon(RoleType.pasteur)),
              text: _getRoleLabel(RoleType.pasteur),
            ),
            Tab(
              icon: Icon(_getRoleIcon(RoleType.famille)),
              text: _getRoleLabel(RoleType.famille),
            ),
            Tab(
              icon: Icon(_getRoleIcon(RoleType.parrain)),
              text: _getRoleLabel(RoleType.parrain),
            ),
            Tab(
              icon: Icon(_getRoleIcon(RoleType.serviceSocial)),
              text: _getRoleLabel(RoleType.serviceSocial),
            ),
            Tab(
              icon: Icon(_getRoleIcon(RoleType.travailleur)),
              text: _getRoleLabel(RoleType.travailleur),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(RoleType.administrateur),
          _buildList(RoleType.pasteur),
          _buildList(RoleType.famille),
          _buildList(RoleType.parrain),
          _buildList(RoleType.serviceSocial),
          _buildList(RoleType.travailleur),
        ],
      ),
      floatingActionButton: _isSousAdmin(authProvider.user?.role)
          ? FloatingActionButton.extended(
        onPressed: () => context.go('/roles/nouveau'),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau Rôle'),
        backgroundColor: const Color(0xFF7B2CBF),
        foregroundColor: Colors.white,
      )
          : null,
    );
  }
}
