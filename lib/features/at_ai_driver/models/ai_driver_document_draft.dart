class AiDriverDocumentDraft {
  final String id;
  final String title;
  final String description;
  final String? localFilePath;
  final String? originalFileName;
  final DateTime? capturedAt;

  const AiDriverDocumentDraft({
    required this.id,
    required this.title,
    required this.description,
    this.localFilePath,
    this.originalFileName,
    this.capturedAt,
  });

  bool get isCollected =>
      localFilePath != null && localFilePath!.trim().isNotEmpty;

  AiDriverDocumentDraft copyWith({
    String? localFilePath,
    String? originalFileName,
    DateTime? capturedAt,
  }) {
    return AiDriverDocumentDraft(
      id: id,
      title: title,
      description: description,
      localFilePath: localFilePath ?? this.localFilePath,
      originalFileName: originalFileName ?? this.originalFileName,
      capturedAt: capturedAt ?? this.capturedAt,
    );
  }

  AiDriverDocumentDraft withoutFile() {
    return AiDriverDocumentDraft(
      id: id,
      title: title,
      description: description,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'localFilePath': localFilePath,
    'originalFileName': originalFileName,
    'capturedAt': capturedAt?.toIso8601String(),
    'uploadStatus': 'notSubmitted',
    'networkDestination': null,
  };

  factory AiDriverDocumentDraft.fromJson(Map<String, dynamic> json) {
    return AiDriverDocumentDraft(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      localFilePath: json['localFilePath'] as String?,
      originalFileName: json['originalFileName'] as String?,
      capturedAt: json['capturedAt'] == null
          ? null
          : DateTime.tryParse(json['capturedAt'] as String),
    );
  }
}
