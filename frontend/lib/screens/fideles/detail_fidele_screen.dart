import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/fidele_provider.dart';

class DetailFideleScreen extends StatefulWidget {
  final int fideleId;

  const DetailFideleScreen({super.key, required this.fideleId});

  @override
  State<DetailFideleScreen> createState() => _DetailFideleScreenState();
}

class _DetailFideleScreenState extends State<DetailFideleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FideleProvider>(
        context,
        listen: false,
      ).fetchFidele(widget.fideleId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du Fidèle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () {},
            tooltip: 'Exporter',
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/fideles'),
            tooltip: 'Retour',
          ),
        ],
      ),
      body: Consumer<FideleProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final fidele = provider.selectedFidele;
          if (fidele == null) {
            return const Center(child: Text('Fidèle non trouvé'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informations du fidèle
                _buildSection('Informations Du Fidèle', [
                  _buildInfoRow(Icons.person, 'Nom', fidele.fullName),
                  _buildInfoRow(
                    Icons.access_time,
                    'Identifiant/Age',
                    fidele.trancheAge ?? 'Non renseigné',
                  ),
                  _buildInfoRow(
                    Icons.home,
                    'Adresse',
                    fidele.lieuResidence ?? 'Non renseigné',
                  ),
                  _buildInfoRow(
                    Icons.work,
                    'Profession',
                    fidele.profession ?? 'Non renseigné',
                  ),
                  _buildInfoRow(
                    Icons.phone,
                    'Téléphone 1',
                    fidele.contacts ?? 'Non renseigné',
                  ),
                  _buildInfoRow(
                    Icons.chat,
                    'Téléphone 2',
                    fidele.whatsapp ?? 'Non renseigné',
                  ),
                  _buildInfoRow(
                    Icons.email,
                    'Email',
                    fidele.email ?? 'Non renseigné',
                  ),
                ]),
                const SizedBox(height: 24),
                // Mise à jour
                _buildSection('Mise À Jour', [
                  ListTile(
                    leading: const Icon(Icons.photo),
                    title: const Text('Choisir une photo'),
                    trailing: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Choisir'),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_add),
                    title: const Text('Parrain'),
                    subtitle: Text(
                      fidele.parrain != null
                          ? '${fidele.parrain!['nom']} ${fidele.parrain!['prenoms']}'
                          : 'Non renseigné',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                  ListTile(
                    leading: const Icon(Icons.church),
                    title: const Text('Choix d\'un pasteur pour le suivi'),
                    subtitle: Text(
                      fidele.pasteur != null
                          ? '${fidele.pasteur!['nom']} ${fidele.pasteur!['prenoms']}'
                          : 'Non renseigné',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                  ListTile(
                    leading: const Icon(Icons.group),
                    title: const Text('Choix d\'un chef de disc'),
                    subtitle: Text(
                      fidele.chefDisc != null
                          ? '${fidele.chefDisc!['nom']} ${fidele.chefDisc!['prenoms']}'
                          : 'Non renseigné',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                ]),
                const SizedBox(height: 24),
                // Suivi du fidèle
                _buildSection('Suivi Du Fidèle', [
                  const Text('Statut de suivi:'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildStatusChip('pas_interesse', 'Pas intéressé'),
                      _buildStatusChip('injoignable', 'Injoignable'),
                      _buildStatusChip('confirme', 'Confirmé'),
                      _buildStatusChip(
                        'visite_prochaine_fois',
                        'Visite une prochaine fois',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: const Text('mm/dd/yyyy'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Observation',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  ),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, String label) {
    return FilterChip(
      label: Text(label),
      selected: false,
      onSelected: (selected) {
        // TODO: Implémenter la logique de suivi
      },
    );
  }
}
