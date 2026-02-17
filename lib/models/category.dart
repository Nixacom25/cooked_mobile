class Category {
  final String id;
  final String name;
  final String imageUrl; // URL or asset path
  final String? description;
  final int productCount;

  const Category({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.description,
    this.productCount = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'],
      productCount: json['productCount'] ?? 0,
    );
  }
}
