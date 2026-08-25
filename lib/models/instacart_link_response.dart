class InstacartLinkResponse {
  final String url;
  final String? deepLinkUrl;
  final int itemCount;
  final int matchedCount;
  final String? message;

  InstacartLinkResponse({
    required this.url,
    this.deepLinkUrl,
    required this.itemCount,
    required this.matchedCount,
    this.message,
  });

  factory InstacartLinkResponse.fromJson(Map<String, dynamic> json) {
    return InstacartLinkResponse(
      url: json['url'] ?? '',
      deepLinkUrl: json['deepLinkUrl'],
      itemCount: json['itemCount'] ?? 0,
      matchedCount: json['matchedCount'] ?? 0,
      message: json['message'],
    );
  }
}
