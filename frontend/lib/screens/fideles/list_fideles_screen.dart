import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/fidele_provider.dart';
import '../../models/fidele.dart';
import '../../services/export_service.dart';
import '../../services/api_service.dart';

class ListFidelesScreen extends StatefulWidget {
  const ListFidelesScreen({super.key});

  @override
  State<ListFidelesScreen> createState() => _ListFidelesScreenState();
}

enum _DateFilterMode { toutes, uneDate, intervalle }

class _ListFidelesScreenState extends State<ListFidelesScreen> {
  final _searchController = TextEditingController();
  String? _selectedTrancheAge;
  DateTime? _dateDebut;
  DateTime? _dateFin;
  _DateFilterMode _dateMode = _DateFilterMode.toutes;

  /// IDs des fidèles sélectionnés pour l'envoi de SMS en masse
  final Set<int> _selectedFideleIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FideleProvider>(context, listen: false).fetchFideles();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final provider = Provider.of<FideleProvider>(context, listen: false);
    provider.fetchFideles(
      search: _searchController.text.isEmpty ? null : _searchController.text,
      trancheAge: _selectedTrancheAge,
      dateDebut: _dateDebut?.toIso8601String().split('T')[0],
      dateFin: _dateFin?.toIso8601String().split('T')[0],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdminObserver = Provider.of<AuthProvider>(context).user?.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste Des Fidèles Et Des Nouvelles Âmes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => _exportAllFideles(context),
            tooltip: 'Exporter toute la liste',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filters
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'recherche sur les fidèles et les nouvelles âmes',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch();
                      },
                    ),
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
                const SizedBox(height: 16),
                // Tranche d'âge
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'recherche par tranche d\'âge',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildAgeFilter('tous', 'Tout les âges'),
                    _buildAgeFilter('5-11', 'De 5 - 11 ans'),
                    _buildAgeFilter('12-17', 'De 12 - 17 ans'),
                    _buildAgeFilter('18-25', 'De 18 - 25 ans'),
                    _buildAgeFilter('26-35', 'De 26 - 35 ans'),
                    _buildAgeFilter('36-45', 'De 36 - 45 ans'),
                    _buildAgeFilter('46+', 'Plus de 46 ans'),
                  ],
                ),
                const SizedBox(height: 16),
                // Recherche par date
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Recherche par date',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildDateModeChip(
                        _DateFilterMode.toutes, 'Toutes les dates'),
                    _buildDateModeChip(_DateFilterMode.uneDate, 'Une date'),
                    _buildDateModeChip(
                        _DateFilterMode.intervalle, 'Intervalle'),
                  ],
                ),
                if (_dateMode == _DateFilterMode.uneDate) ...[
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => _openCalendarSingleDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Sélectionner une date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                        hintText: 'Appuyez pour ouvrir le calendrier',
                      ),
                      child: Text(
                        _dateDebut != null
                            ? '${_dateDebut!.day.toString().padLeft(2, '0')}/${_dateDebut!.month.toString().padLeft(2, '0')}/${_dateDebut!.year}'
                            : 'Choisir la date',
                        style: TextStyle(
                          color: _dateDebut != null ? null : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
                if (_dateMode == _DateFilterMode.intervalle) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _openCalendarDateDebut(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date de début',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              _dateDebut != null
                                  ? '${_dateDebut!.day.toString().padLeft(2, '0')}/${_dateDebut!.month.toString().padLeft(2, '0')}/${_dateDebut!.year}'
                                  : 'dd/mm/aaaa',
                              style: TextStyle(
                                color: _dateDebut != null ? null : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () => _openCalendarDateFin(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date de fin',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              _dateFin != null
                                  ? '${_dateFin!.day.toString().padLeft(2, '0')}/${_dateFin!.month.toString().padLeft(2, '0')}/${_dateFin!.year}'
                                  : 'dd/mm/aaaa',
                              style: TextStyle(
                                color: _dateFin != null ? null : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _performSearch,
                    icon: const Icon(Icons.search),
                    label: const Text('Rechercher'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // List
          Expanded(
            child: Consumer<FideleProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Text(
                      provider.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (provider.fideles.isEmpty) {
                  return const Center(child: Text('Aucun fidèle trouvé'));
                }

                final allIds = provider.fideles.map((f) => f.id).toSet();
                final allSelected = allIds.isNotEmpty &&
                    allIds.every((id) => _selectedFideleIds.contains(id));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tout cocher / Tout décocher
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Material(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        child: CheckboxListTile(
                          value: allSelected,
                          tristate: true,
                          title: const Text(
                            'Tout cocher pour SMS',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            '${_selectedFideleIds.length} / ${provider.fideles.length} sélectionné(s)',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedFideleIds.addAll(allIds);
                              } else {
                                _selectedFideleIds.removeAll(allIds);
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: provider.fideles.length,
                  itemBuilder: (context, index) {
                    final fidele = provider.fideles[index];
                    final isSelected = _selectedFideleIds.contains(fidele.id);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Checkbox(
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedFideleIds.add(fidele.id);
                              } else {
                                _selectedFideleIds.remove(fidele.id);
                              }
                            });
                          },
                        ),
                        title: Text('${fidele.nom} ${fidele.prenoms}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (fidele.lieuResidence != null)
                              Text('Habitation: ${fidele.lieuResidence}'),
                            if (fidele.profession != null)
                              Text('Profession: ${fidele.profession}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.file_download, size: 20),
                              onPressed: () =>
                                  _exportSingleFidele(context, fidele),
                              tooltip: 'Exporter ce fidèle',
                              color: Colors.green,
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: () {
                          context.go('/fideles/${fidele.id}');
                        },
                      ),
                    );
                  },
                ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isAdminObserver
          ? null
          : Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_selectedFideleIds.isNotEmpty) ...[
            FloatingActionButton.extended(
              onPressed: _openSmsBottomSheet,
              icon: const Icon(Icons.sms),
              label: Text('SMS (${_selectedFideleIds.length})'),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            const SizedBox(height: 12),
          ],
          FloatingActionButton(
            onPressed: () {
              context.go('/fideles/enregistrement');
            },
            child: const Icon(Icons.add),
            backgroundColor: const Color(0xFF7B2CBF),
            foregroundColor: Colors.white,
          ),
        ],
      ),
    );
  }

  void _openSmsBottomSheet() {
    final messageController = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Envoyer un SMS à ${_selectedFideleIds.length} fidèle(s)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Message SMS',
                  hintText: 'Saisissez votre message...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                maxLength: 1600,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _sendBulkSms(
                        this.context,
                        messageController.text.trim(),
                      ),
                      icon: const Icon(Icons.send),
                      label: const Text('Envoyer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).then((_) => messageController.dispose());
  }

  Future<void> _sendBulkSms(BuildContext screenContext, String message) async {
    if (message.isEmpty) {
      ScaffoldMessenger.of(screenContext).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir un message'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final ids = _selectedFideleIds.toList();
    Navigator.pop(screenContext); // Fermer le bottom sheet

    showDialog<void>(
      context: screenContext,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Envoi des SMS en cours...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final apiService = ApiService();
      await apiService.sendBulkSms(ids, message);
      if (mounted) {
        Navigator.pop(screenContext); // Fermer le dialog de progression
        setState(() => _selectedFideleIds.clear());
        ScaffoldMessenger.of(screenContext).showSnackBar(
          const SnackBar(
            content: Text('SMS envoyés avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(screenContext);
        ScaffoldMessenger.of(screenContext).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'envoi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildAgeFilter(String value, String label) {
    final isSelected = _selectedTrancheAge == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedTrancheAge = selected ? value : null;
        });
      },
    );
  }

  Widget _buildDateModeChip(_DateFilterMode mode, String label) {
    final isSelected = _dateMode == mode;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _dateMode = mode;
          if (mode == _DateFilterMode.toutes) {
            _dateDebut = null;
            _dateFin = null;
          } else if (mode == _DateFilterMode.uneDate) {
            _dateFin = null;
          }
        });
      },
    );
  }

  Future<void> _openCalendarSingleDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateDebut ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null && mounted) {
      setState(() {
        _dateDebut = date;
        _dateFin = date;
      });
    }
  }

  Future<void> _openCalendarDateDebut(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateDebut ?? _dateFin ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: _dateFin ?? DateTime.now(),
    );
    if (date != null && mounted) {
      setState(() {
        _dateDebut = date;
        if (_dateFin != null && _dateFin!.isBefore(date)) {
          _dateFin = date;
        }
      });
    }
  }

  Future<void> _openCalendarDateFin(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateFin ?? _dateDebut ?? DateTime.now(),
      firstDate: _dateDebut ?? DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null && mounted) {
      setState(() {
        _dateFin = date;
        if (_dateDebut != null && _dateDebut!.isAfter(date)) {
          _dateDebut = date;
        }
      });
    }
  }

  Future<void> _exportAllFideles(BuildContext context) async {
    final provider = Provider.of<FideleProvider>(context, listen: false);

    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Récupérer tous les fidèles pour l'export
      final allFideles = await provider.fetchAllFidelesForExport();

      if (context.mounted) {
        Navigator.pop(context); // Fermer le dialog de chargement

        if (allFideles.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aucun fidèle à exporter'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        // Exporter en CSV
        await ExportService.exportFidelesToCSV(allFideles);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('${allFideles.length} fidèle(s) exporté(s) avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Fermer le dialog de chargement
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'export: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportSingleFidele(BuildContext context, Fidele fidele) async {
    try {
      await ExportService.exportFideleToCSV(fidele);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Fidèle ${fidele.nom} ${fidele.prenoms} exporté avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'export: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
