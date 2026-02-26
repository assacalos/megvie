import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import '../models/fidele.dart';

class ExportService {
  /// Exporte une liste de fidèles en CSV
  static Future<void> exportFidelesToCSV(List<Fidele> fideles) async {
    if (fideles.isEmpty) {
      throw Exception('Aucun fidèle à exporter');
    }

    // En-têtes CSV
    final headers = [
      'ID',
      'Nom',
      'Prénoms',
      'Tranche d\'âge',
      'Lieu de résidence',
      'Email',
      'Téléphone',
      'Profession',
      'Statut',
      'Date d\'arrivée',
      'Parrain',
      'Pasteur',
      'Famille',
      'Facebook',
      'WhatsApp',
      'Instagram',
      'Comment connu',
      'But visite',
      'Fréquente église',
      'Souhaite appartenir',
    ];

    // Construire les lignes CSV
    final csvLines = <String>[headers.join(',')];

    for (final fidele in fideles) {
      final row = [
        fidele.id.toString(),
        _escapeCSV(fidele.nom),
        _escapeCSV(fidele.prenoms),
        _escapeCSV(fidele.trancheAge ?? ''),
        _escapeCSV(fidele.lieuResidence ?? ''),
        _escapeCSV(fidele.email ?? ''),
        _escapeCSV(fidele.contacts ?? ''),
        _escapeCSV(fidele.profession ?? ''),
        _escapeCSV(fidele.statut),
        fidele.dateArrivee != null
            ? fidele.dateArrivee!.toIso8601String().split('T')[0]
            : '',
        _escapeCSV(fidele.parrain?['name'] ?? fidele.parrain?['nom'] ?? ''),
        _escapeCSV(fidele.pasteur?['name'] ?? fidele.pasteur?['nom'] ?? ''),
        _escapeCSV(fidele.famille?['name'] ?? fidele.famille?['nom'] ?? ''),
        _escapeCSV(fidele.facebook ?? ''),
        _escapeCSV(fidele.whatsapp ?? ''),
        _escapeCSV(fidele.instagram ?? ''),
        _escapeCSV(fidele.commentConnu ?? ''),
        _escapeCSV(fidele.butVisite ?? ''),
        _escapeCSV(fidele.frequenteEglise ?? ''),
        fidele.souhaiteAppartenir ? 'Oui' : 'Non',
      ];
      csvLines.add(row.join(','));
    }

    final csvContent = csvLines.join('\n');
    final timestamp = DateTime.now().toIso8601String().split('T')[0];
    final fileName = 'fideles_export_$timestamp.csv';

    // Partager le fichier
    await Share.shareXFiles(
      [XFile.fromData(utf8.encode(csvContent), mimeType: 'text/csv', name: fileName)],
      text: 'Export des fidèles',
      subject: 'Export des fidèles MEG-VIE',
    );
  }

  /// Exporte un seul fidèle en CSV
  static Future<void> exportFideleToCSV(Fidele fidele) async {
    // En-têtes CSV
    final headers = [
      'Champ',
      'Valeur',
    ];

    // Construire les lignes CSV
    final csvLines = <String>[headers.join(',')];

    final data = [
      ['ID', fidele.id.toString()],
      ['Nom', fidele.nom],
      ['Prénoms', fidele.prenoms],
      ['Tranche d\'âge', fidele.trancheAge ?? ''],
      ['Lieu de résidence', fidele.lieuResidence ?? ''],
      ['Email', fidele.email ?? ''],
      ['Téléphone', fidele.contacts ?? ''],
      ['WhatsApp', fidele.whatsapp ?? ''],
      ['Facebook', fidele.facebook ?? ''],
      ['Instagram', fidele.instagram ?? ''],
      ['Profession', fidele.profession ?? ''],
      ['Statut', fidele.statut],
      ['Date d\'arrivée', fidele.dateArrivee != null
          ? fidele.dateArrivee!.toIso8601String().split('T')[0]
          : ''],
      ['Parrain', fidele.parrain?['name'] ?? fidele.parrain?['nom'] ?? ''],
      ['Pasteur', fidele.pasteur?['name'] ?? fidele.pasteur?['nom'] ?? ''],
      ['Famille', fidele.famille?['name'] ?? fidele.famille?['nom'] ?? ''],
      ['Comment connu', fidele.commentConnu ?? ''],
      ['But visite', fidele.butVisite ?? ''],
      ['Qui invite', fidele.quiInvite ?? ''],
      ['Fréquente église', fidele.frequenteEglise ?? ''],
      ['Souhaite appartenir', fidele.souhaiteAppartenir ? 'Oui' : 'Non'],
      ['Appartient famille', fidele.appartientFamille != null
          ? (fidele.appartientFamille! ? 'Oui' : 'Non')
          : ''],
      ['Formation', fidele.formation ?? ''],
      ['Années d\'expérience', fidele.anneeExperience?.toString() ?? ''],
    ];

    for (final row in data) {
      csvLines.add('${_escapeCSV(row[0])},${_escapeCSV(row[1])}');
    }

    // Ajouter les suivis si disponibles
    if (fidele.suivis != null && fidele.suivis!.isNotEmpty) {
      csvLines.add('');
      csvLines.add('Suivis,');
      for (var i = 0; i < fidele.suivis!.length; i++) {
        final suivi = fidele.suivis![i];
        csvLines.add('Suivi ${i + 1},${_escapeCSV(suivi.toString())}');
      }
    }

    // Ajouter les actions si disponibles
    if (fidele.actions != null && fidele.actions!.isNotEmpty) {
      csvLines.add('');
      csvLines.add('Actions,');
      for (var i = 0; i < fidele.actions!.length; i++) {
        final action = fidele.actions![i];
        csvLines.add('Action ${i + 1},${_escapeCSV(action.toString())}');
      }
    }

    final csvContent = csvLines.join('\n');
    final fileName = 'fidele_${fidele.nom}_${fidele.prenoms}_${DateTime.now().toIso8601String().split('T')[0]}.csv';

    await Share.shareXFiles(
      [XFile.fromData(utf8.encode(csvContent), mimeType: 'text/csv', name: fileName)],
      text: 'Export du fidèle ${fidele.nom} ${fidele.prenoms}',
      subject: 'Export fidèle MEG-VIE',
    );
  }

  /// Exporte les statistiques en CSV (pour l'admin observateur)
  static Future<void> exportStatsToCSV(Map<String, dynamic> stats) async {
    final headers = ['Indicateur', 'Valeur'];
    final csvLines = <String>[headers.join(',')];
    final labels = {
      'total': 'Nombre d\'enrolés',
      'baptises': 'Nombre de baptisés',
      'suivis': 'Nombre de suivis',
      'administrateurs': 'Nombre des administrateurs',
      'sans_famille': 'Sans famille',
      'sans_parrain': 'Sans parrain',
      'sans_pasteur': 'Sans pasteur',
      'fideles': 'Fidèles',
      'nouvelles_ames': 'Nouvelles âmes',
    };
    for (final e in stats.entries) {
      csvLines.add('${_escapeCSV(labels[e.key] ?? e.key)},${_escapeCSV(e.value?.toString() ?? '')}');
    }
    final csvContent = csvLines.join('\n');
    final fileName = 'statistiques_megvie_${DateTime.now().toIso8601String().split('T')[0]}.csv';
    await Share.shareXFiles(
      [XFile.fromData(utf8.encode(csvContent), mimeType: 'text/csv', name: fileName)],
      text: 'Statistiques MEG-VIE',
      subject: 'Statistiques MEG-VIE',
    );
  }

  /// Échappe les valeurs CSV (gère les virgules et guillemets)
  static String _escapeCSV(String value) {
    if (value.isEmpty) return '';
    
    // Si la valeur contient une virgule, un guillemet ou un saut de ligne, l'entourer de guillemets
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      // Échapper les guillemets en les doublant
      value = value.replaceAll('"', '""');
      return '"$value"';
    }
    
    return value;
  }
}

