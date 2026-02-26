import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/reference_provider.dart';
import '../../providers/auth_provider.dart';

// Seul le sous-admin peut enregistrer des rôles (admin = observateur)
bool _isSousAdmin(String? role) {
  return role == 'sous_admin';
}

enum RoleType {
  administrateur,
  pasteur,
  famille,
  parrain,
  serviceSocial,
  travailleur,
}

class FormRoleScreen extends StatefulWidget {
  const FormRoleScreen({super.key});

  @override
  State<FormRoleScreen> createState() => _FormRoleScreenState();
}

class _FormRoleScreenState extends State<FormRoleScreen> {
  final _formKey = GlobalKey<FormState>();
  RoleType? _selectedRole;

  // Champs communs pour tous les rôles
  final _nomController = TextEditingController();
  final _prenomsController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _lieuResidenceController = TextEditingController();
  final _zoneSuiviController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

  // Champs spécifiques pour certains rôles
  final _descriptionController = TextEditingController();
  final _professionController = TextEditingController();
  final _entrepriseController = TextEditingController();
  int? _selectedFamilleId; // Pour parrain : famille à laquelle il est rattaché

  @override
  void dispose() {
    _nomController.dispose();
    _prenomsController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _telephoneController.dispose();
    _lieuResidenceController.dispose();
    _zoneSuiviController.dispose();
    _descriptionController.dispose();
    _professionController.dispose();
    _entrepriseController.dispose();
    super.dispose();
  }

  String _getRoleLabel(RoleType role) {
    switch (role) {
      case RoleType.administrateur:
        return 'Administrateur';
      case RoleType.pasteur:
        return 'Pasteur';
      case RoleType.famille:
        return 'Famille';
      case RoleType.parrain:
        return 'Parrain';
      case RoleType.serviceSocial:
        return 'Services Sociaux';
      case RoleType.travailleur:
        return 'Travailleur';
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un type de rôle'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final provider = Provider.of<ReferenceProvider>(context, listen: false);
    bool success = false;
    Map<String, dynamic> data = {};

    // Construire les données communes pour tous les rôles
    data = {
      'nom': _nomController.text.trim(),
      'prenoms': _prenomsController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'telephone': _telephoneController.text.trim().isEmpty
          ? null
          : _telephoneController.text.trim(),
      'lieu_de_residence': _lieuResidenceController.text.trim().isEmpty
          ? null
          : _lieuResidenceController.text.trim(),
      'zone_suivi': _zoneSuiviController.text.trim().isEmpty
          ? null
          : _zoneSuiviController.text.trim(),
    };

    // Ajouter le rôle selon le type sélectionné
    switch (_selectedRole!) {
      case RoleType.administrateur:
        data['role'] = 'admin';
        success = await provider.createUser(data);
        break;

      case RoleType.pasteur:
        data['role'] = 'pasteur';
        success = await provider.createPasteur(data);
        break;

      case RoleType.parrain:
        data['role'] = 'parrain';
        if (_selectedFamilleId != null) data['famille_id'] = _selectedFamilleId;
        success = await provider.createParrain(data);
        break;

      case RoleType.serviceSocial:
        data['role'] = 'service_social';
        if (_descriptionController.text.trim().isNotEmpty) {
          data['description'] = _descriptionController.text.trim();
        }
        success = await provider.createServiceSocial(data);
        break;

      case RoleType.famille:
        data['role'] = 'famille';
        if (_descriptionController.text.trim().isNotEmpty) {
          data['description'] = _descriptionController.text.trim();
        }
        success = await provider.createFamille(data);
        break;

      case RoleType.travailleur:
        data['role'] = 'travailleur';
        if (_professionController.text.trim().isNotEmpty) {
          data['profession'] = _professionController.text.trim();
        }
        if (_entrepriseController.text.trim().isNotEmpty) {
          data['entreprise'] = _entrepriseController.text.trim();
        }
        success = await provider.createTravailleur(data);
        break;
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('${_getRoleLabel(_selectedRole!)} enregistré avec succès!'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/roles');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Erreur lors de l\'enregistrement'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildCommonForm() {
    return Column(
      children: [
        // Nom
        TextFormField(
          controller: _nomController,
          decoration: const InputDecoration(
            labelText: 'Nom*',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Le nom est requis';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        // Prénoms
        TextFormField(
          controller: _prenomsController,
          decoration: const InputDecoration(
            labelText: 'Prénoms*',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Les prénoms sont requis';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        // Email
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email*',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'L\'email est requis';
            }
            if (!value.contains('@')) {
              return 'Email invalide';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        // Mot de passe
        TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Mot de passe*',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          obscureText: _obscurePassword,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Le mot de passe est requis';
            }
            if (value.length < 6) {
              return 'Le mot de passe doit contenir au moins 6 caractères';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        // Confirmation mot de passe
        TextFormField(
          controller: _passwordConfirmController,
          decoration: InputDecoration(
            labelText: 'Confirmer le mot de passe*',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePasswordConfirm
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscurePasswordConfirm = !_obscurePasswordConfirm;
                });
              },
            ),
          ),
          obscureText: _obscurePasswordConfirm,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez confirmer le mot de passe';
            }
            if (value != _passwordController.text) {
              return 'Les mots de passe ne correspondent pas';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        // Téléphone
        TextFormField(
          controller: _telephoneController,
          decoration: const InputDecoration(
            labelText: 'Téléphone',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        // Lieu de résidence
        TextFormField(
          controller: _lieuResidenceController,
          decoration: const InputDecoration(
            labelText: 'Lieu de résidence',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on),
          ),
        ),
        const SizedBox(height: 16),
        // Zone de suivi (pasteur) : quartiers séparés par des virgules pour le classement des fidèles
        if (_selectedRole == RoleType.pasteur) ...[
          TextFormField(
            controller: _zoneSuiviController,
            decoration: const InputDecoration(
              labelText: 'Zone de suivi (optionnel)',
              hintText:
                  'Ex: nouveau chu, centre-ville (quartiers séparés par des virgules)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.map),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
        ],
        // Champs spécifiques selon le rôle
        // Parrain : choix de la famille (obligatoire)
        if (_selectedRole == RoleType.parrain) ...[
          const SizedBox(height: 16),
          Consumer<ReferenceProvider>(
            builder: (context, refProvider, child) {
              return DropdownButtonFormField<int>(
                value: _selectedFamilleId,
                decoration: const InputDecoration(
                  labelText: 'Famille (rattachement)*',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.family_restroom),
                ),
                hint: const Text('Sélectionnez la famille du parrain'),
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('-- Choisir une famille --'),
                  ),
                  ...refProvider.familles.map((f) {
                    final nom = f['nom'] ?? f['name'] ?? 'Famille #${f['id']}';
                    return DropdownMenuItem<int>(
                      value: f['id'] as int,
                      child: Text(nom.toString()),
                    );
                  }),
                ],
                validator: (value) {
                  if (_selectedRole == RoleType.parrain && value == null) {
                    return 'Le parrain doit être rattaché à une famille';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() => _selectedFamilleId = value);
                },
              );
            },
          ),
          const SizedBox(height: 16),
        ],
        if (_selectedRole == RoleType.serviceSocial ||
            _selectedRole == RoleType.famille) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 4,
          ),
        ],
        if (_selectedRole == RoleType.travailleur) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _professionController,
            decoration: const InputDecoration(
              labelText: 'Profession',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.work),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _entrepriseController,
            decoration: const InputDecoration(
              labelText: 'Entreprise',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.business),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Seul le sous-admin peut accéder au formulaire d'ajout de rôle
    if (!_isSousAdmin(authProvider.user?.role)) {
      // Rediriger vers le dashboard si ce n'est pas un admin
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Accès refusé. Seul le sous-administrateur peut enregistrer des rôles.'),
              backgroundColor: Colors.red,
            ),
          );
          context.go('/dashboard');
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enregistrer un Rôle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/roles');
            }
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sélection du type de rôle
              DropdownButtonFormField<RoleType>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Type de rôle*',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                hint: const Text('Sélectionnez un type de rôle'),
                items: RoleType.values.map((role) {
                  return DropdownMenuItem<RoleType>(
                    value: role,
                    child: Text(_getRoleLabel(role)),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un type de rôle';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value;
                  });
                },
              ),
              const SizedBox(height: 32),

              // Formulaire dynamique selon le rôle sélectionné
              if (_selectedRole != null) ...[
                Text(
                  'Informations ${_getRoleLabel(_selectedRole!)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (_selectedRole != null) _buildCommonForm(),
                const SizedBox(height: 32),
              ],

              // Bouton de soumission
              Consumer<ReferenceProvider>(
                builder: (context, provider, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: provider.isLoading || _selectedRole == null
                          ? null
                          : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B2CBF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: provider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Enregistrer'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
