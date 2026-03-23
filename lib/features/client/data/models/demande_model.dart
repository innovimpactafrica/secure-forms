class DemandeModel {
  final String id;
  final String requestNumber;
  final String status;
  final String formType;
  final String organisationName;
  final String category;
  final String createdAt;
  final bool isDraft;
  final String? pdfUrl; // URL MinIO directe depuis submittedForm.pdfUrl

  const DemandeModel({
    required this.id,
    required this.requestNumber,
    required this.status,
    required this.formType,
    required this.organisationName,
    required this.category,
    required this.createdAt,
    this.isDraft = false,
    this.pdfUrl,
  });

  factory DemandeModel.fromJson(Map<String, dynamic> json) {
    final org = json['organisation'] as Map<String, dynamic>?;
    final form = json['form'] as Map<String, dynamic>?;
    final submitted = json['submittedForm'] as Map<String, dynamic>?;
    return DemandeModel(
      id: json['id']?.toString() ?? '',
      requestNumber: json['requestNumber']?.toString() ?? json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      // La réponse API retourne formName directement (pas form.name)
      formType: json['formName']?.toString() ??
          form?['name']?.toString() ??
          json['formType']?.toString() ?? '',
      organisationName: json['organisationName']?.toString() ??
          org?['name']?.toString() ?? '',
      category: org?['sector']?.toString() ?? json['category']?.toString() ?? '',
      createdAt: _parseDate(json['createdAt']?.toString() ?? ''),
      isDraft: json['status']?.toString() == 'BROUILLON',
      pdfUrl: submitted?['pdfUrl']?.toString() ?? json['pdfUrl']?.toString(),
    );
  }

  static String _parseDate(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}

class DemandesPage {
  final List<DemandeModel> items;
  final int total;
  final int page;
  final int limit;

  const DemandesPage({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  bool get hasMore => (page * limit) < total;
}
