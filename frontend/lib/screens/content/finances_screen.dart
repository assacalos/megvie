import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/content_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/operation_financiere.dart';

class FinancesScreen extends StatefulWidget {
  const FinancesScreen({super.key});

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cp = context.read<ContentProvider>();
      final auth = context.read<AuthProvider>();
      if (auth.user?.isFidele == true) {
        cp.fetchOperations();
        cp.fetchStatsFinance();
      } else {
        cp.fetchOperations();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFidele = context.read<AuthProvider>().user?.isFidele == true;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dîmes & Offrandes'),
        backgroundColor: const Color(0xFF7B2CBF),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => isFidele ? context.go('/espace-fidele') : context.go('/dashboard'),
        ),
      ),
      body: Consumer<ContentProvider>(
        builder: (context, cp, _) {
          if (cp.isLoading && cp.operations.isEmpty && cp.statsFinance == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: () async {
              await cp.fetchOperations();
              await cp.fetchStatsFinance();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (cp.statsFinance != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Résumé', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 8),
                            Text('Total: ${cp.statsFinance!['total'] ?? 0} ${cp.statsFinance!['par_type'] != null ? 'XOF' : ''}'),
                            Text('Nombre d\'opérations: ${cp.statsFinance!['nombre_operations'] ?? 0}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (cp.operations.isEmpty)
                    const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Aucune opération.')))
                  else
                    ...cp.operations.map((op) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(_iconForType(op.type), color: Colors.green),
                            title: Text('${op.typeLabel} • ${op.montant} ${op.devise}'),
                            subtitle: Text(DateFormat('dd/MM/yyyy').format(op.dateOperation), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          ),
                        )),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: isFidele
          ? FloatingActionButton(
              onPressed: () => _showDeclareForm(context),
              child: const Icon(Icons.add),
              backgroundColor: const Color(0xFF7B2CBF),
            )
          : null,
    );
  }

  IconData _iconForType(String type) {
    if (type == 'dime') return Icons.volunteer_activism;
    if (type == 'offrande') return Icons.card_giftcard;
    return Icons.payments;
  }

  void _showDeclareForm(BuildContext context) {
    final cp = context.read<ContentProvider>();
    final auth = context.read<AuthProvider>();
    final fideleId = auth.user?.fideleId;
    if (fideleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil fidèle non lié.')));
      return;
    }
    final montantC = TextEditingController();
    var type = 'offrande';
    var mode = 'especes';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setState) => AlertDialog(
          title: const Text('Déclarer un don'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: montantC,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Montant'),
                ),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: 'dime', child: Text('Dîme')),
                    DropdownMenuItem(value: 'offrande', child: Text('Offrande')),
                    DropdownMenuItem(value: 'don', child: Text('Don')),
                  ],
                  onChanged: (v) => setState(() => type = v ?? 'offrande'),
                ),
                DropdownButtonFormField<String>(
                  value: mode,
                  decoration: const InputDecoration(labelText: 'Mode de paiement'),
                  items: const [
                    DropdownMenuItem(value: 'especes', child: Text('Espèces')),
                    DropdownMenuItem(value: 'mobile_money', child: Text('Mobile Money')),
                    DropdownMenuItem(value: 'virement', child: Text('Virement')),
                  ],
                  onChanged: (v) => setState(() => mode = v ?? 'especes'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('Annuler')),
            FilledButton(
              onPressed: () async {
                final montant = double.tryParse(montantC.text.replaceAll(',', '.')) ?? 0;
                if (montant <= 0) return;
                await cp.createOperation(OperationFinanciere(
                  id: 0,
                  fideleId: fideleId,
                  type: type,
                  montant: montant,
                  dateOperation: DateTime.now(),
                  modePaiement: mode,
                ));
                if (context.mounted) {
                  Navigator.pop(ctx2);
                  cp.fetchOperations();
                  cp.fetchStatsFinance();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Déclaration enregistrée.')));
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
