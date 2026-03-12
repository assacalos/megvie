import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/content_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/requete_priere.dart';
import '../../models/temoignage.dart';

class PriereTemoignagesScreen extends StatefulWidget {
  const PriereTemoignagesScreen({super.key});

  @override
  State<PriereTemoignagesScreen> createState() => _PriereTemoignagesScreenState();
}

class _PriereTemoignagesScreenState extends State<PriereTemoignagesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContentProvider>().fetchRequetesPriere();
      context.read<ContentProvider>().fetchTemoignages();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFidele = context.read<AuthProvider>().user?.isFidele == true;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prière & Témoignages'),
        backgroundColor: const Color(0xFF7B2CBF),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => isFidele ? context.go('/espace-fidele') : context.go('/dashboard'),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Requêtes de prière'), Tab(text: 'Témoignages')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _RequetesList(isFidele: isFidele),
          _TemoignagesList(isFidele: isFidele),
        ],
      ),
      floatingActionButton: isFidele
          ? null
          : null,
    );
  }
}

class _RequetesList extends StatelessWidget {
  final bool isFidele;

  const _RequetesList({required this.isFidele});

  @override
  Widget build(BuildContext context) {
    return Consumer<ContentProvider>(
      builder: (context, cp, _) {
        if (cp.isLoading && cp.requetesPriere.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            if (isFidele)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () => _showRequeteForm(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Soumettre une requête de prière'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B2CBF),
                    minimumSize: const Size(double.infinity, 44),
                  ),
                ),
              ),
            Expanded(
              child: cp.requetesPriere.isEmpty
                  ? const Center(child: Text('Aucune requête.'))
                  : RefreshIndicator(
                      onRefresh: () => cp.fetchRequetesPriere(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cp.requetesPriere.length,
                        itemBuilder: (context, i) {
                          final r = cp.requetesPriere[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(r.contenu, maxLines: 2, overflow: TextOverflow.ellipsis),
                              subtitle: Text('${r.statutLabel}${r.createdAt != null ? ' • ${DateFormat('dd/MM/yyyy').format(r.createdAt!)}' : ''}'),
                              onTap: () => showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Requête de prière'),
                                  content: SingleChildScrollView(child: Text(r.contenu)),
                                  actions: [
                                    if (!isFidele && r.statut != 'traitee')
                                      FilledButton(
                                        onPressed: () async {
                                          await cp.updateStatutRequetePriere(r.id, 'traitee');
                                          if (context.mounted) Navigator.pop(ctx);
                                        },
                                        child: const Text('Marquer traitée'),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showRequeteForm(BuildContext context) {
    final cp = context.read<ContentProvider>();
    final contenuC = TextEditingController();
    var isAnonyme = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setState) => AlertDialog(
          title: const Text('Requête de prière'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: contenuC, maxLines: 4, decoration: const InputDecoration(labelText: 'Votre requête')),
              CheckboxListTile(value: isAnonyme, onChanged: (v) => setState(() => isAnonyme = v ?? false), title: const Text('Soumettre anonymement')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('Annuler')),
            FilledButton(
              onPressed: () async {
                if (contenuC.text.trim().isEmpty) return;
                await cp.createRequetePriere(RequetePriere(id: 0, contenu: contenuC.text.trim(), isAnonyme: isAnonyme));
                if (context.mounted) {
                  Navigator.pop(ctx2);
                  cp.fetchRequetesPriere();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Requête envoyée.')));
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

class _TemoignagesList extends StatelessWidget {
  final bool isFidele;

  const _TemoignagesList({required this.isFidele});

  @override
  Widget build(BuildContext context) {
    return Consumer<ContentProvider>(
      builder: (context, cp, _) {
        if (cp.isLoading && cp.temoignages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            if (isFidele)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () => _showTemoignageForm(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Partager un témoignage'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B2CBF),
                    minimumSize: const Size(double.infinity, 44),
                  ),
                ),
              ),
            Expanded(
              child: cp.temoignages.isEmpty
                  ? const Center(child: Text('Aucun témoignage.'))
                  : RefreshIndicator(
                      onRefresh: () => cp.fetchTemoignages(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cp.temoignages.length,
                        itemBuilder: (context, i) {
                          final t = cp.temoignages[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(t.titre),
                              subtitle: Text('${t.statutLabel} • ${t.contenu.length > 80 ? '${t.contenu.substring(0, 80)}...' : t.contenu}'),
                              onTap: () => showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(t.titre),
                                  content: SingleChildScrollView(child: Text(t.contenu)),
                                  actions: [
                                    if (!isFidele && t.statut == 'en_attente')
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () async {
                                              await cp.updateTemoignage(t.id, {'statut': 'rejete'});
                                              if (context.mounted) Navigator.pop(ctx);
                                            },
                                            child: const Text('Rejeter'),
                                          ),
                                          FilledButton(
                                            onPressed: () async {
                                              await cp.updateTemoignage(t.id, {'statut': 'approuve'});
                                              if (context.mounted) Navigator.pop(ctx);
                                            },
                                            child: const Text('Approuver'),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showTemoignageForm(BuildContext context) {
    final cp = context.read<ContentProvider>();
    final titreC = TextEditingController();
    final contenuC = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Partager un témoignage'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titreC, decoration: const InputDecoration(labelText: 'Titre')),
              TextField(controller: contenuC, maxLines: 5, decoration: const InputDecoration(labelText: 'Votre témoignage')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          FilledButton(
            onPressed: () async {
              if (titreC.text.trim().isEmpty || contenuC.text.trim().isEmpty) return;
              await cp.createTemoignage(Temoignage(id: 0, titre: titreC.text.trim(), contenu: contenuC.text.trim()));
              if (context.mounted) {
                Navigator.pop(ctx);
                cp.fetchTemoignages();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Témoignage envoyé. Il sera publié après modération.')));
              }
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }
}
