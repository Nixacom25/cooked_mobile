class Testimonial {
  final String id;
  final String? clientId;
  final String? clientName;
  final String? categoryId;
  final String? categoryName;
  final String content;
  final String mediaUrl;
  final String mediaType;
  final String status;
  int views;
  int likes;
  final int rating;
  final String? orderId;
  final DateTime? createdAt;

  Testimonial({
    required this.id,
    this.clientId,
    this.clientName,
    this.categoryId,
    this.categoryName,
    required this.content,
    required this.mediaUrl,
    required this.mediaType,
    required this.status,
    this.views = 0,
    this.likes = 0,
    required this.rating,
    this.orderId,
    this.createdAt,
  });

  factory Testimonial.fromJson(Map<String, dynamic> json) {
    return Testimonial(
      id: json['id']?.toString() ?? '',
      clientId: json['clientId']?.toString(),
      clientName: json['clientName']?.toString(),
      categoryId: json['categoryId']?.toString(),
      categoryName: json['categoryName']?.toString(),
      content: json['content'] ?? '',
      mediaUrl: json['mediaUrl'] ?? '',
      mediaType: json['mediaType'] ?? 'IMAGE',
      status: json['status'] ?? 'INACTIVE',
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      rating: json['rating'] ?? 0,
      orderId: json['orderId']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'clientName': clientName,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'content': content,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'status': status,
      'views': views,
      'likes': likes,
      'rating': rating,
      'orderId': orderId,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
