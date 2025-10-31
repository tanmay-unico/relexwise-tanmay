class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final Map<String, dynamic>? metadata;
  final bool isRead;
  final bool isDeleted;
  final bool sent;
  final DateTime receivedAt;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.metadata,
    required this.isRead,
    required this.isDeleted,
    required this.sent,
    required this.receivedAt,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      body: json['body'],
      metadata: json['metadata'],
      isRead: json['isRead'],
      isDeleted: json['isDeleted'],
      sent: json['sent'],
      receivedAt: DateTime.parse(json['receivedAt']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'metadata': metadata,
      'isRead': isRead,
      'isDeleted': isDeleted,
      'sent': sent,
      'receivedAt': receivedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

