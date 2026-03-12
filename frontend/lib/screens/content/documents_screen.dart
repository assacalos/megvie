import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/content_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/document.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContentProvider>().fetchDocuments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFidele = context.read<AuthProvider>().user?.isFidele == true;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        backgroundColor: const Color(0xFF7B2CBF),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => isFidele ? context.go('/espace-fidele') : context.go('/dashboard'),
        ),
      ),
      body: Consumer<ContentProvider>(
        builder: (context, cp, _) {
          if (cp.isLoading && cp.documents.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (cp.documents.isEmpty) {
            return const Center(child: Text('Aucun document.'));
          }
          return RefreshIndicator(
            onRefresh: () => cp.fetchDocuments(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cp.documents.length,
              itemBuilder: (context, i) {
                final d = cp.documents[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.description, color: Color(0xFF7B2CBF)),
                    title: Text(d.titre),
                    subtitle: Text('${d.type} • ${d.fileName}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    trailing: const Icon(Icons.download),
                    onTap: () => _openDocument(context, d, cp),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: isFidele ? null : FloatingActionButton(
        onPressed: () => _pickAndUpload(context),
        child: const Icon(Icons.upload_file),
        backgroundColor: const Color(0xFF7B2CBF),
      ),
    );
  }

  void _openDocument(BuildContext context, Document d, ContentProvider cp) {
    final url = '${cp.documentBaseUrl}${d.filePath.replaceFirst('storage/', '')}';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(d.titre),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (d.description != null && d.description!.isNotEmpty) Text(d.description!),
            const SizedBox(height: 8),
            Text('Télécharger: ${d.fileName}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fermer')),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              // In a real app use url_launcher to open url
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Téléchargement: $url')));
            },
            icon: const Icon(Icons.download),
            label: const Text('Télécharger'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUpload(BuildContext context) async {
    final file = await FilePicker.platform.pickFiles(type: FileType.any);
    if (file == null || file.files.single.path == null) return;
    final path = file.files.single.path!;
    final titreC = TextEditingController();
    final descC = TextEditingController();
    var type = 'autre';
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setState) => AlertDialog(
          title: const Text('Ajouter un document'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titreC, decoration: const InputDecoration(labelText: 'Titre')),
              TextField(controller: descC, decoration: const InputDecoration(labelText: 'Description (optionnel)')),
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: 'reglement', child: Text('Règlement')),
                  DropdownMenuItem(value: 'formulaire', child: Text('Formulaire')),
                  DropdownMenuItem(value: 'autre', child: Text('Autre')),
                ],
                onChanged: (v) => setState(() => type = v ?? 'autre'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('Annuler')),
            FilledButton(
              onPressed: () async {
                final cp = context.read<ContentProvider>();
                final ok = await cp.uploadDocument(titreC.text.trim(), descC.text.trim().isEmpty ? null : descC.text.trim(), type, path);
                if (context.mounted) {
                  Navigator.pop(ctx2);
                  if (ok) {
                    cp.fetchDocuments();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document ajouté.')));
                  }
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
