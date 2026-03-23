class ArchiveModel {
  final String id;
  final String type; // 'request' | 'document'
  final String title;
  final String institution;
  final String date;
  final String status;
  final String? documentType;
  final bool isRequest;
  final String? pdfUrl;    // type=request : submittedForm.pdfUrl MinIO
  final String? filePath;  // type=document : filePath MinIO direct

  const ArchiveModel({
    required this.id,
    required this.type,
    required this.title,
    required this.institution,
    required this.date,
    required this.status,
    this.documentType,
    this.isRequest = true,
    this.pdfUrl,
    this.filePath,
  });

  factory ArchiveModel.fromJson(Map<String, dynamic> json) {
    final rawType = json['type']?.toString().toLowerCase() ?? 'request';
    final isRequest = rawType == 'request';
    final submitted = json['submittedForm'] as Map<String, dynamic>?;
    return ArchiveModel(
      id: json['id']?.toString() ?? '',
      type: rawType,
      title: json['title']?.toString() ??
          json['formName']?.toString() ??
          json['label']?.toString() ?? '',
      institution: json['organisationName']?.toString() ??
          json['institution']?.toString() ??
          json['bankName']?.toString() ?? '',
      date: _parseDate(
          json['date']?.toString() ?? json['createdAt']?.toString() ?? ''),
      status: json['status']?.toString() ?? '',
      documentType: json['documentType']?.toString(),
      isRequest: isRequest,
      pdfUrl: submitted?['pdfUrl']?.toString() ?? json['pdfUrl']?.toString(),
      // Pour les documents profil, le filePath est l'URL MinIO signée
      filePath: isRequest ? null : json['filePath']?.toString(),
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
