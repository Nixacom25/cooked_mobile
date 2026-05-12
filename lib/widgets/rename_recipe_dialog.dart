import 'package:flutter/material.dart';
import '../models/recipe.dart';
import 'red_button.dart';

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
          RedButton(
            label: 'Save',
            onTap: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                Navigator.pop(context);
                final updatedRecipe = recipe.copyWith(name: newName);
                onRetry(updatedRecipe);
              }
            },
            width: 100,
            height: 40,
            fontSize: 14,
          ),
        ],
      );
    },
  );
}
