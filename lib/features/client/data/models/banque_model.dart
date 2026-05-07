import 'package:quick_forms/core/utils/base_url.dart';

class BanqueModel {
  final String id;
  final String nom;
  final String description;
  final String sector;
  final String imagePath;
  final String? logoUrl;

  const BanqueModel({
    required this.id,
    required this.nom,
    required this.description,
    required this.sector,
    required this.imagePath,
    this.logoUrl,
  });

  factory BanqueModel.fromJson(Map<String, dynamic> json) {
    final sector = json['sector'] as String? ?? '';
    return BanqueModel(
      id: json['id'] as String? ?? '',
      nom: json['name'] as String? ?? '',
      description: sector,
      sector: sector,
      imagePath: '',
      logoUrl: json['logo'] != null
          ? BaseUrl.storageFile(json['logo'] as String)
          : null,
    );
  }
}
