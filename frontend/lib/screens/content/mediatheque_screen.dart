import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/content_provider.dart';
import '../../providers/auth_provider.dart';

class MediathequeScreen extends StatefulWidget {
  const MediathequeScreen({super.key});

  @override
  State<MediathequeScreen> createState() => _MediathequeScreenState();
}

class _MediathequeScreenState extends State<MediathequeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContentProvider>().fetchMediatheque();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFidele = context.read<AuthProvider>().user?.isFidele == true;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Médiathèque spirituelle'),
        backgroundColor: const Color(0xFF7B2CBF),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => isFidele ? context.go('/espace-fidele') : context.go('/dashboard'),
        ),
      ),
      body: Consumer<ContentProvider>(
        builder: (context, cp, _) {
          if (cp.isLoading && cp.mediatheque.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (cp.mediatheque.isEmpty) {
            return const Center(child: Text('Aucun contenu pour le moment.'));
          }
          return RefreshIndicator(
            onRefresh: () => cp.fetchMediatheque(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cp.mediatheque.length,
              itemBuilder: (context, i) {
                final m = cp.mediatheque[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(_iconForType(m.type), color: const Color(0xFF7B2CBF)),
                    title: Text(m.titre),
                    subtitle: Text(
                      '${m.typeLabel}${m.dureeFormatee.isNotEmpty ? ' • ${m.dureeFormatee}' : ''}${m.datePublication != null ? ' • ${DateFormat('dd/MM/yyyy').format(m.datePublication!)}' : ''}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    trailing: const Icon(Icons.play_circle_outline),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ouvrir: ${m.urlOrPath}')),
                      );
                    },
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
              onPressed: () => _showAddItem(context),
              child: const Icon(Icons.add),
              backgroundColor: const Color(0xFF7B2CBF),
            ),
    );
  }

  IconData _iconForType(String type) {
    if (type == 'video') return Icons.video_library;
    if (type == 'audio') return Icons.audiotrack;
    if (type == 'note_predication') return Icons.menu_book;
    return Icons.auto_stories;
  }

  void _showAddItem(BuildContext context) {
    final cp = context.read<ContentProvider>();
    final titreC = TextEditingController();
    final urlC = TextEditingController();
    final descC = TextEditingController();
    var type = 'video';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setState) => AlertDialog(
          title: const Text('Ajouter à la médiathèque'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titreC, decoration: const InputDecoration(labelText: 'Titre')),
                TextField(controller: urlC, decoration: const InputDecoration(labelText: 'URL ou chemin')),
                TextField(controller: descC, maxLines: 2, decoration: const InputDecoration(labelText: 'Description (optionnel)')),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: 'video', child: Text('Vidéo')),
                    DropdownMenuItem(value: 'audio', child: Text('Audio')),
                    DropdownMenuItem(value: 'note_predication', child: Text('Note de prédication')),
                    DropdownMenuItem(value: 'ressource_biblique', child: Text('Ressource biblique')),
                  ],
                  onChanged: (v) => setState(() => type = v ?? 'video'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('Annuler')),
            FilledButton(
              onPressed: () async {
                if (titreC.text.trim().isEmpty || urlC.text.trim().isEmpty) return;
                await cp.createMediathequeItem({
                  'titre': titreC.text.trim(),
                  'type': type,
                  'url_or_path': urlC.text.trim(),
                  'description': descC.text.trim().isEmpty ? null : descC.text.trim(),
                });
                if (context.mounted) {
                  Navigator.pop(ctx2);
                  cp.fetchMediatheque();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Élément ajouté.')));
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }
}
