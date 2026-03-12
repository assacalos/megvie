class Document {
  final int id;
  final String titre;
  final String? description;
  final String type;
  final String filePath;
  final String fileName;
  final String? mimeType;
  final int? fileSize;

  Document({
    required this.id,
    required this.titre,
    this.description,
    this.type = 'autre',
    required this.filePath,
    required this.fileName,
    this.mimeType,
    this.fileSize,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
      type: json['type'] ?? 'autre',
      filePath: json['file_path'] ?? '',
      fileName: json['file_name'] ?? '',
      mimeType: json['mime_type'],
      fileSize: json['file_size'],
    );
  }
}
