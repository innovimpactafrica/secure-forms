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
  final String? inProgressAt;
  final String? finalizedAt;
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
    this.inProgressAt,
    this.finalizedAt,
    this.isDraft = false,
    this.pdfUrl,
    this.submittedForms = const [],
    this.requiredDocuments = const [],
  });

  factory DemandeModel.fromJson(Map<String, dynamic> json) {
    final org = json['organisation'] as Map<String, dynamic>?;
    final form = json['form'] as Map<String, dynamic>?;
    final submitted = json['submittedForm'] as Map<String, dynamic>?;

    // ignore: avoid_print
    print('[DemandeModel.fromJson] keys=${json.keys.toList()}');
    // ignore: avoid_print
    print('[DemandeModel.fromJson] formName=${json["formName"]} | formType=${json["formType"]} | form=$form | organisationName=${json["organisationName"]} | organisation=$org | createdAt=${json["createdAt"]}');
    // ignore: avoid_print
    print('[DemandeModel.fromJson] inProgressAt=${json["inProgressAt"]} | processedAt=${json["processedAt"]} | finalizedAt=${json["finalizedAt"]} | validatedAt=${json["validatedAt"]}');

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
          (json['type']?.toString()?.isNotEmpty == true ? json['type'].toString() : null) ??
          '',
      organisationName: (json['organisationName']?.toString()?.isNotEmpty == true ? json['organisationName'].toString() : null) ??
          org?['name']?.toString() ??
          (json['institution']?.toString()?.isNotEmpty == true ? json['institution'].toString() : null) ??
          '',
      category: org?['sector']?.toString() ?? json['category']?.toString() ?? '',
      createdAt: _parseDate(
        (json['createdAt'] ?? json['date'])?.toString() ?? '',
      ),
      inProgressAt: _parseDateOrNull(json['updatedAt']),
      finalizedAt: _parseDateOrNull(json['finalizedAt']),
      isDraft: json['status']?.toString() == 'BROUILLON',
      pdfUrl: submitted?['pdfUrl']?.toString() ?? json['pdfUrl']?.toString(),
      submittedForms: submittedFormsList,
      requiredDocuments: requiredDocsList,
    );
  }

  static String? _parseDateOrNull(dynamic raw) {
    if (raw == null) return null;
    final s = raw.toString();
    if (s.isEmpty || s == 'null') return null;
    try {
      final dt = DateTime.parse(s);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return null;
    }
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
