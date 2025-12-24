import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../providers/fidele_provider.dart';
import '../../models/fidele.dart';

class EnregistrementScreen extends StatefulWidget {
  const EnregistrementScreen({super.key});

  @override
  State<EnregistrementScreen> createState() => _EnregistrementScreenState();
}

class _EnregistrementScreenState extends State<EnregistrementScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentPage = 0;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Informations personnelles
  final _nomController = TextEditingController();
  final _prenomsController = TextEditingController();
  String? _trancheAge;
  final _lieuResidenceController = TextEditingController();

  // Comment connu et but visite
  String? _commentConnu;
  String? _butVisite;

  // Qui invite et fréquente église
  String? _quiInvite;
  final _frequenteEgliseController = TextEditingController();
  bool _souhaiteAppartenir = false;
  DateTime? _dateArrivee;
  String? _appartientFamille;

  // Statut et profession
  String _statut = 'nouvel_ame';
  final _professionController = TextEditingController();

  // Contacts
  final _facebookController = TextEditingController();
  final _contactsController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _instagramController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _nomController.dispose();
    _prenomsController.dispose();
    _lieuResidenceController.dispose();
    _frequenteEgliseController.dispose();
    _professionController.dispose();
    _facebookController.dispose();
    _contactsController.dispose();
    _whatsappController.dispose();
    _instagramController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final fidele = Fidele(
      id: 0,
      nom: _nomController.text.trim(),
      prenoms: _prenomsController.text.trim(),
      trancheAge: _trancheAge,
      lieuResidence: _lieuResidenceController.text.trim(),
      commentConnu: _commentConnu,
      butVisite: _butVisite,
      quiInvite: _quiInvite,
      frequenteEglise: _frequenteEgliseController.text.trim(),
      souhaiteAppartenir: _souhaiteAppartenir,
      dateArrivee: _dateArrivee,
      appartientFamille: _appartientFamille,
      statut: _statut,
      profession: _professionController.text.trim(),
      facebook: _facebookController.text.trim(),
      contacts: _contactsController.text.trim(),
      whatsapp: _whatsappController.text.trim(),
      instagram: _instagramController.text.trim(),
      email: _emailController.text.trim(),
    );

    final provider = Provider.of<FideleProvider>(context, listen: false);
    final success = await provider.createFidele(
      fidele,
      photoPath: _selectedImage?.path,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enregistrement réussi!'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/fideles');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Erreur lors de l\'enregistrement'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvel Enregistrement'),
        actions: [
          if (_currentPage > 0)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          if (_currentPage < 3)
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          children: [
            _buildPage1(),
            _buildPage2(),
            _buildPage3(),
            _buildPage4(),
          ],
        ),
      ),
      bottomNavigationBar:
          _currentPage == 3
              ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B2CBF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Soumettre'),
                ),
              )
              : null,
    );
  }

  Widget _buildPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Information personnelle',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nomController,
            decoration: const InputDecoration(
              labelText: 'Nom*',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ce champ est requis';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _prenomsController,
            decoration: const InputDecoration(
              labelText: 'Prénoms*',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ce champ est requis';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _trancheAge,
            decoration: const InputDecoration(
              labelText: 'Tranche d\'âge',
              border: OutlineInputBorder(),
            ),
            hint: const Text('Faites un choix'),
            items: const [
              DropdownMenuItem(value: '5-11', child: Text('De 5 - 11 ans')),
              DropdownMenuItem(value: '12-17', child: Text('De 12 - 17 ans')),
              DropdownMenuItem(value: '18-25', child: Text('De 18 - 25 ans')),
              DropdownMenuItem(value: '26-35', child: Text('De 26 - 35 ans')),
              DropdownMenuItem(value: '36-45', child: Text('De 36 - 45 ans')),
              DropdownMenuItem(value: '46+', child: Text('Plus de 46 ans')),
            ],
            onChanged: (value) {
              setState(() {
                _trancheAge = value;
              });
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _lieuResidenceController,
            decoration: const InputDecoration(
              labelText: 'Lieu de résidence',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comment avez-vous connu la MEG-VIE ?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildRadioOption('Evangelisation', _commentConnu, (value) {
                setState(() => _commentConnu = value);
              }),
              _buildRadioOption('Media', _commentConnu, (value) {
                setState(() => _commentConnu = value);
              }),
              _buildRadioOption('Internet', _commentConnu, (value) {
                setState(() => _commentConnu = value);
              }),
              _buildRadioOption('Invitation', _commentConnu, (value) {
                setState(() => _commentConnu = value);
              }),
              _buildRadioOption('De passage', _commentConnu, (value) {
                setState(() => _commentConnu = value);
              }),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Quel est le but de votre visite ?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildRadioOption('Nouveau dans le quartier', _butVisite, (
                value,
              ) {
                setState(() => _butVisite = value);
              }),
              _buildRadioOption('Être membre', _butVisite, (value) {
                setState(() => _butVisite = value);
              }),
              _buildRadioOption('De passage', _butVisite, (value) {
                setState(() => _butVisite = value);
              }),
              _buildRadioOption('Invitation', _butVisite, (value) {
                setState(() => _butVisite = value);
              }),
              _buildRadioOption('Besoin de prière', _butVisite, (value) {
                setState(() => _butVisite = value);
              }),
              _buildRadioOption('Rencontrer un pasteur', _butVisite, (value) {
                setState(() => _butVisite = value);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPage3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Qui vous a invité?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildRadioOption('Un membre', _quiInvite, (value) {
                setState(() => _quiInvite = value);
              }),
              const SizedBox(width: 16),
              _buildRadioOption('Venu de moi-même', _quiInvite, (value) {
                setState(() => _quiInvite = value);
              }),
            ],
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _frequenteEgliseController,
            decoration: const InputDecoration(
              labelText: 'Fréquentez-vous une église ?',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Souhaitez-vous appartenir à la MEG-VIE ?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: _souhaiteAppartenir,
                onChanged: (value) {
                  setState(() => _souhaiteAppartenir = value ?? false);
                },
              ),
              const Text('Oui'),
              const SizedBox(width: 32),
              Radio<bool>(
                value: false,
                groupValue: _souhaiteAppartenir,
                onChanged: (value) {
                  setState(() => _souhaiteAppartenir = value ?? false);
                },
              ),
              const Text('Non'),
            ],
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => _dateArrivee = date);
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'à la MEG-VIE depuis*',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              child: Text(
                _dateArrivee != null
                    ? DateFormat('dd/MM/yyyy').format(_dateArrivee!)
                    : 'mm/dd/yyyy',
              ),
            ),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: _appartientFamille,
            decoration: const InputDecoration(
              labelText: 'Appartenez vous à une famille ?',
              border: OutlineInputBorder(),
            ),
            hint: const Text('Faites un choix'),
            items: const [
              DropdownMenuItem(value: 'Oui', child: Text('Oui')),
              DropdownMenuItem(value: 'Non', child: Text('Non')),
            ],
            onChanged: (value) {
              setState(() => _appartientFamille = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPage4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statut',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Radio<String>(
                value: 'fidele',
                groupValue: _statut,
                onChanged: (value) {
                  setState(() => _statut = value ?? 'nouvel_ame');
                },
              ),
              const Text('Fidèle'),
              const SizedBox(width: 32),
              Radio<String>(
                value: 'nouvel_ame',
                groupValue: _statut,
                onChanged: (value) {
                  setState(() => _statut = value ?? 'nouvel_ame');
                },
              ),
              const Text('Nouvel âme'),
            ],
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _professionController,
            decoration: const InputDecoration(
              labelText: 'Profession',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'photo',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  controller: TextEditingController(
                    text: _selectedImage?.name ?? '',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B2CBF),
                  foregroundColor: Colors.white,
                ),
                child: const Text('choisir'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Contacts',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _facebookController,
            decoration: const InputDecoration(
              labelText: 'Facebook',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _contactsController,
            decoration: const InputDecoration(
              labelText: 'Contacts*',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _whatsappController,
            decoration: const InputDecoration(
              labelText: 'Whatsapp',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _instagramController,
            decoration: const InputDecoration(
              labelText: 'Instagram',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(
    String label,
    String? selectedValue,
    Function(String) onChanged,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: label,
          groupValue: selectedValue,
          onChanged: (value) => onChanged(value!),
        ),
        Text(label),
      ],
    );
  }
}
