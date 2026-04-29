import 'package:secure_link/core/utils/base_url.dart';

class BanqueModel {
  final String id;
  final String nom;
  final String description;
  final String imagePath;
  final String? logoUrl;

  const BanqueModel({
    required this.id,
    required this.nom,
    required this.description,
    required this.imagePath,
    this.logoUrl,
  });

  factory BanqueModel.fromJson(Map<String, dynamic> json) {
    return BanqueModel(
      id: json['id'] as String? ?? '',
      nom: json['name'] as String? ?? '',
      description: json['sector'] as String? ?? '',
      imagePath: '',
      logoUrl: json['logo'] != null
          ? BaseUrl.storageFile(json['logo'] as String)
          : null,
    );
  }
}
