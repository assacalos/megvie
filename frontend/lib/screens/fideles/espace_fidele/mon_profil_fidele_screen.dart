import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/fidele_provider.dart';
import '../../../models/fidele.dart';

/// Écran "Mon profil" pour le fidèle : affichage et mise à jour limitée (contacts, photo, etc.).
class MonProfilFideleScreen extends StatefulWidget {
  const MonProfilFideleScreen({super.key});

  @override
  State<MonProfilFideleScreen> createState() => _MonProfilFideleScreenState();
}

class _MonProfilFideleScreenState extends State<MonProfilFideleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contactsController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();
  final _lieuResidenceController = TextEditingController();
  final _professionController = TextEditingController();
  int? _lastFideleId;

  @override
  void dispose() {
    _contactsController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _lieuResidenceController.dispose();
    _professionController.dispose();
    super.dispose();
  }

  void _fillFromFidele(Fidele? f) {
    if (f == null) return;
    if (_lastFideleId == f.id) return;
    _lastFideleId = f.id;
    _contactsController.text = f.contacts ?? '';
    _whatsappController.text = f.whatsapp ?? '';
    _emailController.text = f.email ?? '';
    _lieuResidenceController.text = f.lieuResidence ?? '';
    _professionController.text = f.profession ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
        backgroundColor: const Color(0xFF7B2CBF),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/espace-fidele'),
        ),
      ),
      body: Consumer<FideleProvider>(
        builder: (context, provider, _) {
          final fidele = provider.selectedFidele;
          if (provider.isLoading && fidele == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (fidele == null) {
            return const Center(child: Text('Profil non disponible.'));
          }
          _fillFromFidele(fidele);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionTitle(title: 'Informations personnelles'),
                  _ReadOnlyField(label: 'Nom', value: fidele.nom),
                  _ReadOnlyField(label: 'Prénoms', value: fidele.prenoms),
                  _ReadOnlyField(
                    label: 'Tranche d\'âge',
                    value: fidele.trancheAge ?? 'Non renseigné',
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(title: 'Coordonnées (modifiables)'),
                  TextFormField(
                    controller: _contactsController,
                    decoration: const InputDecoration(
                      labelText: 'Téléphone',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _whatsappController,
                    decoration: const InputDecoration(
                      labelText: 'WhatsApp',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _lieuResidenceController,
                    decoration: const InputDecoration(
                      labelText: 'Lieu de résidence',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _professionController,
                    decoration: const InputDecoration(
                      labelText: 'Profession',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(title: 'Parrainage & accompagnement'),
                  _ReadOnlyField(
                    label: 'Parrain',
                    value: fidele.parrain != null
                        ? '${fidele.parrain!['nom']} ${fidele.parrain!['prenoms']}'
                        : 'Non assigné',
                  ),
                  _ReadOnlyField(
                    label: 'Pasteur',
                    value: fidele.pasteur != null
                        ? '${fidele.pasteur!['nom']} ${fidele.pasteur!['prenoms']}'
                        : 'Non assigné',
                  ),
                  _ReadOnlyField(
                    label: 'Famille',
                    value: fidele.famille != null
                        ? '${fidele.famille!['nom']} ${fidele.famille!['prenoms']}'
                        : 'Aucune',
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(title: 'Parcours spirituel'),
                  _ReadOnlyField(
                    label: 'Baptême d\'eau',
                    value: fidele.baptiseEau == true ? 'Oui' : 'Non',
                  ),
                  _ReadOnlyField(
                    label: 'Baptême du Saint-Esprit',
                    value: fidele.baptiseSaintEsprit == true ? 'Oui' : 'Non',
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => _save(context, provider, fidele.id),
                    icon: const Icon(Icons.save),
                    label: const Text('Enregistrer les modifications'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B2CBF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _save(BuildContext context, FideleProvider provider, int fideleId) async {
    final success = await provider.updateFidele(
      fideleId,
      {
        'contacts': _contactsController.text.trim().isEmpty ? null : _contactsController.text.trim(),
        'whatsapp': _whatsappController.text.trim().isEmpty ? null : _whatsappController.text.trim(),
        'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        'lieu_residence': _lieuResidenceController.text.trim().isEmpty ? null : _lieuResidenceController.text.trim(),
        'profession': _professionController.text.trim().isEmpty ? null : _professionController.text.trim(),
      },
    );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour.')),
      );
      await provider.fetchMyProfilFidele();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Erreur lors de l\'enregistrement'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF7B2CBF),
        ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;

  const _ReadOnlyField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
