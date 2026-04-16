import 'package:flutter/material.dart';
import '../models/recipe.dart';

void showRenameRecipeDialog(
  BuildContext context,
  Recipe recipe,
  Future<void> Function(Recipe) onRetry,
) {
  final TextEditingController nameController = TextEditingController(
    text: recipe.name,
  );

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Recipe Name Exists',
          style: TextStyle(fontFamily: 'SF Pro', fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'The AI generated a name that you already use. Please modify it slightly to save:',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Recipe Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                Navigator.pop(context);
                final updatedRecipe = Recipe(
                  id: recipe.id,
                  name: newName,
                  image: recipe.image,
                  cookTime: recipe.cookTime,
                  kcal: recipe.kcal,
                  category: recipe.category,
                  isPublic: recipe.isPublic,
                  sourceUrl: recipe.sourceUrl,
                  steps: recipe.steps,
                  ingredients: recipe.ingredients,
                  isFavorite: recipe.isFavorite,
                  createdAt: recipe.createdAt,
                  updatedAt: recipe.updatedAt,
                  creator: recipe.creator,
                );
                onRetry(updatedRecipe);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCC3333),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}
