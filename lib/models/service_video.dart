class ServiceVideoComment {
  final String id;
  final String clientId;
  final String content;
  final bool isApproved;
  final bool isCommand;
  final String createdAt;

  ServiceVideoComment({
    required this.id,
    required this.clientId,
    required this.content,
    required this.isApproved,
    required this.isCommand,
    required this.createdAt,
  });

  factory ServiceVideoComment.fromJson(Map<String, dynamic> json) {
    return ServiceVideoComment(
      id: json['id'] ?? '',
      clientId: json['client_id'] ?? '',
      content: json['content'] ?? '',
      isApproved: json['is_approved'] ?? false,
      isCommand: json['is_command'] ?? false,
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'content': content,
      'is_approved': isApproved,
      'is_command': isCommand,
      'created_at': createdAt,
    };
  }
}

class ServiceVideo {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String thumbnailUrl;
  final String type; // TECHNICIAN, PRODUCT_USAGE, VLOG
  final int views;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final bool isPinned;
  final int commentCount;
  final List<ServiceVideoComment> comments;

  ServiceVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.type,
    required this.views,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.commentCount = 0,
    this.comments = const [],
  });

  factory ServiceVideo.fromJson(Map<String, dynamic> json) {
    final commentsList = json['comments'] as List?;
    return ServiceVideo(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      videoUrl: json['video_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      type: json['type'] ?? 'PRODUCT_USAGE',
      views: json['views'] ?? 0,
      isActive: json['is_active'] ?? true,
      isPinned: json['is_pinned'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      commentCount: json['comment_count'] ?? json['commentCount'] ?? 0,
      comments: commentsList != null
          ? commentsList.map((c) => ServiceVideoComment.fromJson(c)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'type': type,
      'views': views,
      'is_active': isActive,
      'is_pinned': isPinned,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'comments': comments.map((c) => c.toJson()).toList(),
    };
  }
}
