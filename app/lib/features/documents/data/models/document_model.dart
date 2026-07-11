class DocumentModel {
  const DocumentModel({
    required this.id,
    required this.filename,
    required this.contentType,
    required this.sizeBytes,
    required this.createdAt,
  });

  final int id;
  final String filename;
  final String contentType;
  final int sizeBytes;
  final DateTime createdAt;

  factory DocumentModel.fromJson(Map<String, dynamic> json) => DocumentModel(
        id: json['id'] as int,
        filename: json['filename'] as String? ?? '',
        contentType: json['content_type'] as String? ?? 'application/octet-stream',
        sizeBytes: json['size_bytes'] as int? ?? 0,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
