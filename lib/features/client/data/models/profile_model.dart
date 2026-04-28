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
  final String id;              // id du premier fichier (files[0].id)
  final String documentTypeId;
  final String documentTypeTitle;
  final String status;
  final String? issueDate;
  final String? expirationDate;
  final DateTime? uploadedAt;
  final String? fileUrl;        // URL MinIO signée directe (files[0].filePath)
  final String? backFileId;     // id du deuxième fichier si présent (files[1].id)
  final String? backFileUrl;    // URL MinIO signée du verso (files[1].filePath)

  const UploadedDocumentModel({
    required this.id,
    required this.documentTypeId,
    required this.documentTypeTitle,
    required this.status,
    this.issueDate,
    this.expirationDate,
    this.uploadedAt,
    this.fileUrl,
    this.backFileId,
    this.backFileUrl,
  });

  factory UploadedDocumentModel.fromJson(Map<String, dynamic> json) {
    // Nouveau format bundle : {bundleKey, documentTypeId, files:[{id, filePath}]}
    // Format réponse upload : [{id, filePath, documentTypeId, status, ...}]
    final files = (json['files'] as List<dynamic>? ?? []);
    final firstFile  = files.isNotEmpty ? files[0] as Map<String, dynamic> : null;
    final secondFile = files.length > 1  ? files[1] as Map<String, dynamic> : null;

    // id : files[0].id > json['id']
    final id = firstFile?['id']?.toString()
        ?? json['id']?.toString()
        ?? '';

    // fileUrl : files[0].filePath > json['filePath'] > json['fileUrl']
    final fileUrl = firstFile?['filePath']?.toString()
        ?? json['filePath']?.toString()
        ?? json['fileUrl']?.toString();

    final backFileId  = secondFile?['id']?.toString();
    final backFileUrl = secondFile?['filePath']?.toString();

    final documentTypeId = (json['documentTypeId']
        ?? json['documentType']?['id']
        ?? '').toString();

    final documentTypeTitle = (json['label']
        ?? json['documentType']?['title']
        ?? json['documentTypeTitle']
        ?? '').toString();

    return UploadedDocumentModel(
      id: id,
      documentTypeId: documentTypeId,
      documentTypeTitle: documentTypeTitle,
      status: json['status']?.toString() ?? 'PENDING',
      issueDate: json['issueDate']?.toString(),
      expirationDate: json['expirationDate']?.toString(),
      uploadedAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : json['uploadedAt'] != null
              ? DateTime.tryParse(json['uploadedAt'].toString())
              : null,
      fileUrl: fileUrl,
      backFileId: backFileId,
      backFileUrl: backFileUrl,
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
