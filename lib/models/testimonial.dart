class Testimonial {
  final int id;
  final String clientName;
  final String content;
  final String mediaUrl;
  final String mediaType; // AUDIO, VIDEO, IMAGE
  final String category;
  String status;
  final String? activityDuration;
  final DateTime? createdAt;
  int likes;
  int views;

  Testimonial({
    required this.id,
    required this.clientName,
    required this.content,
    required this.mediaUrl,
    required this.mediaType,
    required this.category,
    this.status = 'ACTIVE',
    this.activityDuration,
    this.createdAt,
    this.likes = 0,
    this.views = 0,
  });

  factory Testimonial.fromJson(Map<String, dynamic> json) {
    return Testimonial(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      clientName: json['clientName'] ?? 'Client',
      content: json['content'] ?? '',
      mediaUrl: json['mediaUrl'] ?? '',
      mediaType: json['mediaType'] ?? 'IMAGE',
      category: json['category'] ?? 'Général',
      status: json['status'] ?? 'ACTIVE',
      activityDuration: json['activityDuration'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      likes: json['likes'] is int ? json['likes'] : 0,
      views: json['views'] is int ? json['views'] : 0,
    );
  }
}
