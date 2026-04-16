class Creator {
  final String id;
  final String firstname;
  final String lastname;
  final String? photo;
  final int publicRecipeCount;
  final int totalUsageCount;

  Creator({
    required this.id,
    required this.firstname,
    required this.lastname,
    this.photo,
    required this.publicRecipeCount,
    required this.totalUsageCount,
  });

  factory Creator.fromJson(Map<String, dynamic> json) {
    return Creator(
      id: json['id'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      photo: json['photo'],
      publicRecipeCount: json['publicRecipeCount'] ?? 0,
      totalUsageCount: json['totalUsageCount'] ?? 0,
    );
  }

  String get displayName => '$firstname $lastname';
}
