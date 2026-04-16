class ActivityLog {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;

  ActivityLog({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
