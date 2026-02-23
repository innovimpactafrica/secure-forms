/// Modèle de données du profil client
/// TODO: connecter à l'API — ajouter fromJson/toJson lors de l'intégration
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
    this.progressPercent = 0.30,
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

/// Modèle d'un document uploadé
class DocumentModel {
  final String type;         // CNI, Permis, etc.
  final String deliveryDate;
  final String expiryDate;
  final String filePath;     // chemin local temporaire avant upload API
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

/// Types de documents requis
class DocumentType {
  static const String cni = 'Pièce d\'identité (CNI)';
  static const String nationality = 'Certificat de nationalité';
  static const String drivingLicense = 'Permis de conduire';
  static const String residence = 'Certificat de résidence';
  static const String photo = 'Photo d\'identité';
  static const String property = 'Titre de propriété';

  static List<String> get all => [
        cni,
        nationality,
        drivingLicense,
        residence,
        photo,
        property,
      ];

  // Documents qui nécessitent une vérification Face ID
  static List<String> get requireFaceId => [cni, drivingLicense, photo];
}