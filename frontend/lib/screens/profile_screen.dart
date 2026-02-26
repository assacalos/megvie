import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userDetails;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = ApiService();
      final response = await apiService.get('/api/user');

      if (response.statusCode == 200) {
        setState(() {
          _userDetails = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Erreur lors du chargement du profil';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  String _getRoleLabel(String? role) {
    switch (role) {
      case 'admin':
        return 'Administrateur';
      case 'sous_admin':
        return 'Sous-administrateur';
      case 'pasteur':
        return 'Pasteur';
      case 'famille':
        return 'Famille';
      case 'parrain':
        return 'Parrain';
      case 'service_social':
        return 'Services Sociaux';
      case 'travailleur':
        return 'Travailleur';
      default:
        return role ?? 'Non défini';
    }
  }

  IconData _getRoleIcon(String? role) {
    switch (role) {
      case 'admin':
      case 'sous_admin':
        return Icons.admin_panel_settings;
      case 'pasteur':
        return Icons.church;
      case 'famille':
        return Icons.family_restroom;
      case 'parrain':
        return Icons.handshake;
      case 'service_social':
        return Icons.volunteer_activism;
      case 'travailleur':
        return Icons.badge;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserDetails,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUserDetails,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // En-tête avec avatar et nom
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF7B2CBF), Color(0xFF9D4EDD)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    _getRoleIcon(_userDetails?['role']),
                                    size: 50,
                                    color: const Color(0xFF7B2CBF),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _userDetails?['name'] ??
                                      '${_userDetails?['nom'] ?? ''} ${_userDetails?['prenoms'] ?? ''}'
                                          .trim(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _getRoleLabel(_userDetails?['role']),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Informations personnelles
                        const Text(
                          'Informations Personnelles',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          icon: Icons.email,
                          label: 'Email',
                          value: _userDetails?['email'] ?? 'Non renseigné',
                        ),
                        if (_userDetails?['nom'] != null)
                          _buildInfoCard(
                            icon: Icons.person,
                            label: 'Nom',
                            value: _userDetails?['nom'] ?? 'Non renseigné',
                          ),
                        if (_userDetails?['prenoms'] != null)
                          _buildInfoCard(
                            icon: Icons.person_outline,
                            label: 'Prénoms',
                            value: _userDetails?['prenoms'] ?? 'Non renseigné',
                          ),
                        if (_userDetails?['telephone'] != null)
                          _buildInfoCard(
                            icon: Icons.phone,
                            label: 'Téléphone',
                            value:
                                _userDetails?['telephone'] ?? 'Non renseigné',
                          ),
                        if (_userDetails?['lieu_de_residence'] != null)
                          _buildInfoCard(
                            icon: Icons.location_on,
                            label: 'Lieu de résidence',
                            value: _userDetails?['lieu_de_residence'] ??
                                'Non renseigné',
                          ),
                        if (_userDetails?['zone_suivi'] != null &&
                            (_userDetails!['zone_suivi'] as String).trim().isNotEmpty)
                          _buildInfoCard(
                            icon: Icons.map,
                            label: 'Zone de suivi',
                            value: _userDetails?['zone_suivi'] ?? 'Non renseigné',
                          ),
                        // Informations spécifiques selon le rôle
                        if (_userDetails?['description'] != null) ...[
                          const SizedBox(height: 24),
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoCard(
                            icon: Icons.description,
                            label: 'Description',
                            value:
                                _userDetails?['description'] ?? 'Non renseigné',
                          ),
                        ],
                        if (_userDetails?['profession'] != null) ...[
                          const SizedBox(height: 16),
                          _buildInfoCard(
                            icon: Icons.work,
                            label: 'Profession',
                            value:
                                _userDetails?['profession'] ?? 'Non renseigné',
                          ),
                        ],
                        if (_userDetails?['entreprise'] != null) ...[
                          const SizedBox(height: 16),
                          _buildInfoCard(
                            icon: Icons.business,
                            label: 'Entreprise',
                            value:
                                _userDetails?['entreprise'] ?? 'Non renseigné',
                          ),
                        ],
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF7B2CBF)),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
