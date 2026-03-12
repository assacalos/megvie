import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Écran de détail d'un suivi : affiche toutes les informations d'un suivi
/// (nature, motif, résumé, date, observation, commentaire, statut).
class DetailSuiviScreen extends StatelessWidget {
  final int fideleId;
  final String? fideleNom;
  final Map<String, dynamic> suivi;

  const DetailSuiviScreen({
    super.key,
    required this.fideleId,
    this.fideleNom,
    required this.suivi,
  });

  static const String routeName = '/fideles/suivis/detail';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nature = suivi['nature_echange']?.toString();
    final natureLabel = nature == 'physique'
        ? 'Physique'
        : nature == 'telephonique'
            ? 'Téléphonique'
            : '—';
    final dateStr = suivi['date']?.toString();
    DateTime? date;
    if (dateStr != null && dateStr.isNotEmpty) {
      try {
        date = DateTime.tryParse(dateStr);
      } catch (_) {}
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail du suivi'),
        backgroundColor: const Color(0xFF7B2CBF),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (fideleNom != null && fideleNom!.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: Color(0xFF7B2CBF)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          fideleNom!,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            _buildSection(context, 'Nature de l\'échange', natureLabel),
            _buildSection(context, 'Motif de l\'échange',
                suivi['motif_echange']?.toString() ?? '—'),
            _buildSection(context, 'Résumé de l\'échange',
                suivi['resume_echange']?.toString() ?? '—'),
            _buildSection(
              context,
              'Date',
              date != null
                  ? DateFormat('dd/MM/yyyy').format(date)
                  : (dateStr ?? 'N/A'),
            ),
            _buildSection(context, 'Statut',
                _formatStatut(suivi['statut']?.toString())),
            _buildSection(context, 'Observation',
                suivi['observation']?.toString() ?? '—'),
            _buildSection(context, 'Commentaire',
                suivi['commentaire']?.toString() ?? '—'),
          ],
        ),
      ),
    );
  }

  String _formatStatut(String? statut) {
    if (statut == null || statut.isEmpty) return '—';
    switch (statut) {
      case 'pas_interesse':
        return 'Pas intéressé';
      case 'injoignable':
        return 'Injoignable';
      case 'confirme':
        return 'Confirmé';
      case 'visite_prochaine_fois':
        return 'Visite prochaine fois';
      default:
        return statut;
    }
  }

  Widget _buildSection(
      BuildContext context, String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF7B2CBF),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
