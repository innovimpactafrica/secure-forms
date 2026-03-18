/// Modèle de données du profil client
class ProfileModel {
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String birthDate;
  final String gender;
  final String maritalStatus;
  final List<DocumentModel> documents;
  final double progressPercent;

  const ProfileModel({
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
    this.email = '',
    this.birthDate = '',
    this.gender = '',
    this.maritalStatus = '',
    this.documents = const [],
    this.progressPercent = 0.50,
  });

  ProfileModel copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? birthDate,
    String? gender,
    String? maritalStatus,
    List<DocumentModel>? documents,
    double? progressPercent,
  }) {
    return ProfileModel(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      documents: documents ?? this.documents,
      progressPercent: progressPercent ?? this.progressPercent,
    );
  }
}

/// Modèle d'un document uploadé (local)
class DocumentModel {
  final String type;
  final String deliveryDate;
  final String expiryDate;
  final String filePath;
  final DocumentStatus status;

  const DocumentModel({
    required this.type,
    required this.deliveryDate,
    required this.expiryDate,
    required this.filePath,
    this.status = DocumentStatus.pending,
  });

  DocumentModel copyWith({
    String? type,
    String? deliveryDate,
    String? expiryDate,
    String? filePath,
    DocumentStatus? status,
  }) {
    return DocumentModel(
      type: type ?? this.type,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      expiryDate: expiryDate ?? this.expiryDate,
      filePath: filePath ?? this.filePath,
      status: status ?? this.status,
    );
  }
}

enum DocumentStatus { pending, validated, rejected, inProgress }

/// Types de documents requis (statique — fallback)
class DocumentType {
  static const String cni = 'profile.doc_cni';
  static const String nationality = 'profile.doc_nationality';
  static const String drivingLicense = 'profile.doc_driving_license';
  static const String residence = 'profile.doc_residence';
  static const String photo = 'profile.doc_photo';
  static const String property = 'profile.doc_property';

  static List<String> get all => [
        cni, nationality, drivingLicense,
        residence, photo, property,
      ];

  static List<String> get requireFaceId => [cni, drivingLicense, photo];

  static List<String> get hasExpiryDate => [cni, drivingLicense, residence];
}

// ─────────────────────────────────────────────────────────────────
// MODÈLES API — Profile Documents
// ─────────────────────────────────────────────────────────────────

/// Type de document retourné par GET /api/users/profile/document-types
class DocumentTypeModel {
  final String id;
  final String title;
  final bool hasExpirationDate;
  final bool isForIdentityVerification;
  final String mappedType;
  final bool isRequired;

  const DocumentTypeModel({
    required this.id,
    required this.title,
    required this.hasExpirationDate,
    required this.isForIdentityVerification,
    required this.mappedType,
    required this.isRequired,
  });

  factory DocumentTypeModel.fromJson(Map<String, dynamic> json) {
    return DocumentTypeModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      hasExpirationDate: json['hasExpirationDate'] == true,
      isForIdentityVerification: json['isForIdentityVerification'] == true,
      mappedType: json['mappedType']?.toString() ?? '',
      isRequired: json['isRequired'] == true,
    );
  }
}

/// Document uploadé retourné par GET /api/users/profile/documents
class UploadedDocumentModel {
  final String id;
  final String documentTypeId;
  final String documentTypeTitle;
  final String status;
  final String? issueDate;
  final String? expirationDate;
  final DateTime? uploadedAt;
  /// URL du fichier : GET /api/users/profile/documents/{id}/file
  final String? fileUrl;

  const UploadedDocumentModel({
    required this.id,
    required this.documentTypeId,
    required this.documentTypeTitle,
    required this.status,
    this.issueDate,
    this.expirationDate,
    this.uploadedAt,
    this.fileUrl,
  });

  factory UploadedDocumentModel.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    return UploadedDocumentModel(
      id: id,
      documentTypeId: (json['documentType']?['id'] ?? json['documentTypeId'] ?? '').toString(),
      documentTypeTitle: (json['documentType']?['title'] ?? json['documentTypeTitle'] ?? '').toString(),
      status: json['status']?.toString() ?? 'PENDING',
      issueDate: json['issueDate']?.toString(),
      expirationDate: json['expirationDate']?.toString(),
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.tryParse(json['uploadedAt'].toString())
          : null,
      fileUrl: json['fileUrl']?.toString(),
    );
  }
}

/// Complétion du profil retournée par GET /api/users/profile/completion
class ProfileCompletionModel {
  final int completion;
  final List<RequiredDocumentStatus> requiredDocuments;

  const ProfileCompletionModel({
    required this.completion,
    required this.requiredDocuments,
  });

  factory ProfileCompletionModel.fromJson(Map<String, dynamic> json) {
    final docs = (json['requiredDocuments'] as List<dynamic>? ?? [])
        .map((e) => RequiredDocumentStatus.fromJson(e as Map<String, dynamic>))
        .toList();
    return ProfileCompletionModel(
      completion: (json['completion'] as num?)?.toInt() ?? 50,
      requiredDocuments: docs,
    );
  }
}

/// Statut d'un document requis dans la complétion
class RequiredDocumentStatus {
  final String type;
  final String label;
  final bool isUploaded;
  final String status;
  final String? documentId;
  final String? uploadedAt;

  const RequiredDocumentStatus({
    required this.type,
    required this.label,
    required this.isUploaded,
    required this.status,
    this.documentId,
    this.uploadedAt,
  });

  factory RequiredDocumentStatus.fromJson(Map<String, dynamic> json) {
    return RequiredDocumentStatus(
      type: json['type']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      isUploaded: json['isUploaded'] == true,
      status: json['status']?.toString() ?? '',
      documentId: json['documentId']?.toString(),
      uploadedAt: json['uploadedAt']?.toString(),
    );
  }
}