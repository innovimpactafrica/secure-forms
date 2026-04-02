class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type; // 'DOCUMENT_EXPIRING' | 'REQUEST_VALIDATED' | 'REQUEST_REJECTED' | etc.
  final String createdAt;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? json['body'] ?? '',
      type: json['type'] ?? 'info',
      createdAt: json['date'] ?? json['createdAt'] ?? '',
      isRead: json['isRead'] == true || json['read'] == true,
    );
  }

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
    id: id, title: title, message: message,
    type: type, createdAt: createdAt,
    isRead: isRead ?? this.isRead,
  );

  /// Retourne la date formatée pour l'affichage (aujourd'hui / hier / date)
  String get formattedDate {
    if (createdAt.isEmpty) return '';
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final itemDay = DateTime(dt.year, dt.month, dt.day);
      if (itemDay == today) return 'today';
      if (itemDay == yesterday) return 'yesterday';
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return createdAt;
    }
  }

  String get timeFormatted {
    if (createdAt.isEmpty) return '';
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
