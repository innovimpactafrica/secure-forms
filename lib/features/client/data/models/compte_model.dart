class CompteModel {
  final String id;
  final String numeroCompte;
  final String typeCompte;
  final String titulaire;

  const CompteModel({
    required this.id,
    required this.numeroCompte,
    required this.typeCompte,
    required this.titulaire,
  });

  factory CompteModel.fromJson(Map<String, dynamic> json) {
    return CompteModel(
      id: json['number'] as String? ?? '',
      numeroCompte: json['number'] as String? ?? '',
      typeCompte: json['accountType'] as String? ?? '',
      titulaire: json['holder'] as String? ?? '',
    );
  }
}
