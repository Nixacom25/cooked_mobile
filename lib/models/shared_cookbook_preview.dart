/// A cookbook someone shared with the user, before it is added to their
/// library (see CookbookService.getSharedPreview).
class SharedCookbookPreview {
  final String id;
  final String name;
  final String? ownerName;
  final int recipeCount;
  final List<String> coverImages;
  final bool isOwner;

  const SharedCookbookPreview({
    required this.id,
    required this.name,
    required this.recipeCount,
    this.ownerName,
    this.coverImages = const [],
    this.isOwner = false,
  });

  factory SharedCookbookPreview.fromJson(Map<String, dynamic> json) {
    return SharedCookbookPreview(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      ownerName: json['ownerName']?.toString(),
      recipeCount: (json['recipeCount'] as num?)?.toInt() ?? 0,
      coverImages: (json['coverImages'] as List? ?? []).whereType<String>().toList(),
      isOwner: json['isOwner'] == true,
    );
  }
}

/// The link points to a cookbook that was deleted or never shared.
class SharedCookbookNotFound implements Exception {
  const SharedCookbookNotFound();
}
