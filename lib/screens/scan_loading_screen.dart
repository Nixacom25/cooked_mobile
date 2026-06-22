import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../widgets/scan_animation_overlay.dart';

class ScanLoadingScreen extends StatefulWidget {
  const ScanLoadingScreen({super.key});

  @override
  State<ScanLoadingScreen> createState() => _ScanLoadingScreenState();
}

class _ScanLoadingScreenState extends State<ScanLoadingScreen> {
  final List<RecipeIngredient> _mockIngredients = [
    RecipeIngredient(id: '1', name: 'Chicken breast', icon: '🍗', image: 'assets/images/ing1.png', amount: 1.0, unit: 'lb', quantity: '1 lb'),
    RecipeIngredient(id: '2', name: 'Cherry tomatoes', icon: '🍅', image: 'assets/images/ing2.png', amount: 2.0, unit: 'pcs', quantity: '2 pcs'),
    RecipeIngredient(id: '3', name: 'Garlic', icon: '🧄', image: 'assets/images/ing3.png', amount: 1.0, unit: 'pc', quantity: '1 pc'),
    RecipeIngredient(id: '4', name: 'Pasta', icon: '🍝', image: 'assets/images/ing4.png', amount: 1.0, unit: 'box', quantity: '1 box'),
    RecipeIngredient(id: '5', name: 'Parmesan cheese', icon: '🧀', image: 'assets/images/ing5.png', amount: 1.0, unit: 'cup', quantity: '1 cup'),
  ];

  final List<Recipe> _mockRecipes = [
    Recipe(
      id: '1',
      name: 'Chicken Tomato Stew',
      cookTime: 20,
      kcal: 400,
      image: '',
      isSuggested: true,
      isInCookbook: false,
      isPublic: false,
      isFavorite: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      steps: [],
      equipment: [],
      ingredients: [],
    ),
    Recipe(
      id: '2',
      name: 'Pasta Delight',
      cookTime: 15,
      kcal: 350,
      image: '',
      isSuggested: true,
      isInCookbook: false,
      isPublic: false,
      isFavorite: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      steps: [],
      equipment: [],
      ingredients: [],
    ),
    Recipe(
      id: '3',
      name: 'Garlic Chicken',
      cookTime: 25,
      kcal: 450,
      image: '',
      isSuggested: true,
      isInCookbook: false,
      isPublic: false,
      isFavorite: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      steps: [],
      equipment: [],
      ingredients: [],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          ScanAnimationOverlay(
            detectedIngredients: _mockIngredients,
            generatedRecipes: _mockRecipes,
            onAnimationComplete: () {
              Navigator.pop(context);
            },
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
