import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/fidele_provider.dart';

class ListFidelesScreen extends StatefulWidget {
  const ListFidelesScreen({super.key});

  @override
  State<ListFidelesScreen> createState() => _ListFidelesScreenState();
}

class _ListFidelesScreenState extends State<ListFidelesScreen> {
  final _searchController = TextEditingController();
  String? _selectedTrancheAge;
  DateTime? _dateDebut;
  DateTime? _dateFin;
  bool _toutesDates = true;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste Des Fidèles Et Des Nouvelles Âmes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () {
              Provider.of<FideleProvider>(
                context,
                listen: false,
              ).fetchFideles();
              // TODO: Implémenter l'export
            },
            tooltip: 'Exporter les données',
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
                // Date filters
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'recherche par date',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: _toutesDates,
                      onChanged: (value) {
                        setState(() {
                          _toutesDates = value ?? true;
                          if (_toutesDates) {
                            _dateDebut = null;
                            _dateFin = null;
                          }
                        });
                      },
                    ),
                    const Text('Toutes les dates'),
                  ],
                ),
                if (!_toutesDates) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _dateDebut ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() => _dateDebut = date);
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date de début',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              _dateDebut != null
                                  ? '${_dateDebut!.day}/${_dateDebut!.month}/${_dateDebut!.year}'
                                  : 'mm/dd/yyyy',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _dateFin ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() => _dateFin = date);
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date de fin',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              _dateFin != null
                                  ? '${_dateFin!.day}/${_dateFin!.month}/${_dateFin!.year}'
                                  : 'mm/dd/yyyy',
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

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: provider.fideles.length,
                  itemBuilder: (context, index) {
                    final fidele = provider.fideles[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.person, color: Colors.amber),
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
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          context.go('/fideles/${fidele.id}');
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/fideles/enregistrement');
        },
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFF7B2CBF),
      ),
    );
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
}
