import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/content_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/rendez_vous.dart';

class RendezVousScreen extends StatefulWidget {
  const RendezVousScreen({super.key});

  @override
  State<RendezVousScreen> createState() => _RendezVousScreenState();
}

class _RendezVousScreenState extends State<RendezVousScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContentProvider>().fetchRendezVous();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFidele = context.read<AuthProvider>().user?.isFidele == true;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rendez-vous'),
        backgroundColor: const Color(0xFF7B2CBF),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => isFidele ? context.go('/espace-fidele') : context.go('/dashboard'),
        ),
      ),
      body: Consumer<ContentProvider>(
        builder: (context, cp, _) {
          if (cp.isLoading && cp.rendezVous.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (cp.rendezVous.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Aucun rendez-vous.'),
                  if (isFidele) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showRequestForm(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Demander un rendez-vous'),
                    ),
                  ],
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => cp.fetchRendezVous(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cp.rendezVous.length,
              itemBuilder: (context, i) {
                final r = cp.rendezVous[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(Icons.event, color: _colorForStatut(r.statut)),
                    title: Text(r.sujet),
                    subtitle: Text(
                      '${r.typeLabel} • ${r.statutLabel}${r.dateSouhaitee != null ? ' • ${DateFormat('dd/MM/yyyy').format(r.dateSouhaitee!)}' : ''}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    onTap: () => _showDetail(context, r, cp, isFidele),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: isFidele
          ? FloatingActionButton(
              onPressed: () => _showRequestForm(context),
              child: const Icon(Icons.add),
              backgroundColor: const Color(0xFF7B2CBF),
            )
          : null,
    );
  }

  Color _colorForStatut(String s) {
    if (s == 'confirme') return Colors.green;
    if (s == 'effectue') return Colors.blue;
    if (s == 'annule') return Colors.red;
    return Colors.orange;
  }

  void _showDetail(BuildContext context, RendezVous r, ContentProvider cp, bool isFidele) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(r.sujet, style: Theme.of(ctx).textTheme.titleLarge),
            Text('${r.typeLabel} • ${r.statutLabel}'),
            if (r.dateSouhaitee != null) Text('Date souhaitée: ${DateFormat('dd/MM/yyyy').format(r.dateSouhaitee!)}'),
            if (r.noteFidele != null && r.noteFidele!.isNotEmpty) Text('Note: ${r.noteFidele}'),
          ],
        ),
      ),
    );
  }

  void _showRequestForm(BuildContext context) {
    final cp = context.read<ContentProvider>();
    final auth = context.read<AuthProvider>();
    final fideleId = auth.user?.fideleId;
    if (fideleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil fidèle non lié.')));
      return;
    }
    final sujetC = TextEditingController();
    final noteC = TextEditingController();
    var type = 'pastoral';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setState) => AlertDialog(
          title: const Text('Demander un rendez-vous'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: sujetC, decoration: const InputDecoration(labelText: 'Sujet / Motif')),
                TextField(controller: noteC, maxLines: 3, decoration: const InputDecoration(labelText: 'Message (optionnel)')),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: 'pastoral', child: Text('Rendez-vous pastoral')),
                    DropdownMenuItem(value: 'priere', child: Text('Prière')),
                    DropdownMenuItem(value: 'autre', child: Text('Autre')),
                  ],
                  onChanged: (v) => setState(() => type = v ?? 'pastoral'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('Annuler')),
            FilledButton(
              onPressed: () async {
                if (sujetC.text.trim().isEmpty) return;
                await cp.createRendezVous(RendezVous(
                  id: 0,
                  fideleId: fideleId,
                  type: type,
                  sujet: sujetC.text.trim(),
                  noteFidele: noteC.text.trim().isEmpty ? null : noteC.text.trim(),
                ));
                if (context.mounted) {
                  Navigator.pop(ctx2);
                  cp.fetchRendezVous();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demande envoyée.')));
                }
              },
              child: const Text('Envoyer'),
            ),
          ],
        ),
      ),
    );
  }
}
