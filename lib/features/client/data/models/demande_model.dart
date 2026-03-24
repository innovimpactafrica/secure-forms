class SubmittedFormItem {
  final String label;
  final String pdfUrl;
  final String fileName;

  const SubmittedFormItem({
    required this.label,
    required this.pdfUrl,
    required this.fileName,
  });

  factory SubmittedFormItem.fromJson(Map<String, dynamic> json) {
    return SubmittedFormItem(
      label: json['label']?.toString() ?? '',
      pdfUrl: json['pdfUrl']?.toString() ?? '',
      fileName: json['fileName']?.toString() ?? '',
    );
  }
}

class RequiredDocumentItem {
  final String id;
  final String label;

  const RequiredDocumentItem({required this.id, required this.label});

  factory RequiredDocumentItem.fromJson(Map<String, dynamic> json) {
    return RequiredDocumentItem(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }
}

class DemandeModel {
  final String id;
  final String requestNumber;
  final String status;
  final String formType;
  final String organisationName;
  final String category;
  final String createdAt;
  final bool isDraft;
  final String? pdfUrl;
  final List<SubmittedFormItem> submittedForms;
  final List<RequiredDocumentItem> requiredDocuments;

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
    this.submittedForms = const [],
    this.requiredDocuments = const [],
  });

  factory DemandeModel.fromJson(Map<String, dynamic> json) {
    final org = json['organisation'] as Map<String, dynamic>?;
    final form = json['form'] as Map<String, dynamic>?;
    final submitted = json['submittedForm'] as Map<String, dynamic>?;

    final submittedFormsList = (json['submittedForms'] as List?)?.map(
      (e) => SubmittedFormItem.fromJson(e as Map<String, dynamic>),
    ).toList() ?? [];

    final requiredDocsList = (json['requiredDocuments'] as List?)?.map(
      (e) => RequiredDocumentItem.fromJson(e as Map<String, dynamic>),
    ).toList() ?? [];

    return DemandeModel(
      id: json['id']?.toString() ?? '',
      requestNumber: json['requestNumber']?.toString() ?? json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      formType: (json['formName']?.toString()?.isNotEmpty == true ? json['formName'].toString() : null) ??
          (form?['name']?.toString()?.isNotEmpty == true ? form!['name'].toString() : null) ??
          (json['formType']?.toString()?.isNotEmpty == true ? json['formType'].toString() : null) ??
          '',
      organisationName: (json['organisationName']?.toString()?.isNotEmpty == true ? json['organisationName'].toString() : null) ??
          org?['name']?.toString() ?? '',
      category: org?['sector']?.toString() ?? json['category']?.toString() ?? '',
      createdAt: _parseDate(json['createdAt']?.toString() ?? ''),
      isDraft: json['status']?.toString() == 'BROUILLON',
      pdfUrl: submitted?['pdfUrl']?.toString() ?? json['pdfUrl']?.toString(),
      submittedForms: submittedFormsList,
      requiredDocuments: requiredDocsList,
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
