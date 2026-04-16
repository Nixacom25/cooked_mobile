class DeviceSession {
  final String id;
  final String deviceName;
  final String location;
  final String ipAddress;
  final DateTime lastActive;
  final bool isCurrentSession;

  DeviceSession({
    required this.id,
    required this.deviceName,
    required this.location,
    required this.ipAddress,
    required this.lastActive,
    required this.isCurrentSession,
  });

  factory DeviceSession.fromJson(Map<String, dynamic> json) {
    return DeviceSession(
      id: json['id'] as String,
      deviceName: json['deviceName'] as String,
      location: json['location'] as String? ?? 'Unknown',
      ipAddress: json['ipAddress'] as String? ?? 'Unknown IP',
      lastActive: DateTime.parse(json['lastActive'] as String),
      isCurrentSession: json['isCurrentSession'] as bool? ?? false,
    );
  }
}
