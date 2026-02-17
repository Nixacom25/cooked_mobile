class Advertisement {
  final int id;
  final String title;
  final String description;
  final String audioUrl;
  final String status;
  final String duration;
  final int listeners;

  Advertisement({
    required this.id,
    required this.title,
    required this.description,
    required this.audioUrl,
    required this.status,
    required this.duration,
    required this.listeners,
  });

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      audioUrl: json['audioUrl'] ?? '',
      status: json['status'] ?? 'INACTIVE',
      duration: json['duration'] ?? '0:00',
      listeners: json['listeners'] is int ? json['listeners'] : 0,
    );
  }
}
