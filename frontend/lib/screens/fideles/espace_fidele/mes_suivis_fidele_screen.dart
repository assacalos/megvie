import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../providers/fidele_provider.dart';

/// Liste des suivis du fidèle connecté.
class MesSuivisFideleScreen extends StatelessWidget {
  const MesSuivisFideleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes suivis'),
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
            return const Center(child: Text('Données non disponibles.'));
          }
          final suivis = fidele.suivis ?? [];
          if (suivis.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_late, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun suivi enregistré pour le moment.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => provider.fetchMyProfilFidele(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: suivis.length,
              itemBuilder: (context, index) {
                final suivi = suivis[index] as Map<String, dynamic>;
                return _SuiviCard(
                  suivi: suivi,
                  fideleId: fidele.id,
                  fideleNom: fidele.fullName,
                  onTap: () {
                    context.push('/fideles/suivis/detail', extra: {
                      'fideleId': fidele.id,
                      'fideleNom': fidele.fullName,
                      'suivi': suivi,
                    });
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SuiviCard extends StatelessWidget {
  final Map<String, dynamic> suivi;
  final int fideleId;
  final String fideleNom;
  final VoidCallback onTap;

  const _SuiviCard({
    required this.suivi,
    required this.fideleId,
    required this.fideleNom,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = suivi['date'] != null
        ? DateFormat('dd/MM/yyyy').format(DateTime.parse(suivi['date'].toString()))
        : (suivi['date_suivi'] != null
            ? DateFormat('dd/MM/yyyy').format(DateTime.parse(suivi['date_suivi'].toString()))
            : 'Date non renseignée');
    final motif = suivi['motif_echange']?.toString() ?? suivi['motif']?.toString() ?? 'Suivi';
    final resume = suivi['resume_echange']?.toString() ?? suivi['resume']?.toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7B2CBF).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.assignment, color: Color(0xFF7B2CBF)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          motif,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              if (resume != null && resume.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  resume,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
