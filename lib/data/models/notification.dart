class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? relatedId; // ID de l'école, filière ou document lié

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.relatedId,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    String? relatedId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      relatedId: relatedId ?? this.relatedId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.toString(),
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'relatedId': relatedId,
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => NotificationType.document,
      ),
      createdAt: DateTime.parse(map['createdAt']),
      isRead: map['isRead'] ?? false,
      relatedId: map['relatedId'],
    );
  }
}

enum NotificationType {
  document,
  ecole,
  filiere,
}

extension NotificationTypeExtension on NotificationType {
  String get label {
    switch (this) {
      case NotificationType.document:
        return 'Nouveau document';
      case NotificationType.ecole:
        return 'Nouvelle école';
      case NotificationType.filiere:
        return 'Nouvelle filière';
    }
  }

  String get icon {
    switch (this) {
      case NotificationType.document:
        return '📄';
      case NotificationType.ecole:
        return '🏫';
      case NotificationType.filiere:
        return '📚';
    }
  }
}

