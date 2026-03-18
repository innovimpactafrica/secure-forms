/// Modèle d'un document d'identité retourné par l'API
class IdentityDocumentModel {
  final String id;
  final String kind; // RECTO | VERSO | SELFIE
  final String status;
  final String? fileName;
  final String? mimeType;
  final DateTime? uploadedAt;

  const IdentityDocumentModel({
    required this.id,
    required this.kind,
    required this.status,
    this.fileName,
    this.mimeType,
    this.uploadedAt,
  });

  factory IdentityDocumentModel.fromJson(Map<String, dynamic> json) {
    return IdentityDocumentModel(
      id: json['id']?.toString() ?? '',
      kind: json['kind'] ?? '',
      status: json['status'] ?? '',
      fileName: json['fileName'],
      mimeType: json['mimeType'],
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.tryParse(json['uploadedAt'].toString())
          : null,
    );
  }
}

/// Résultat de l'upload d'un document
class UploadDocumentResponse {
  final String id;
  final String kind;
  final String status;
  final String? message;

  const UploadDocumentResponse({
    required this.id,
    required this.kind,
    required this.status,
    this.message,
  });

  factory UploadDocumentResponse.fromJson(Map<String, dynamic> json) {
    return UploadDocumentResponse(
      id: json['id']?.toString() ?? '',
      kind: json['kind'] ?? '',
      status: json['status'] ?? '',
      message: json['message'],
    );
  }
}

/// Constantes pour les kinds de documents
class DocumentKind {
  static const String recto = 'RECTO';
  static const String verso = 'VERSO';
  static const String selfie = 'SELFIE';
}
