import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/annonce.dart';
import '../providers/content_provider.dart';

/// Sheet de détail d'une annonce/actualité avec like, commentaires et partage.
class AnnonceDetailSheet extends StatefulWidget {
  final Annonce annonce;
  final bool isFidele;
  final VoidCallback? onEdit;

  const AnnonceDetailSheet({
    required this.annonce,
    this.isFidele = false,
    this.onEdit,
  });

  @override
  State<AnnonceDetailSheet> createState() => _AnnonceDetailSheetState();
}

class _AnnonceDetailSheetState extends State<AnnonceDetailSheet> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContentProvider>(
      builder: (context, cp, _) {
        final ann = cp.selectedAnnonce;
        final a = (ann != null && ann.id == widget.annonce.id) ? ann : widget.annonce;
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          expand: false,
          builder: (_, controller) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  a.titre,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  DateFormat('dd/MM/yyyy').format(a.datePublication),
                  style: TextStyle(color: Colors.grey[600]),
                ),
                if (widget.onEdit != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onEdit!();
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Modifier'),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        a.userHasLiked ? Icons.favorite : Icons.favorite_border,
                        color: a.userHasLiked ? Colors.red : null,
                      ),
                      onPressed: () => cp.toggleLikeAnnonce(a.id),
                    ),
                    Text('${a.likesCount}'),
                    IconButton(
                      icon: const Icon(Icons.comment_outlined),
                      onPressed: () {},
                    ),
                    Text('${a.commentsCount}'),
                    IconButton(
                      icon: const Icon(Icons.share_outlined),
                      onPressed: () => cp.partagerAnnonce(a.id),
                    ),
                    Text('${a.partagesCount}'),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    controller: controller,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(a.contenu),
                        const SizedBox(height: 16),
                        const Text('Commentaires', style: TextStyle(fontWeight: FontWeight.bold)),
                        ...(a.comments ?? []).map((c) => Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    child: Text(
                                      (c.user?['name'] ?? '?').toString().substring(0, 1).toUpperCase(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c.user?['name'] ?? 'Anonyme',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(c.contenu, style: const TextStyle(fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: 'Ajouter un commentaire...',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                          onSubmitted: (_) => _submitComment(cp, a.id),
                        ),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: () => _submitComment(cp, a.id),
                          child: const Text('Publier le commentaire'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitComment(ContentProvider cp, int annonceId) async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    _commentController.clear();
    await cp.addCommentAnnonce(annonceId, text);
  }
}
