class GroceryItem {
  final String id;
  final String? ingredientId;
  final String ingredientName;
  final String? ingredientIcon;
  final String? recipeId;
  final String? recipeName;
  final String? recipeImage;
  final String quantity;
  final bool isBought;
  final DateTime? plannedDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  GroceryItem({
    required this.id,
    this.ingredientId,
    required this.ingredientName,
    this.ingredientIcon,
    this.recipeId,
    this.recipeName,
    this.recipeImage,
    required this.quantity,
    required this.isBought,
    this.plannedDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    // Backend returns nested ingredient object
    final ingredient = json['ingredient'] ?? {};
    return GroceryItem(
      id: json['id'],
      ingredientId: ingredient['id'],
      ingredientName: ingredient['name'] ?? '',
      ingredientIcon: ingredient['icon'],
      recipeId: json['recipeId'],
      recipeName: json['recipeName'],
      recipeImage: json['recipeImage'],
      quantity: json['quantity'] ?? '',
      isBought: json['isBought'] ?? false,
      plannedDate: json['plannedDate'] != null
          ? DateTime.parse(json['plannedDate'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
