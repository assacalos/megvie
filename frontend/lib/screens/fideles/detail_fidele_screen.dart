import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/fidele_provider.dart';
import '../../providers/reference_provider.dart';
import '../../services/export_service.dart';
import '../../services/api_service.dart';

class DetailFideleScreen extends StatefulWidget {
  final int fideleId;

  const DetailFideleScreen({super.key, required this.fideleId});

  @override
  State<DetailFideleScreen> createState() => _DetailFideleScreenState();
}

class _DetailFideleScreenState extends State<DetailFideleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  /// Suivi S-P visible uniquement pour admin, sous_admin et service_social (pas pasteur, famille, parrain)
  bool _showSocioProTab = true;
  String? _currentUserRole;

  /// Baptêmes (pour pasteur) : synchronisé depuis le fidèle à l'affichage
  int _baptiseSyncedFideleId = -1;
  bool _baptiseEau = false;
  bool _baptiseSaintEsprit = false;
  bool _cureDAme = false;
  bool _delivrance = false;
  bool _mariage = false;

  // Controllers pour le formulaire de mise à jour
  int? _selectedParrainId;
  int? _selectedPasteurId;
  int? _selectedFamilleId;
  String? _selectedFormation;
  int? _selectedAnneeExperience;
  int? _selectedCorpsMetierId;

  // Controllers pour le suivi socio-professionnel
  String? _selectedTypeAction;
  final _montantController = TextEditingController();
  final _observationController = TextEditingController();
  final _commentaireController = TextEditingController();
  DateTime? _dateAction;
  int _nombreActions = 0;
  List<Map<String, dynamic>> _actionsList = [];

  // Controllers pour le suivi du fidèle
  String? _natureEchangeSuivi; // 'physique' | 'telephonique'
  final _motifEchangeSuiviController = TextEditingController();
  final _resumeEchangeSuiviController = TextEditingController();
  final _observationSuiviController = TextEditingController();
  DateTime? _dateSuivi;
  int _nombreSuivis = 0;
  List<Map<String, dynamic>> _suivisList = [];

  @override
  void initState() {
    super.initState();
    // Suivi S-P : uniquement admin, sous_admin, service_social. Pasteur voit Informations, Mise à jour, Suivi (avec baptêmes)
    final role = Provider.of<AuthProvider>(context, listen: false).user?.role;
    _currentUserRole = role;
    _showSocioProTab =
        role == 'admin' || role == 'sous_admin' || role == 'service_social';
    final tabCount = _showSocioProTab ? 4 : 3;
    _tabController =
        TabController(length: tabCount, vsync: this, initialIndex: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FideleProvider>(
        context,
        listen: false,
      ).fetchFidele(widget.fideleId);

      // Charger les données de référence
      Provider.of<ReferenceProvider>(
        context,
        listen: false,
      ).fetchAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _montantController.dispose();
    _observationController.dispose();
    _commentaireController.dispose();
    _observationSuiviController.dispose();
    _motifEchangeSuiviController.dispose();
    _resumeEchangeSuiviController.dispose();
    super.dispose();
  }

  Future<void> _exportFidele(BuildContext context) async {
    final provider = Provider.of<FideleProvider>(context, listen: false);
    final fidele = provider.selectedFidele;

    if (fidele == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune information de fidèle disponible'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

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

  // Méthode pour enregistrer une action socio-professionnelle
  Future<void> _handleSaveAction() async {
    if (_selectedTypeAction == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un type d\'action'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_dateAction == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une date'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final fidele =
        Provider.of<FideleProvider>(context, listen: false).selectedFidele;
    if (fidele == null) return;

    // Créer l'action et l'ajouter à la liste
    final actionData = {
      'date': DateFormat('dd/MM/yyyy').format(_dateAction!),
      'commentaire': _commentaireController.text.trim(),
      'observation': _observationController.text.trim(),
      'type': _selectedTypeAction,
      'montant': _montantController.text.trim().isNotEmpty
          ? int.tryParse(_montantController.text.trim()) ?? 0
          : 0,
    };

    // TODO: Envoyer l'action au backend via un provider dédié
    // await actionProvider.createAction(actionData);

    // Incrémenter le compteur et ajouter à la liste
    if (mounted) {
      setState(() {
        _nombreActions++;
        _actionsList.add(actionData);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Action enregistrée avec succès!'),
          backgroundColor: Colors.green,
        ),
      );

      // Réinitialiser le formulaire
      setState(() {
        _selectedTypeAction = null;
        _montantController.clear();
        _observationController.clear();
        _commentaireController.clear();
        _dateAction = null;
      });
    }
  }

  // Méthode pour enregistrer un suivi
  Future<void> _handleSaveSuivi() async {
    if (_dateSuivi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une date'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final provider = Provider.of<FideleProvider>(context, listen: false);
    final fidele = provider.selectedFidele;
    if (fidele == null) return;

    try {
      final apiService = ApiService();
      final response = await apiService.post(
        '/api/suivis',
        data: {
          'fidele_id': fidele.id,
          'nature_echange': _natureEchangeSuivi,
          'motif_echange': _motifEchangeSuiviController.text.trim().isEmpty
              ? null
              : _motifEchangeSuiviController.text.trim(),
          'resume_echange': _resumeEchangeSuiviController.text.trim().isEmpty
              ? null
              : _resumeEchangeSuiviController.text.trim(),
          'date': DateFormat('yyyy-MM-dd').format(_dateSuivi!),
          'observation': _observationSuiviController.text.trim(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await provider.fetchFidele(widget.fideleId);
        if (mounted) {
          final updatedFidele = provider.selectedFidele;
          setState(() {
            final raw = updatedFidele?.suivis ?? [];
            _suivisList = raw
                .map<Map<String, dynamic>>((s) => s is Map<String, dynamic>
                    ? Map<String, dynamic>.from(s)
                    : <String, dynamic>{})
                .toList();
            _nombreSuivis = _suivisList.length;
            _natureEchangeSuivi = null;
            _motifEchangeSuiviController.clear();
            _resumeEchangeSuiviController.clear();
            _observationSuiviController.clear();
            _dateSuivi = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Suivi enregistré avec succès!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'enregistrement: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Enregistre les baptêmes (baptisé d'eau, baptisé du Saint-Esprit) sur le fidèle.
  Future<void> _handleSaveBaptemes() async {
    final provider = Provider.of<FideleProvider>(context, listen: false);
    final fidele = provider.selectedFidele;
    if (fidele == null) return;

    final success = await provider.updateFidele(fidele.id, {
      'baptise_eau': _baptiseEau,
      'baptise_saint_esprit': _baptiseSaintEsprit,
    });

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Baptêmes enregistrés avec succès.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Erreur lors de l\'enregistrement'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Méthode pour mettre à jour le fidèle (champs envoyés selon le rôle)
  Future<void> _handleUpdate() async {
    final provider = Provider.of<FideleProvider>(context, listen: false);
    final fidele = provider.selectedFidele;

    if (fidele == null) return;

    final Map<String, dynamic> data = {};
    final role = _currentUserRole;

    // Admin / sous_admin : tous les champs
    if (role == 'admin' || role == 'sous_admin') {
      if (_selectedParrainId != null) data['parrain_id'] = _selectedParrainId;
      if (_selectedPasteurId != null) data['pasteur_id'] = _selectedPasteurId;
      if (_selectedFamilleId != null) data['famille_id'] = _selectedFamilleId;
      if (_selectedFormation != null) data['formation'] = _selectedFormation;
      if (_selectedAnneeExperience != null)
        data['annee_experience'] = _selectedAnneeExperience;
      if (_selectedCorpsMetierId != null)
        data['corps_metier_id'] = _selectedCorpsMetierId;
    }
    // Pasteur : photo, baptême eau, baptême saint esprit, cure d'âme, délivrance, mariage
    else if (role == 'pasteur') {
      data['baptise_eau'] = _baptiseEau;
      data['baptise_saint_esprit'] = _baptiseSaintEsprit;
      data['cure_d_ame'] = _cureDAme;
      data['delivrance'] = _delivrance;
      data['mariage'] = _mariage;
    }
    // Famille et Parrain : photo, parrain, pasteur, famille (pas formation, annee, corps_metier)
    else if (role == 'famille' || role == 'parrain') {
      if (_selectedParrainId != null) data['parrain_id'] = _selectedParrainId;
      if (_selectedPasteurId != null) data['pasteur_id'] = _selectedPasteurId;
      if (_selectedFamilleId != null) data['famille_id'] = _selectedFamilleId;
    }
    // Service social : photo, pasteur, famille (pas parrain)
    else if (role == 'service_social') {
      if (_selectedPasteurId != null) data['pasteur_id'] = _selectedPasteurId;
      if (_selectedFamilleId != null) data['famille_id'] = _selectedFamilleId;
    }
    // Travailleur : photo, formation, année d'expérience, corps métier
    else if (role == 'travailleur') {
      if (_selectedFormation != null) data['formation'] = _selectedFormation;
      if (_selectedAnneeExperience != null)
        data['annee_experience'] = _selectedAnneeExperience;
      if (_selectedCorpsMetierId != null)
        data['corps_metier_id'] = _selectedCorpsMetierId;
    }

    final success = await provider.updateFidele(fidele.id, data);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mise à jour réussie!'),
          backgroundColor: Colors.green,
        ),
      );

      await provider.fetchFidele(fidele.id);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Erreur lors de la mise à jour'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Affiche le choix entre appareil photo et galerie, puis envoie la photo au serveur.
  Future<void> _showPhotoSourcePicker(BuildContext context, dynamic fidele) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Prendre une photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir depuis la galerie'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Annuler'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;

      final provider = Provider.of<FideleProvider>(context, listen: false);
      final success = await provider.updateFidele(
        fidele.id,
        {},
        photoPath: file.path,
      );

      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo enregistrée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Erreur lors de l\'envoi de la photo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/fideles');
            }
          },
        ),
        title: const Text('Détails du Fidèle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => _exportFidele(context),
            tooltip: 'Exporter les informations',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            const Tab(text: 'Informations'),
            const Tab(text: 'Mise à jour'),
            const Tab(text: 'Suivi'),
            if (_showSocioProTab) const Tab(text: 'Suivi S-P'),
          ],
        ),
      ),
      body: Consumer<FideleProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final fidele = provider.selectedFidele;
          if (fidele == null) {
            return const Center(child: Text('Fidèle non trouvé'));
          }

          // Synchroniser l'état des baptêmes depuis le fidèle (une fois par fidèle)
          if (fidele.id != _baptiseSyncedFideleId) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && provider.selectedFidele?.id == fidele.id) {
                setState(() {
                  _baptiseSyncedFideleId = fidele.id;
                  _baptiseEau = fidele.baptiseEau ?? false;
                  _baptiseSaintEsprit = fidele.baptiseSaintEsprit ?? false;
                  _cureDAme = fidele.cureDAme ?? false;
                  _delivrance = fidele.delivrance ?? false;
                  _mariage = fidele.mariage ?? false;
                });
              }
            });
          }

          // Initialiser le compteur et la liste pour les actions si ce n'est pas déjà fait
          if (fidele.actions != null &&
              _actionsList.isEmpty &&
              _nombreActions == 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _nombreActions = fidele.actions!.length;
                  _actionsList =
                      List<Map<String, dynamic>>.from(fidele.actions!);
                });
              }
            });
          }

          // Initialiser le compteur et la liste pour les suivis si ce n'est pas déjà fait
          if (fidele.suivis != null &&
              _suivisList.isEmpty &&
              _nombreSuivis == 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _nombreSuivis = fidele.suivis!.length;
                  _suivisList = List<Map<String, dynamic>>.from(fidele.suivis!);
                });
              }
            });
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildInfoTab(fidele),
              _buildUpdateTab(fidele),
              _buildSuiviTab(fidele),
              if (_showSocioProTab) _buildSocioProTab(fidele),
            ],
          );
        },
      ),
    );
  }

  /// Retourne le nom de la famille si le fidèle appartient à une famille, sinon "Aucun".
  String _getFamilleDisplayName(dynamic fidele) {
    if (fidele.familleId == null && fidele.famille == null) return 'Aucun';
    final famille = fidele.famille;
    if (famille == null) return 'Aucun';
    final nom = famille['nom'] ?? famille['name'];
    if (nom == null || nom.toString().trim().isEmpty) return 'Aucun';
    return nom.toString().trim();
  }

  // TAB 1: INFORMATIONS
  Widget _buildInfoTab(dynamic fidele) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informations du fidèle
          _buildSection('Informations Du Fidèle', [
            _buildInfoRow(Icons.person, 'Nom', fidele.fullName),
            _buildInfoRow(
              Icons.access_time,
              'Identifiant/Age',
              fidele.trancheAge ?? 'Non renseigné',
            ),
            _buildInfoRow(
              Icons.home,
              'Adresse',
              fidele.lieuResidence ?? 'Non renseigné',
            ),
            _buildInfoRow(
              Icons.work,
              'Profession',
              fidele.profession ?? 'Non renseigné',
            ),
            _buildInfoRow(
              Icons.phone,
              'Téléphone 1',
              fidele.contacts ?? 'Non renseigné',
            ),
            _buildInfoRow(
              Icons.chat,
              'Téléphone 2',
              fidele.whatsapp ?? 'Non renseigné',
            ),
            _buildInfoRow(
              Icons.email,
              'Email',
              fidele.email ?? 'Non renseigné',
            ),
          ]),
          const SizedBox(height: 24),

          // AUTRES INFORMATIONS
          _buildSection('Autres Informations', [
            _buildInfoRow(
              Icons.person_add,
              'Parrain',
              fidele.parrain != null
                  ? '${fidele.parrain!['nom']} ${fidele.parrain!['prenoms']}'
                  : 'Non renseigné',
              dateMiseAJour: fidele.dateMiseAJourParrainage != null
                  ? DateFormat('dd/MM/yyyy HH:mm').format(fidele.dateMiseAJourParrainage!)
                  : null,
            ),
            _buildInfoRow(
              Icons.group,
              'Chef de disc',
              fidele.chefDisc != null
                  ? '${fidele.chefDisc!['nom']} ${fidele.chefDisc!['prenoms']}'
                  : 'Non renseigné',
              dateMiseAJour: fidele.dateMiseAJourParrainage != null
                  ? DateFormat('dd/MM/yyyy HH:mm').format(fidele.dateMiseAJourParrainage!)
                  : null,
            ),
            _buildInfoRow(
              Icons.church,
              'Suivi par',
              fidele.pasteur != null
                  ? '${fidele.pasteur!['nom']} ${fidele.pasteur!['prenoms']} depuis le ${fidele.dateArrivee != null ? DateFormat('dd/MM/yyyy').format(fidele.dateArrivee!) : "Non renseigné"}'
                  : 'Non renseigné',
              dateMiseAJour: fidele.dateMiseAJourParrainage != null
                  ? DateFormat('dd/MM/yyyy HH:mm').format(fidele.dateMiseAJourParrainage!)
                  : null,
            ),
            const Divider(height: 24),
            // Baptêmes et champs pasteur : date MAJ pasteur
            _buildInfoRow(
              Icons.water,
              'Baptisé d\'eau',
              (fidele.baptiseEau == true) ? 'Oui' : 'Non',
              dateMiseAJour: fidele.dateMiseAJourPasteur != null
                  ? DateFormat('dd/MM/yyyy HH:mm').format(fidele.dateMiseAJourPasteur!)
                  : null,
            ),
            _buildInfoRow(
              Icons.water_drop,
              'Baptisé du Saint-Esprit',
              (fidele.baptiseSaintEsprit == true) ? 'Oui' : 'Non',
              dateMiseAJour: fidele.dateMiseAJourPasteur != null
                  ? DateFormat('dd/MM/yyyy HH:mm').format(fidele.dateMiseAJourPasteur!)
                  : null,
            ),
            _buildInfoRow(
              Icons.favorite,
              'Cure d\'âme',
              (fidele.cureDAme == true) ? 'Oui' : 'Non',
              dateMiseAJour: fidele.dateMiseAJourPasteur != null
                  ? DateFormat('dd/MM/yyyy HH:mm').format(fidele.dateMiseAJourPasteur!)
                  : null,
            ),
            _buildInfoRow(
              Icons.volunteer_activism,
              'Délivrance',
              (fidele.delivrance == true) ? 'Oui' : 'Non',
              dateMiseAJour: fidele.dateMiseAJourPasteur != null
                  ? DateFormat('dd/MM/yyyy HH:mm').format(fidele.dateMiseAJourPasteur!)
                  : null,
            ),
            _buildInfoRow(
              Icons.favorite_border,
              'Mariage',
              (fidele.mariage == true) ? 'Oui' : 'Non',
              dateMiseAJour: fidele.dateMiseAJourPasteur != null
                  ? DateFormat('dd/MM/yyyy HH:mm').format(fidele.dateMiseAJourPasteur!)
                  : null,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.family_restroom,
              'Appartient à la famille',
              _getFamilleDisplayName(fidele),
              dateMiseAJour: fidele.dateMiseAJourParrainage != null
                  ? DateFormat('dd/MM/yyyy HH:mm').format(fidele.dateMiseAJourParrainage!)
                  : null,
            ),
            if (fidele.dateDerniereMiseAJour != null) ...[
              const Divider(height: 24),
              _buildInfoRow(
                Icons.update,
                'Dernière mise à jour globale',
                DateFormat('dd/MM/yyyy HH:mm').format(fidele.dateDerniereMiseAJour!),
              ),
            ],
          ]),
        ],
      ),
    );
  }

  // TAB 2: MISE À JOUR (champs selon le rôle)
  Widget _buildUpdateTab(dynamic fidele) {
    final role = _currentUserRole;
    final isAdmin = role == 'admin' || role == 'sous_admin';
    final isPasteur = role == 'pasteur';
    final isFamilleOrParrain = role == 'famille' || role == 'parrain';
    final isServiceSocial = role == 'service_social';
    final isTravailleur = role == 'travailleur';

    return Consumer<ReferenceProvider>(
      builder: (context, refProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection('Mise À Jour', [
                // Dates des différentes mises à jour
                if (fidele.dateMiseAJourPasteur != null ||
                    fidele.dateMiseAJourParrainage != null ||
                    fidele.dateMiseAJourSocioPro != null ||
                    fidele.dateDerniereMiseAJour != null) ...[
                  const Text(
                    'Dates des mises à jour',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (fidele.dateMiseAJourPasteur != null)
                    _buildInfoRow(
                      Icons.church,
                      'Dernière mise à jour (pasteur)',
                      DateFormat('dd/MM/yyyy HH:mm').format(fidele.dateMiseAJourPasteur!),
                    ),
                  if (fidele.dateMiseAJourParrainage != null)
                    _buildInfoRow(
                      Icons.family_restroom,
                      'Dernière mise à jour (parrain / pasteur / famille)',
                      DateFormat('dd/MM/yyyy HH:mm').format(fidele.dateMiseAJourParrainage!),
                    ),
                  if (fidele.dateMiseAJourSocioPro != null)
                    _buildInfoRow(
                      Icons.work,
                      'Dernière mise à jour (formation / corps métier)',
                      DateFormat('dd/MM/yyyy HH:mm').format(fidele.dateMiseAJourSocioPro!),
                    ),
                  if (fidele.dateDerniereMiseAJour != null)
                    _buildInfoRow(
                      Icons.update,
                      'Dernière mise à jour globale',
                      DateFormat('dd/MM/yyyy HH:mm').format(fidele.dateDerniereMiseAJour!),
                    ),
                  const SizedBox(height: 16),
                ],
                // Photo : tous les rôles
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Photo',
                          border: const OutlineInputBorder(),
                          hintText: fidele.photo != null && fidele.photo.toString().isNotEmpty
                              ? 'Photo enregistrée'
                              : 'Aucune photo',
                        ),
                        readOnly: true,
                        onTap: () => _showPhotoSourcePicker(context, fidele),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showPhotoSourcePicker(context, fidele),
                      icon: const Icon(Icons.add_photo_alternate, size: 20),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B2CBF),
                        foregroundColor: Colors.white,
                      ),
                      label: const Text('Choisir'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // --- PASTEUR : baptême eau, baptême saint esprit, cure d'âme, délivrance, mariage ---
                if (isPasteur) ...[
                  CheckboxListTile(
                    value: _baptiseEau,
                    onChanged: (value) {
                      setState(() => _baptiseEau = value ?? false);
                    },
                    title: const Text('Baptisé d\'eau'),
                    secondary: const Icon(Icons.water, color: Colors.blue),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    value: _baptiseSaintEsprit,
                    onChanged: (value) {
                      setState(() => _baptiseSaintEsprit = value ?? false);
                    },
                    title: const Text('Baptisé du Saint-Esprit'),
                    secondary: const Icon(Icons.water_drop, color: Colors.blue),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    value: _cureDAme,
                    onChanged: (value) {
                      setState(() => _cureDAme = value ?? false);
                    },
                    title: const Text('Cure d\'âme'),
                    secondary: const Icon(Icons.favorite, color: Colors.red),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    value: _delivrance,
                    onChanged: (value) {
                      setState(() => _delivrance = value ?? false);
                    },
                    title: const Text('Délivrance'),
                    secondary: const Icon(Icons.volunteer_activism),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    value: _mariage,
                    onChanged: (value) {
                      setState(() => _mariage = value ?? false);
                    },
                    title: const Text('Mariage'),
                    secondary: const Icon(Icons.favorite_border),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],

                // --- Famille + Parrain : parrain, pasteur, famille (pas formation, annee, corps_metier) ---
                if (isFamilleOrParrain) ...[
                  DropdownButtonFormField<int>(
                    value: _selectedParrainId ?? fidele.parrainId,
                    decoration: InputDecoration(
                      labelText: 'Parrain',
                      border: const OutlineInputBorder(),
                      hintText: fidele.familleId == null
                          ? 'Choisissez d\'abord une famille pour voir les parrains'
                          : 'Faites un choix',
                    ),
                    hint: Text(fidele.familleId == null
                        ? 'Choisissez d\'abord une famille'
                        : 'Faites un choix'),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('Faites un choix')),
                      ...refProvider.parrains
                          .where((parrain) =>
                              fidele.familleId != null &&
                              parrain['famille_id'] == fidele.familleId)
                          .map((parrain) {
                        return DropdownMenuItem<int>(
                          value: parrain['id'],
                          child: Text('${parrain['nom']} ${parrain['prenoms']}'),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedParrainId = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _selectedPasteurId ?? fidele.pasteurId,
                    decoration: const InputDecoration(
                      labelText: 'Choix d\'un pasteur pour le suivi',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Faites un choix'),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('Faites un choix')),
                      ...refProvider.pasteurs.map((pasteur) {
                        return DropdownMenuItem<int>(
                          value: pasteur['id'],
                          child: Text('${pasteur['nom']} ${pasteur['prenoms']}'),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedPasteurId = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _selectedFamilleId ?? fidele.familleId,
                    decoration: const InputDecoration(
                      labelText: 'Choix d\'une famille',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Faites un choix'),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('Faites un choix')),
                      ...refProvider.familles.map((famille) {
                        return DropdownMenuItem<int>(
                          value: famille['id'],
                          child: Text(famille['nom']),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedFamilleId = value);
                    },
                  ),
                ],

                // --- Service social : pasteur, famille (pas parrain) ---
                if (isServiceSocial) ...[
                  DropdownButtonFormField<int>(
                    value: _selectedPasteurId ?? fidele.pasteurId,
                    decoration: const InputDecoration(
                      labelText: 'Choix d\'un pasteur pour le suivi',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Faites un choix'),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('Faites un choix')),
                      ...refProvider.pasteurs.map((pasteur) {
                        return DropdownMenuItem<int>(
                          value: pasteur['id'],
                          child: Text('${pasteur['nom']} ${pasteur['prenoms']}'),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedPasteurId = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _selectedFamilleId ?? fidele.familleId,
                    decoration: const InputDecoration(
                      labelText: 'Choix d\'une famille',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Faites un choix'),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('Faites un choix')),
                      ...refProvider.familles.map((famille) {
                        return DropdownMenuItem<int>(
                          value: famille['id'],
                          child: Text(famille['nom']),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedFamilleId = value);
                    },
                  ),
                ],

                // --- Travailleur : formation, année d'expérience, corps métier ---
                if (isTravailleur) ...[
                  DropdownButtonFormField<String>(
                    value: _selectedFormation ?? fidele.formation,
                    decoration: const InputDecoration(
                      labelText: 'Formation',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Choix'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Choix')),
                      DropdownMenuItem(value: 'Aucune', child: Text('Aucune')),
                      DropdownMenuItem(
                          value: 'Primaire', child: Text('Primaire')),
                      DropdownMenuItem(
                          value: 'Secondaire', child: Text('Secondaire')),
                      DropdownMenuItem(
                          value: 'Universitaire', child: Text('Universitaire')),
                      DropdownMenuItem(
                          value: 'Professionnelle',
                          child: Text('Professionnelle')),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedFormation = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _selectedAnneeExperience ?? fidele.anneeExperience,
                    decoration: const InputDecoration(
                      labelText: 'Année d\'expérience',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Choix'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Choix')),
                      for (int i = 0; i <= 40; i++)
                        DropdownMenuItem(
                            value: i, child: Text('$i an${i > 1 ? 's' : ''}')),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedAnneeExperience = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _selectedCorpsMetierId ?? fidele.corpsMetierId,
                    decoration: const InputDecoration(
                      labelText: 'Corps de métiers',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Faites un choix'),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('Faites un choix')),
                      ...refProvider.corpsMetiers.map((corps) {
                        return DropdownMenuItem<int>(
                          value: corps['id'],
                          child: Text(corps['nom']),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedCorpsMetierId = value);
                    },
                  ),
                ],

                // --- Admin / sous_admin : tous les champs ---
                if (isAdmin) ...[
                  DropdownButtonFormField<int>(
                    value: _selectedParrainId ?? fidele.parrainId,
                    decoration: InputDecoration(
                      labelText: 'Parrain',
                      border: const OutlineInputBorder(),
                      hintText: fidele.familleId == null
                          ? 'Choisissez d\'abord une famille pour voir les parrains'
                          : 'Faites un choix',
                    ),
                    hint: Text(fidele.familleId == null
                        ? 'Choisissez d\'abord une famille'
                        : 'Faites un choix'),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('Faites un choix')),
                      ...refProvider.parrains
                          .where((parrain) =>
                              fidele.familleId != null &&
                              parrain['famille_id'] == fidele.familleId)
                          .map((parrain) {
                        return DropdownMenuItem<int>(
                          value: parrain['id'],
                          child: Text('${parrain['nom']} ${parrain['prenoms']}'),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedParrainId = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _selectedPasteurId ?? fidele.pasteurId,
                    decoration: const InputDecoration(
                      labelText: 'Choix d\'un pasteur pour le suivi',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Faites un choix'),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('Faites un choix')),
                      ...refProvider.pasteurs.map((pasteur) {
                        return DropdownMenuItem<int>(
                          value: pasteur['id'],
                          child: Text('${pasteur['nom']} ${pasteur['prenoms']}'),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedPasteurId = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _selectedFamilleId ?? fidele.familleId,
                    decoration: const InputDecoration(
                      labelText: 'Choix d\'une famille',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Faites un choix'),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('Faites un choix')),
                      ...refProvider.familles.map((famille) {
                        return DropdownMenuItem<int>(
                          value: famille['id'],
                          child: Text(famille['nom']),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedFamilleId = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedFormation ?? fidele.formation,
                    decoration: const InputDecoration(
                      labelText: 'Formation',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Choix'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Choix')),
                      DropdownMenuItem(value: 'Aucune', child: Text('Aucune')),
                      DropdownMenuItem(
                          value: 'Primaire', child: Text('Primaire')),
                      DropdownMenuItem(
                          value: 'Secondaire', child: Text('Secondaire')),
                      DropdownMenuItem(
                          value: 'Universitaire', child: Text('Universitaire')),
                      DropdownMenuItem(
                          value: 'Professionnelle',
                          child: Text('Professionnelle')),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedFormation = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _selectedAnneeExperience ?? fidele.anneeExperience,
                    decoration: const InputDecoration(
                      labelText: 'Année d\'expérience',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Choix'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Choix')),
                      for (int i = 0; i <= 40; i++)
                        DropdownMenuItem(
                            value: i, child: Text('$i an${i > 1 ? 's' : ''}')),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedAnneeExperience = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _selectedCorpsMetierId ?? fidele.corpsMetierId,
                    decoration: const InputDecoration(
                      labelText: 'Corps de métiers',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Faites un choix'),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('Faites un choix')),
                      ...refProvider.corpsMetiers.map((corps) {
                        return DropdownMenuItem<int>(
                          value: corps['id'],
                          child: Text(corps['nom']),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedCorpsMetierId = value);
                    },
                  ),
                ],
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: role != 'admin'
                      ? ElevatedButton(
                    onPressed: _handleUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B2CBF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Mise à jour'),
                  )
                      : const SizedBox.shrink(),
                ),
              ]),
            ],
          ),
        );
      },
    );
  }

  // TAB 3: SUIVI DU FIDÈLE
  Widget _buildSuiviTab(dynamic fidele) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('Suivi Du Fidèle', [
            // Nature de l'échange
            const Text(
              'Nature de l\'échange',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Physique'),
                  selected: _natureEchangeSuivi == 'physique',
                  onSelected: (selected) {
                    setState(() {
                      _natureEchangeSuivi = selected ? 'physique' : null;
                    });
                  },
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('Téléphonique'),
                  selected: _natureEchangeSuivi == 'telephonique',
                  onSelected: (selected) {
                    setState(() {
                      _natureEchangeSuivi = selected ? 'telephonique' : null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Motif de l'échange
            TextFormField(
              controller: _motifEchangeSuiviController,
              decoration: const InputDecoration(
                labelText: 'Motif de l\'échange',
                border: OutlineInputBorder(),
                hintText: 'Raison de l\'échange...',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Résumé de l'échange
            TextFormField(
              controller: _resumeEchangeSuiviController,
              decoration: const InputDecoration(
                labelText: 'Résumé de l\'échange',
                border: OutlineInputBorder(),
                hintText: 'Résumez l\'échange...',
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),

            // Date
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dateSuivi ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() => _dateSuivi = date);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _dateSuivi != null
                      ? DateFormat('dd/MM/yyyy').format(_dateSuivi!)
                      : 'mm/dd/yyyy',
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Observation
            const Text(
              'Observation',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _observationSuiviController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Saisissez vos observations...',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),

            // Bouton Enregistrer (masqué pour admin observateur)
            if (_currentUserRole != 'admin')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSaveSuivi,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B2CBF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Enregistrer'),
                ),
              ),
          ]),
          const SizedBox(height: 24),

          // Bouton Nombre de suivi avec incrémentation
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  // Le compteur s'incrémente automatiquement lors de l'enregistrement
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF7B2CBF)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Nombre de suivi',
                      style: TextStyle(color: Color(0xFF7B2CBF)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_nombreSuivis',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tableau des suivis
          _buildSection('Historique des suivis', [
            if (_suivisList.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Nature')),
                    DataColumn(label: Text('Motif')),
                    DataColumn(label: Text('Résumé')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Observation')),
                  ],
                  rows: _suivisList.map<DataRow>((suivi) {
                    final nature = suivi['nature_echange'];
                    final natureLabel = nature == 'physique'
                        ? 'Physique'
                        : nature == 'telephonique'
                            ? 'Téléphonique'
                            : '—';
                    return DataRow(
                      cells: [
                        DataCell(Text(natureLabel)),
                        DataCell(Text(suivi['motif_echange']?.toString() ?? '—')),
                        DataCell(Text(suivi['resume_echange']?.toString() ?? '—')),
                        DataCell(Text(suivi['date']?.toString() ?? 'N/A')),
                        DataCell(Text(suivi['observation']?.toString() ?? '—')),
                      ],
                    );
                  }).toList(),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text('Aucun suivi'),
                ),
              ),
          ]),
        ],
      ),
    );
  }

  // TAB 4: SUIVI ENCADREMENT SOCIO-PROFESSIONNEL
  Widget _buildSocioProTab(dynamic fidele) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('Suivi Encadrement Socio-Professionnel', [
            // Type d'action
            const Text(
              'Type d\'action',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Action sociale'),
                  selected: _selectedTypeAction == 'action_sociale',
                  onSelected: (selected) {
                    setState(() {
                      _selectedTypeAction = selected ? 'action_sociale' : null;
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Attribution de marché'),
                  selected: _selectedTypeAction == 'attribution_marche',
                  onSelected: (selected) {
                    setState(() {
                      _selectedTypeAction =
                          selected ? 'attribution_marche' : null;
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Accompagnement projet'),
                  selected: _selectedTypeAction == 'accompagnement_projet',
                  onSelected: (selected) {
                    setState(() {
                      _selectedTypeAction =
                          selected ? 'accompagnement_projet' : null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Montant
            TextFormField(
              controller: _montantController,
              decoration: const InputDecoration(
                labelText: 'Montant',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Commentaire
            TextFormField(
              controller: _commentaireController,
              decoration: const InputDecoration(
                labelText: 'Commentaire',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Observation
            TextFormField(
              controller: _observationController,
              decoration: const InputDecoration(
                labelText: 'Observation',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),

            // Date de l'action
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() => _dateAction = date);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date de l\'action',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _dateAction != null
                      ? DateFormat('dd/MM/yyyy').format(_dateAction!)
                      : 'mm/dd/yyyy',
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bouton Enregistrer l'action (masqué pour admin observateur)
            if (_currentUserRole != 'admin')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSaveAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B2CBF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Enregistrer l\'action'),
                ),
              ),
          ]),
          const SizedBox(height: 24),

          // Bouton Nombre d'action avec incrémentation
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  // Le compteur s'incrémente automatiquement lors de l'enregistrement
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF7B2CBF)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Nombre d\'action',
                      style: TextStyle(color: Color(0xFF7B2CBF)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_nombreActions',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tableau des actions
          _buildSection('Historique des actions', [
            if (_actionsList.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('date de l\'action')),
                    DataColumn(label: Text('commentaire')),
                    DataColumn(label: Text('observation')),
                  ],
                  rows: _actionsList.map<DataRow>((action) {
                    return DataRow(
                      cells: [
                        DataCell(Text(action['date'] ?? 'N/A')),
                        DataCell(Text(action['commentaire'] ?? '')),
                        DataCell(Text(action['observation'] ?? '')),
                      ],
                    );
                  }).toList(),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text('Aucune action'),
                ),
              ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {String? dateMiseAJour}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (dateMiseAJour != null && dateMiseAJour.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'MAJ le $dateMiseAJour',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
