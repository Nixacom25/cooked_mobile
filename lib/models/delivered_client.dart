
class DeliveredClient {
  final String id;
  final String title;
  final String videoUrl; // ⚠️ Video URL - will use GlobalVideoCache

  const DeliveredClient({
    required this.id,
    required this.title,
    required this.videoUrl,
  });
}
