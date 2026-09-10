class DocumentModel {
  final String? masterId;
  final String? masterType;
  final String? filePath;
  final String? fileName;
  final int? documentType;
  final String? downloadUrl;
  final String? id;

  const DocumentModel({
    this.masterId,
    this.masterType,
    this.filePath,
    this.fileName,
    this.documentType,
    this.downloadUrl,
    this.id,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      masterId: json['masterId'] as String?,
      masterType: json['masterType'] as String?,
      filePath: json['filePath'] as String?,
      fileName: json['fileName'] as String?,
      documentType: json['documentType'] as int?,
      downloadUrl: json['downloadUrl'] as String?,
      id: json['id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'masterId': masterId,
      'masterType': masterType,
      'filePath': filePath,
      'fileName': fileName,
      'documentType': documentType,
      'downloadUrl': downloadUrl,
      'id': id,
    };
  }

  DocumentModel copyWith({
    String? masterId,
    String? masterType,
    String? filePath,
    String? fileName,
    int? documentType,
    String? downloadUrl,
    String? id,
  }) {
    return DocumentModel(
      masterId: masterId ?? this.masterId,
      masterType: masterType ?? this.masterType,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      documentType: documentType ?? this.documentType,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      id: id ?? this.id,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DocumentModel &&
        other.masterId == masterId &&
        other.masterType == masterType &&
        other.filePath == filePath &&
        other.fileName == fileName &&
        other.documentType == documentType &&
        other.downloadUrl == downloadUrl &&
        other.id == id;
  }

  @override
  int get hashCode {
    return Object.hash(
      masterId,
      masterType,
      filePath,
      fileName,
      documentType,
      downloadUrl,
      id,
    );
  }

  @override
  String toString() {
    return 'DocumentModel(masterId: $masterId, masterType: $masterType, '
        'filePath: $filePath, fileName: $fileName, documentType: $documentType, '
        'downloadUrl: $downloadUrl, id: $id)';
  }

  // Convenience methods
  bool get hasValidId => id != null && id!.isNotEmpty;
  bool get hasValidUrl => downloadUrl != null && downloadUrl!.isNotEmpty;
  bool get isComplete => hasValidId && hasValidUrl && fileName != null;
}
