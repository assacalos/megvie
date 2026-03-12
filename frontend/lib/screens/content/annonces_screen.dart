import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/content_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/annonce.dart';

class AnnoncesScreen extends StatefulWidget {
  const AnnoncesScreen({super.key});

  @override
  State<AnnoncesScreen> createState() => _AnnoncesScreenState();
}

class _AnnoncesScreenState extends State<AnnoncesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContentProvider>().fetchAnnonces();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFidele = context.read<AuthProvider>().user?.isFidele == true;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Annonces & Actualités'),
        backgroundColor: const Color(0xFF7B2CBF),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => isFidele ? context.go('/espace-fidele') : context.go('/dashboard'),
        ),
      ),
      body: Consumer<ContentProvider>(
        builder: (context, cp, _) {
          if (cp.isLoading && cp.annonces.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (cp.annonces.isEmpty) {
            return const Center(child: Text('Aucune annonce.'));
          }
          return RefreshIndicator(
            onRefresh: () => cp.fetchAnnonces(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cp.annonces.length,
              itemBuilder: (context, i) {
                final a = cp.annonces[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(Icons.campaign, color: a.isPinned ? Colors.amber : Colors.grey),
                    title: Text(a.titre, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${DateFormat('dd/MM/yyyy').format(a.datePublication)} • ${a.type == 'actualite' ? 'Actualité' : 'Annonce'}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    onTap: () => _openDetail(context, a, cp, isFidele),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: isFidele
          ? null
          : FloatingActionButton(
              onPressed: () => _showForm(context, null),
              child: const Icon(Icons.add),
              backgroundColor: const Color(0xFF7B2CBF),
            ),
    );
  }

  void _openDetail(BuildContext context, Annonce a, ContentProvider cp, bool isFidele) async {
    await cp.fetchAnnonce(a.id);
    if (!context.mounted) return;
    final ann = cp.selectedAnnonce;
    if (ann == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        expand: false,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(ann.titre, style: Theme.of(ctx).textTheme.titleLarge),
              Text(DateFormat('dd/MM/yyyy').format(ann.datePublication), style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 12),
              Expanded(child: SingleChildScrollView(controller: controller, child: Text(ann.contenu))),
              if (!isFidele)
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showForm(context, ann);
                  },
                  child: const Text('Modifier'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showForm(BuildContext context, Annonce? existing) {
    final titreC = TextEditingController(text: existing?.titre);
    final contenuC = TextEditingController(text: existing?.contenu);
    var type = existing?.type ?? 'annonce';
    var isPinned = existing?.isPinned ?? false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setState) => AlertDialog(
          title: Text(existing == null ? 'Nouvelle annonce' : 'Modifier l\'annonce'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titreC, decoration: const InputDecoration(labelText: 'Titre')),
                const SizedBox(height: 8),
                TextField(controller: contenuC, maxLines: 5, decoration: const InputDecoration(labelText: 'Contenu')),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [DropdownMenuItem(value: 'annonce', child: Text('Annonce')), DropdownMenuItem(value: 'actualite', child: Text('Actualité'))],
                  onChanged: (v) => setState(() => type = v ?? 'annonce'),
                ),
                CheckboxListTile(value: isPinned, onChanged: (v) => setState(() => isPinned = v ?? false), title: const Text('Épingler')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('Annuler')),
            FilledButton(
              onPressed: () async {
                final cp = context.read<ContentProvider>();
                if (existing != null) {
                  await cp.updateAnnonce(existing.id, {
                    'titre': titreC.text,
                    'contenu': contenuC.text,
                    'type': type,
                    'is_pinned': isPinned,
                  });
                } else {
                  await cp.createAnnonce(Annonce(
                    id: 0,
                    titre: titreC.text,
                    contenu: contenuC.text,
                    type: type,
                    datePublication: DateTime.now(),
                  ));
                }
                if (context.mounted) {
                  Navigator.pop(ctx2);
                  cp.fetchAnnonces();
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
