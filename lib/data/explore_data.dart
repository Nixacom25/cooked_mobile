import '../models/cookbook.dart';
import '../models/recipe.dart';

class ExploreData {
  static Recipe _createStaticRecipe(
    String idSuffix,
    String name,
    String image,
    int prepTime,
    int cookTime, {
    List<RecipeIngredient>? ingredients,
    List<String>? steps,
    List<String>? equipment,
    String? tips,
    int? kcal,
    int? servings,
    String? category,
  }) {
    return Recipe(
      id: 'static_recipe_$idSuffix',
      name: name,
      image: image,
      cookTime: cookTime,
      prepTime: prepTime,
      kcal: kcal ?? 400,
      servings: servings ?? 2,
      tips: tips ?? 'A delicious $name recipe.',
      ingredients: ingredients ??
          [
            RecipeIngredient(
                id: 'static_ing_$idSuffix',
                name: 'Main Ingredient',
                amount: 1.0,
                unit: 'portion',
                quantity: '1 portion',
                icon: '🍲')
          ],
      steps: steps ??
          [
            'Prepare the $name.',
            'Cook according to preference.',
            'Serve and enjoy!'
          ],
      equipment: equipment ?? ['Stove', 'Pan'],
      sourceUrl: '',
      origin: 'STATIC',
      isPublic: true,
      isFavorite: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      category: category,
    );
  }

  static final Map<String, RecipeIngredient> _ingredientsRepo = {
    'pizza_dough': _riRaw('Pizza Dough', '1 ball', '🍕'),
    'tomato_puree': _riRaw('Tomato Puree', '1/2 cup', '🥫'),
    'fresh_mozzarella': _riRaw('Fresh Mozzarella', '125g', '🧀'),
    'fresh_basil': _riRaw('Fresh Basil', 'handful', '🌿'),
    'olive_oil': _riRaw('Olive Oil', '1 tbsp', '🫒'),
    'garlic': _riRaw('Garlic', '2 cloves', '🧄'),
    'onion': _riRaw('Onion', '1 unit', '🧅'),
    'chicken_breast': _riRaw('Chicken Breast', '250g', '🍗'),
    'parmesan_cheese': _riRaw('Parmesan Cheese', '1/2 cup', '🧀'),
    'heavy_cream': _riRaw('Heavy Cream', '1/2 cup', '🥛'),
    'fettuccine_pasta': _riRaw('Fettuccine Pasta', '200g', '🍝'),
    'butter': _riRaw('Butter', '2 tbsp', '🧈'),
    'ground_beef': _riRaw('Ground Beef', '300g', '🥩'),
    'beef_steak': _riRaw('Beef Steak', '250g', '🥩'),
    'pork_belly': _riRaw('Pork Belly', '150g', '🥩'),
    'salmon_fillet': _riRaw('Salmon Fillet', '200g', '🐟'),
    'shrimp': _riRaw('Shrimp', '150g', '🦐'),
    'egg': _riRaw('Egg', '1 unit', '🥚'),
    'milk': _riRaw('Milk', '1 cup', '🥛'),
    'flour': _riRaw('Flour', '1 cup', '🌾'),
    'sugar': _riRaw('Sugar', '1 tbsp', '🍬'),
    'salt': _riRaw('Salt', 'pinch', '🧂'),
    'black_pepper': _riRaw('Black Pepper', 'pinch', '🌶️'),
    'lemon': _riRaw('Lemon', '1 unit', '🍋'),
    'lime': _riRaw('Lime', '1 unit', '🍋‍🟩'),
    'avocado': _riRaw('Avocado', '1 unit', '🥑'),
    'broccoli': _riRaw('Broccoli', '1 cup', '🥦'),
    'spinach': _riRaw('Spinach', '1 cup', '🥬'),
    'carrot': _riRaw('Carrot', '1 unit', '🥕'),
    'potato': _riRaw('Potato', '1 unit', '🥔'),
    'jasmine_rice': _riRaw('Jasmine Rice', '1 cup', '🍚'),
    'basmati_rice': _riRaw('Basmati Rice', '1 cup', '🍚'),
    'rice_noodles': _riRaw('Rice Noodles', '200g', '🍜'),
    'soy_sauce': _riRaw('Soy Sauce', '2 tbsp', '🧂'),
    'sesame_oil': _riRaw('Sesame Oil', '1 tbsp', '🫒'),
    'fish_sauce': _riRaw('Fish Sauce', '1 tbsp', '🧂'),
    'tamarind_paste': _riRaw('Tamarind Paste', '2 tbsp', '🫙'),
    'peanuts': _riRaw('Peanuts', 'handful', '🥜'),
    'coconut_milk': _riRaw('Coconut Milk', '1 can', '🥥'),
    'green_curry_paste': _riRaw('Green Curry Paste', '2 tbsp', '🍛'),
    'red_curry_paste': _riRaw('Red Curry Paste', '2 tbsp', '🍛'),
    'garam_masala': _riRaw('Garam Masala', '1 tsp', '🧂'),
    'gochujang': _riRaw('Gochujang', '1 tbsp', '🌶️'),
    'kimchi': _riRaw('Kimchi', '1/2 cup', '🥬'),
    'ginger': _riRaw('Ginger', '1 tsp', '🫚'),
    'parsley': _riRaw('Parsley', 'handful', '🌿'),
    'thyme': _riRaw('Thyme', '2 sprigs', '🌿'),
    'oregano': _riRaw('Oregano', '1 tsp', '🌿'),
    'saffron': _riRaw('Saffron', 'pinch', '🧶'),
    'cilantro': _riRaw('Cilantro', 'handful', '🌿'),
    'cumin': _riRaw('Cumin', '1 tsp', '🧂'),
    'paprika': _riRaw('Paprika', '1 tsp', '🌶️'),
    'chili_powder': _riRaw('Chili Powder', '1 tsp', '🌶️'),
    'tortillas': _riRaw('Tortillas', '6 units', '🫓'),
    'cheddar_cheese': _riRaw('Cheddar Cheese', '1 cup', '🧀'),
    'sour_cream': _riRaw('Sour Cream', '1/4 cup', '🥛'),
    'salsa': _riRaw('Salsa', '1/4 cup', '🥫'),
    'black_beans': _riRaw('Black Beans', '1 can', '🫘'),
    'corn': _riRaw('Corn', '1 cup', '🌽'),
    'bell_peppers': _riRaw('Bell Peppers', '1 unit', '🫑'),
    'zucchini': _riRaw('Zucchini', '1 unit', '🥒'),
    'cucumber': _riRaw('Cucumber', '1 unit', '🥒'),
    'mushrooms': _riRaw('Mushrooms', '1 cup', '🍄'),
    'tofu': _riRaw('Tofu', '200g', '🧊'),
    'honey': _riRaw('Honey', '1 tbsp', '🍯'),
    'maple_syrup': _riRaw('Maple Syrup', '1 tbsp', '🍁'),
    'cinnamon': _riRaw('Cinnamon', '1 tsp', '🧂'),
    'vanilla_extract': _riRaw('Vanilla Extract', '1 tsp', '🧴'),
    'baking_powder': _riRaw('Baking Powder', '1 tsp', '🧂'),
    'yeast': _riRaw('Yeast', '1 tsp', '🧂'),
    'walnuts': _riRaw('Walnuts', '1/4 cup', '🥜'),
    'almonds': _riRaw('Almonds', '1/4 cup', '🥜'),
    'chocolate_chips': _riRaw('Chocolate Chips', '1/2 cup', '🍫'),
    'cocoa_powder': _riRaw('Cocoa Powder', '1/2 cup', '🍫'),
    'spaghetti': _riRaw('Spaghetti', '200g', '🍝'),
    'tomato_sauce': _riRaw('Tomato Sauce', '400ml', '🥫'),
    'lettuce': _riRaw('Lettuce', '1 cup', '🥬'),
    'red_onion': _riRaw('Red Onion', '1/2 unit', '🧅'),
    'mayonnaise': _riRaw('Mayonnaise', '2 tbsp', '🧴'),
    'mustard': _riRaw('Mustard', '1 tbsp', '🧴'),
    'ketchup': _riRaw('Ketchup', '2 tbsp', '🥫'),
    'bacon': _riRaw('Bacon', '4 strips', '🥓'),
    'ham': _riRaw('Ham', '100g', '🍖'),
    'celery': _riRaw('Celery', '2 stalks', '🥬'),
    'peas': _riRaw('Peas', '1/2 cup', '🫛'),
    'green_beans': _riRaw('Green Beans', '1 cup', '🫛'),
    'cabbage': _riRaw('Cabbage', '1 cup', '🥬'),
    'scallions': _riRaw('Scallions', '2 units', '🥬'),
    'tuna': _riRaw('Tuna', '1 can', '🐟'),
    'turkey_breast': _riRaw('Turkey Breast', '200g', '🍗'),
    'lamb_chops': _riRaw('Lamb Chops', '250g', '🥩'),
    'couscous': _riRaw('Couscous', '1 cup', '🍚'),
    'quinoa': _riRaw('Quinoa', '1 cup', '🍚'),
    'lentils': _riRaw('Lentils', '1 cup', '🫘'),
    'chickpeas': _riRaw('Chickpeas', '1 can', '🫘'),
    'feta_cheese': _riRaw('Feta Cheese', '100g', '🧀'),
    'goat_cheese': _riRaw('Goat Cheese', '100g', '🧀'),
    'blue_cheese': _riRaw('Blue Cheese', '50g', '🧀'),
    'gochugaru': _riRaw('Gochugaru', '1 tbsp', '🌶️'),
    'miso_paste': _riRaw('Miso Paste', '1 tbsp', '🥣'),
    'mirin': _riRaw('Mirin', '1 tbsp', '🧴'),
    'sake': _riRaw('Sake', '1 tbsp', '🍶'),
    'dashi_powder': _riRaw('Dashi Powder', '1 tsp', '🧂'),
    'panko_breadcrumbs': _riRaw('Panko Breadcrumbs', '1 cup', '🌾'),
    'eggplant': _riRaw('Eggplant', '1 unit', '🍆'),
    'red_bell_pepper': _riRaw('Red Bell Pepper', '1 unit', '🫑'),
    'herbes_de_provence': _riRaw('Herbes de Provence', '1 tsp', '🌿'),
    'chicken_quarters': _riRaw('Chicken Quarters', '4 units', '🍗'),
    'red_wine': _riRaw('Red Wine', '2 cups', '🍷'),
    'bacon_lardons': _riRaw('Bacon Lardons', '100g', '🥓'),
    'pearl_onions': _riRaw('Pearl Onions', '1/2 cup', '🧅'),
    'rice_cakes': _riRaw('Rice Cakes', '200g', '🍡'),
    'fish_cakes': _riRaw('Fish Cakes', '100g', '🍥'),
    'green_onions': _riRaw('Green Onions', '2 units', '🥬'),
    'chicken_wings': _riRaw('Chicken Wings', '500g', '🍗'),
    'cornstarch': _riRaw('Cornstarch', '1/2 cup', '🌾'),
    'sweet_and_spicy_glaze': _riRaw('Sweet and Spicy Glaze', '1/2 cup', '🍯'),
  };

  static RecipeIngredient _riRaw(String name, String qty, String emoji) {
    return RecipeIngredient(
      id: 'ing_${name.toLowerCase().replaceAll(' ', '_')}',
      name: name,
      amount: 1,
      unit: '',
      quantity: qty,
      icon: emoji,
    );
  }

  static RecipeIngredient _gi(String id, [String? qty]) {
    final ing = _ingredientsRepo[id];
    if (ing == null) {
      return _riRaw(id.replaceAll('_', ' '), qty ?? '', '🍲');
    }
    if (qty != null) {
      return RecipeIngredient(
        id: ing.id,
        name: ing.name,
        amount: ing.amount,
        unit: ing.unit,
        quantity: qty,
        icon: ing.icon,
      );
    }
    return ing;
  }

  static RecipeIngredient _ri(String name, String qty) {
    return _gi(name.toLowerCase().replaceAll(' ', '_'), qty);
  }

  static ({Cookbook cookbook, String image}) _createStaticCookbook(
      String idSuffix, String name, String image, List<Recipe> recipes) {
    // Assign category to recipes in this cookbook if they don't have one
    final updatedRecipes = recipes.map((r) {
      if (r.category == null) {
        return r.copyWith(category: name);
      }
      return r;
    }).toList();

    return (
      cookbook: Cookbook(
        id: 'static_cb_$idSuffix',
        name: name,
        recipes: updatedRecipes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      image: image,
    );
  }

  static final List<({Cookbook cookbook, String image})> cuisines = [
    _createStaticCookbook('c_italian', 'Italian', 'assets/images/italian.png', [
      _createStaticRecipe(
        'it_1',
        'Spaghetti Bolognese',
        'assets/images/recipe_pasta.png',
        15,
        30,
        ingredients: [
          _ri('Spaghetti', '200g'),
          _ri('Ground Beef', '250g'),
          _ri('Tomato Sauce', '400ml'),
          _ri('Onion', '1 medium'),
          _ri('Garlic', '2 cloves'),
        ],
        steps: [
          'Boil spaghetti in salted water until al dente.',
          'Sauté chopped onion and garlic in a pan.',
          'Add ground beef and brown it thoroughly.',
          'Pour in tomato sauce and simmer for 15 minutes.',
          'Mix pasta with sauce and serve with parmesan.'
        ],
        equipment: ['Large Pot', 'Frying Pan', 'Colander'],
        kcal: 650,
      ),
      _createStaticRecipe(
        'it_2',
        'Chicken Alfredo',
        'assets/images/others.png',
        10,
        20,
        ingredients: [
          _ri('Fettuccine Pasta', '200g'),
          _ri('Chicken Breast', '2 units'),
          _ri('Heavy Cream', '200ml'),
          _ri('Parmesan Cheese', '50g'),
          _ri('Butter', '2 tbsp'),
        ],
        steps: [
          'Cook fettuccine according to package directions.',
          'Slice and cook chicken in butter until golden.',
          'Add cream and parmesan to the pan to create sauce.',
          'Toss pasta into the creamy chicken mixture.',
        ],
        equipment: ['Pot', 'Sauté Pan'],
        kcal: 750,
      ),
      _createStaticRecipe(
        'it_3',
        'Margherita Pizza',
        'assets/images/others.png',
        20,
        15,
        ingredients: [
          _ri('Pizza Dough', '1 ball'),
          _ri('Tomato Puree', '1/2 cup'),
          _ri('Fresh Mozzarella', '125g'),
          _ri('Fresh Basil', 'handful'),
          _ri('Olive Oil', '1 tbsp'),
        ],
        steps: [
          'Preheat oven to 220°C (430°F).',
          'Roll out pizza dough on a floured surface.',
          'Spread tomato puree and top with mozzarella.',
          'Bake for 12-15 minutes until crust is golden.',
          'Top with fresh basil and a drizzle of olive oil.'
        ],
        equipment: ['Oven', 'Baking Sheet', 'Rolling Pin'],
        kcal: 800,
      ),
      _createStaticRecipe(
        'it_4',
        'Lasagna',
        'assets/images/others.png',
        30,
        45,
        ingredients: [
          _ri('Lasagna Sheets', '12 units'),
          _ri('Ricotta Cheese', '2 cups'),
          _ri('Mozzarella', '2 cups shredded'),
          _ri('Meat Sauce', '3 cups'),
          _ri('Egg', '1 unit'),
        ],
        steps: [
          'Preheat oven to 190°C (375°F).',
          'Mix ricotta, egg, and half of the mozzarella.',
          'Layer meat sauce, lasagna sheets, and cheese mixture in a dish.',
          'Repeat layers until ingredients are used up.',
          'Bake for 45 minutes until bubbly and golden.'
        ],
        equipment: ['9x13 Baking Dish', 'Mixing Bowl'],
        kcal: 720,
      ),
      _createStaticRecipe(
        'it_5',
        'Penne Arrabbiata',
        'assets/images/others.png',
        10,
        20,
        ingredients: [
          _ri('Penne Pasta', '200g'),
          _ri('Tomato Puree', '400ml'),
          _ri('Dried Red Chili Flakes', '1 tsp'),
          _ri('Garlic', '3 cloves'),
          _ri('Olive Oil', '2 tbsp'),
        ],
        steps: [
          'Cook penne in boiling salted water.',
          'Sauté minced garlic and chili flakes in olive oil.',
          'Add tomato puree and simmer for 10 minutes.',
          'Toss pasta into the spicy sauce.',
          'Garnish with fresh parsley.'
        ],
        equipment: ['Large Pot', 'Skillet'],
        kcal: 480,
      ),
      _createStaticRecipe(
        'it_6',
        'Carbonara',
        'assets/images/others.png',
        15,
        15,
        ingredients: [
          _ri('Spaghetti', '200g'),
          _ri('Pancetta or Guanciale', '100g'),
          _ri('Large Eggs', '2 units'),
          _ri('Pecorino Romano', '50g'),
          _ri('Black Pepper', 'lots of it'),
        ],
        steps: [
          'Boil spaghetti until al dente.',
          'Fry pancetta until crispy in a large pan.',
          'Whisk eggs and cheese together in a bowl.',
          'Combine hot pasta with pancetta, then remove from heat.',
          'Quickly toss egg mixture with pasta (heat from pasta cooks the egg).'
        ],
        equipment: ['Large Pot', 'Skillet', 'Whisking Bowl'],
        kcal: 600,
      ),
      _createStaticRecipe(
        'it_7',
        'Caprese Salad',
        'assets/images/others.png',
        10,
        0,
        ingredients: [
          _ri('Fresh Tomatoes', '2 large'),
          _ri('Fresh Mozzarella', '200g'),
          _ri('Fresh Basil Leaves', 'handful'),
          _ri('Balsamic Glaze', '2 tbsp'),
          _ri('Extra Virgin Olive Oil', '1 tbsp'),
        ],
        steps: [
          'Slice tomatoes and mozzarella into 1cm thick rounds.',
          'Alternate tomato and mozzarella slices on a plate.',
          'Tuck basil leaves between the slices.',
          'Drizzle with olive oil and balsamic glaze.',
          'Season with salt and pepper.'
        ],
        equipment: ['Sharp Knife', 'Serving Platter'],
        kcal: 250,
      ),
      _createStaticRecipe(
        'it_8',
        'Risotto',
        'assets/images/others.png',
        10,
        35,
        ingredients: [
          _ri('Arborio Rice', '1 cup'),
          _ri('Chicken or Veg Broth', '3 cups'),
          _ri('White Wine', '1/2 cup'),
          _ri('Shallot', '1 unit minced'),
          _ri('Parmesan Cheese', '1/2 cup'),
        ],
        steps: [
          'Heat broth in a separate pot to a simmer.',
          'Sauté shallots in butter until translucent.',
          'Add rice and toast for 2 minutes.',
          'Deglaze with wine and stir until absorbed.',
          'Add broth 1 ladle at a time, stirring constantly until absorbed.'
        ],
        equipment: ['Large Saucepan', 'Broth Pot', 'Wooden Spoon'],
        kcal: 550,
      ),
      _createStaticRecipe(
        'it_9',
        'Bruschetta',
        'assets/images/others.png',
        10,
        10,
        ingredients: [
          _ri('Baguette', '1 unit'),
          _ri('Roma Tomatoes', '3 units diced'),
          _ri('Garlic', '2 cloves'),
          _ri('Fresh Basil', 'handful chopped'),
          _ri('Olive Oil', '2 tbsp'),
        ],
        steps: [
          'Slice baguette and toast until golden.',
          'Rub each toast slice with a raw garlic clove.',
          'Mix diced tomatoes, basil, and olive oil in a bowl.',
          'Spoon tomato mixture onto the toasted bread.',
        ],
        equipment: ['Knife', 'Toaster or Oven'],
        kcal: 220,
      ),
    ]),
    _createStaticCookbook('c_mexican', 'Mexican', 'assets/images/mexican.png', [
      _createStaticRecipe(
        'mx_1',
        'Chicken Tacos',
        'assets/images/others.png',
        15,
        15,
        ingredients: [
          _ri('Corn Tortillas', '6 units'),
          _ri('Chicken Thighs', '300g'),
          _ri('Onion', '1 small'),
          _ri('Cilantro', 'handful'),
          _ri('Lime', '1 unit'),
        ],
        steps: [
          'Season and grill chicken until cooked through.',
          'Chop chicken into small bite-sized pieces.',
          'Warm tortillas on a hot skillet.',
          'Assemble tacos with chicken, onions, and cilantro.',
          'Serve with a squeeze of lime juice.'
        ],
        equipment: ['Skillet', 'Chef Knife', 'Cutting Board'],
        kcal: 450,
      ),
      _createStaticRecipe(
        'mx_2',
        'Beef Burrito',
        'assets/images/others.png',
        15,
        20,
        ingredients: [
          _ri('Large Flour Tortilla', '2 units'),
          _ri('Ground Beef', '200g'),
          _ri('Rice', '1 cup cooked'),
          _ri('Black Beans', '1/2 cup'),
          _ri('Shredded Cheese', '1/2 cup'),
        ],
        steps: [
          'Cook ground beef with taco seasoning.',
          'Layer rice, beans, beef, and cheese on the tortilla.',
          'Fold the sides and roll tightly into a burrito.',
          'Optional: Toast the burrito on a pan for extra crunch.'
        ],
        equipment: ['Pan', 'Spatula'],
        kcal: 600,
      ),
      _createStaticRecipe(
        'mx_3',
        'Quesadilla',
        'assets/images/others.png',
        10,
        10,
        ingredients: [
          _ri('Flour Tortillas', '2 units'),
          _ri('Monterey Jack Cheese', '1 cup shredded'),
          _ri('Jalapeños', 'optional'),
          _ri('Sour Cream', 'for dipping'),
        ],
        steps: [
          'Place one tortilla in a dry skillet over medium heat.',
          'Sprinkle cheese and optional jalapeños evenly.',
          'Top with the second tortilla.',
          'Cook for 3 minutes per side until cheese melts.',
          'Slice into wedges and serve with sour cream.'
        ],
        equipment: ['Large Skillet', 'Pizza Cutter'],
        kcal: 400,
      ),
      _createStaticRecipe(
        'mx_4',
        'Guacamole',
        'assets/images/others.png',
        10,
        0,
        ingredients: [
          _ri('Ripe Avocados', '3 units'),
          _ri('Lime Juice', '1 tbsp'),
          _ri('Red Onion', '1/4 cup minced'),
          _ri('Cilantro', '2 tbsp chopped'),
          _ri('Salt', '1/2 tsp'),
        ],
        steps: [
          'Mash avocado flesh in a bowl with a fork.',
          'Stir in lime juice, salt, onion, and cilantro.',
          'Adjust seasoning to taste.',
          'Serve immediately with chips.'
        ],
        equipment: ['Medium Bowl', 'Fork'],
        kcal: 280,
      ),
      _createStaticRecipe(
        'mx_5',
        'Enchiladas',
        'assets/images/others.png',
        20,
        25,
        ingredients: [
          _ri('Corn Tortillas', '8 units'),
          _ri('Shredded Chicken', '2 cups'),
          _ri('Enchilada Sauce', '2 cups'),
          _ri('Cheese', '1 cup'),
        ],
        steps: [
          'Preheat oven to 180°C (350°F).',
          'Dip tortillas in sauce to soften.',
          'Fill with chicken and roll up.',
          'Place rolls in a baking dish, cover with extra sauce and cheese.',
          'Bake for 20 minutes until bubbling.'
        ],
        equipment: ['Baking Dish', 'Small Pan'],
        kcal: 580,
      ),
      _createStaticRecipe(
        'mx_6',
        'Nachos',
        'assets/images/others.png',
        10,
        15,
        ingredients: [
          _ri('Tortilla Chips', '1 large bag'),
          _ri('Nacho Cheese Sauce', '1 cup'),
          _ri('Black Beans', '1/2 cup'),
          _ri('Pickled Jalapeños', 'handful'),
          _ri('Guacamole', '1/2 cup'),
        ],
        steps: [
          'Spread chips on a large baking sheet.',
          'Drizzle cheese sauce and beans over the chips.',
          'Bake at 200°C for 5-8 minutes.',
          'Top with jalapeños and guacamole before serving.'
        ],
        equipment: ['Baking Sheet', 'Oven'],
        kcal: 900,
      ),
      _createStaticRecipe(
        'mx_7',
        'Street Corn (Elote)',
        'assets/images/others.png',
        10,
        15,
        ingredients: [
          _ri('Corn on the Cob', '4 units'),
          _ri('Mayonnaise', '1/4 cup'),
          _ri('Cotija Cheese', '1/2 cup crumbled'),
          _ri('Chili Powder', '1 tsp'),
          _ri('Lime', '1 unit'),
        ],
        steps: [
          'Grill corn until slightly charred all over.',
          'Brush mayonnaise onto the hot corn.',
          'Roll corn in crumbled Cotija cheese.',
          'Dust with chili powder and serve with lime wedges.'
        ],
        equipment: ['Grill', 'Silicone Brush'],
        kcal: 320,
      ),
      _createStaticRecipe(
        'mx_8',
        'Rice and Beans',
        'assets/images/others.png',
        5,
        20,
        ingredients: [
          _ri('White Rice', '1 cup'),
          _ri('Black Beans', '1 can rinsed'),
          _ri('Cumin', '1 tsp'),
          _ri('Garlic Powder', '1 tsp'),
          _ri('Vegetable Broth', '2 cups'),
        ],
        steps: [
          'Cook rice in broth with cumin and garlic powder.',
          'Once rice is cooked, fold in the black beans.',
          'Simmer for 5 more minutes to heat through.',
          'Fluff with a fork and serve.'
        ],
        equipment: ['Medium Saucepan', 'Fork'],
        kcal: 350,
      ),
    ]),
    _createStaticCookbook('c_chinese', 'Chinese', 'assets/images/chinese.png', [
      _createStaticRecipe(
        'cn_1',
        'Chicken Fried Rice',
        'assets/images/others.png',
        10,
        15,
        ingredients: [
          _ri('Cooked Rice', '2 cups'),
          _ri('Chicken Breast', '150g diced'),
          _ri('Peas and Carrots', '1/2 cup'),
          _ri('Soy Sauce', '2 tbsp'),
          _ri('Eggs', '2 units'),
        ],
        steps: [
          'Scramble eggs in a wok and set aside.',
          'Stir-fry chicken until cooked through.',
          'Add vegetables and rice to the wok.',
          'Mix in soy sauce and scrambled eggs.',
          'Toss everything over high heat for 3 minutes.'
        ],
        equipment: ['Wok', 'Spatula'],
        kcal: 500,
      ),
      _createStaticRecipe(
        'cn_2',
        'Beef and Broccoli',
        'assets/images/others.png',
        15,
        15,
        ingredients: [
          _ri('Flank Steak', '300g sliced'),
          _ri('Broccoli Florets', '2 cups'),
          _ri('Oyster Sauce', '3 tbsp'),
          _ri('Ginger', '1 tsp minced'),
          _ri('Cornstarch', '1 tsp'),
        ],
        steps: [
          'Marinate beef in a little soy sauce and cornstarch.',
          'Steam broccoli until bright green.',
          'Sear beef in a hot wok in batches.',
          'Add broccoli and oyster sauce back to the pan.',
          'Stir until the sauce thickens and coats everything.'
        ],
        equipment: ['Wok', 'Steamer Basket'],
        kcal: 420,
      ),
      _createStaticRecipe(
        'cn_3',
        'Sweet and Sour Chicken',
        'assets/images/others.png',
        20,
        20,
        ingredients: [
          _ri('Chicken Breast', '300g cubed'),
          _ri('Pineapple Chunks', '1 cup'),
          _ri('Bell Peppers', '2 units'),
          _ri('Sweet and Sour Sauce', '1/2 cup'),
          _ri('Flour', 'for coating'),
        ],
        steps: [
          'Dredge chicken in flour and fry until crispy.',
          'Sauté peppers and pineapple in a separate pan.',
          'Add sweet and sour sauce and bring to a simmer.',
          'Toss in the crispy chicken and serve immediately.'
        ],
        equipment: ['Deep Fryer or Large Pot', 'Skillet'],
        kcal: 600,
      ),
      _createStaticRecipe(
        'cn_4',
        'Lo Mein',
        'assets/images/others.png',
        15,
        15,
        ingredients: [
          _ri('Egg Noodles', '200g'),
          _ri('Cabbage', '1 cup shredded'),
          _ri('Carrots', '1/2 cup julienned'),
          _ri('Soy Sauce', '2 tbsp'),
          _ri('Sesame Oil', '1 tsp'),
        ],
        steps: [
          'Cook noodles and drain.',
          'Stir-fry vegetables until tender.',
          'Add noodles and sauces to the wok.',
          'Toss over high heat until well combined.'
        ],
        equipment: ['Wok', 'Tongs'],
        kcal: 450,
      ),
      _createStaticRecipe(
        'cn_5',
        'Dumplings',
        'assets/images/others.png',
        30,
        15,
        ingredients: [
          _ri('Dumpling Wrappers', '20 units'),
          _ri('Ground Pork', '200g'),
          _ri('Napa Cabbage', '1 cup finely chopped'),
          _ri('Green Onions', '2 units'),
          _ri('Soy Sauce', '1 tbsp'),
        ],
        steps: [
          'Mix pork, cabbage, and seasonings in a bowl.',
          'Place a spoonful of filling on each wrapper.',
          'Pleat the edges to seal the dumplings.',
          'Pan-fry until the bottom is crispy, then steam with a splash of water.'
        ],
        equipment: ['Mixing Bowl', 'Skillet with Lid'],
        kcal: 350,
      ),
      _createStaticRecipe(
        'cn_6',
        'Kung Pao Chicken',
        'assets/images/others.png',
        15,
        15,
        ingredients: [
          _ri('Chicken Breast', '300g cubed'),
          _ri('Peanuts', '1/4 cup roasted'),
          _ri('Dried Red Chilies', '5 units'),
          _ri('Hoisin Sauce', '2 tbsp'),
          _ri('Zucchini', '1 unit diced'),
        ],
        steps: [
          'Sauté chilies and garlic in oil until fragrant.',
          'Add chicken and cook until browned.',
          'Stir in zucchini and hoisin sauce.',
          'Fold in peanuts right before serving for crunch.'
        ],
        equipment: ['Wok'],
        kcal: 480,
      ),
      _createStaticRecipe(
        'cn_7',
        'Egg Rolls',
        'assets/images/others.png',
        20,
        15,
        ingredients: [
          _ri('Egg Roll Wrappers', '10 units'),
          _ri('Shredded Cabbage', '2 cups'),
          _ri('Carrots', '1/2 cup julienned'),
          _ri('Ground Pork', '150g'),
          _ri('Ginger', '1/2 tsp'),
        ],
        steps: [
          'Sauté pork and vegetables until tender.',
          'Place filling in wrappers and roll tightly.',
          'Seal edges with a bit of egg wash.',
          'Deep fry until golden and crispy.',
          'Serve with sweet chili sauce.'
        ],
        equipment: ['Wok', 'Deep Fryer'],
        kcal: 380,
      ),
      _createStaticRecipe(
        'cn_8',
        'Hot and Sour Soup',
        'assets/images/others.png',
        10,
        20,
        ingredients: [
          _ri('Chicken Broth', '4 cups'),
          _ri('Tofu', '200g cubed'),
          _ri('Bamboo Shoots', '1/2 cup'),
          _ri('Rice Vinegar', '3 tbsp'),
          _ri('White Pepper', '1 tsp'),
        ],
        steps: [
          'Bring broth to a boil with vegetables and tofu.',
          'Add vinegar, soy sauce, and white pepper.',
          'Stir in a cornstarch slurry to thicken.',
          'Slowly drizzle in a beaten egg while stirring.',
        ],
        equipment: ['Large Pot'],
        kcal: 220,
      ),
    ]),
    _createStaticCookbook('c_japanese', 'Japanese', 'assets/images/japanese.png', [
      _createStaticRecipe(
        'jp_1',
        'Sushi Rolls',
        'assets/images/others.png',
        40,
        0,
        ingredients: [
          _ri('Sushi Rice', '2 cups cooked'),
          _ri('Nori Sheets', '4 units'),
          _ri('Fresh Salmon or Tuna', '150g'),
          _ri('Cucumber', '1 unit julienned'),
          _ri('Rice Vinegar', '2 tbsp'),
        ],
        steps: [
          'Season rice with rice vinegar while warm.',
          'Place nori sheet on a bamboo mat.',
          'Spread rice evenly over the nori, leaving a small gap at the top.',
          'Place fish and cucumber in the center.',
          'Roll tightly and slice into 8 pieces.'
        ],
        equipment: ['Bamboo Sushi Mat', 'Sharp Knife', 'Rice Cooker'],
        kcal: 300,
      ),
      _createStaticRecipe(
        'jp_2',
        'Chicken Teriyaki',
        'assets/images/others.png',
        15,
        15,
        ingredients: [
          _ri('Chicken Thighs', '2 units'),
          _ri('Teriyaki Sauce', '1/2 cup'),
          _ri('Sesame Seeds', '1 tsp'),
          _ri('Broccoli', '1 cup steamed'),
        ],
        steps: [
          'Pan-sear chicken thighs until skin is crispy.',
          'Pour teriyaki sauce over the chicken and simmer.',
          'Glaze the chicken until the sauce is thick.',
          'Slice chicken and serve over rice with sesame seeds.'
        ],
        equipment: ['Skillet', 'Chef Knife'],
        kcal: 450,
      ),
      _createStaticRecipe(
        'jp_3',
        'Ramen',
        'assets/images/others.png',
        20,
        20,
        ingredients: [
          _ri('Ramen Noodles', '1 pack'),
          _ri('Pork Belly or Chicken', '2 slices'),
          _ri('Soft-boiled Egg', '1 unit'),
          _ri('Miso Paste', '1 tbsp'),
          _ri('Dashi Stock', '2 cups'),
        ],
        steps: [
          'Cook noodles in boiling water and drain.',
          'Combine dashi stock and miso paste in a pot.',
          'Add cooked meat and noodles to a bowl.',
          'Pour hot broth over and top with the egg.'
        ],
        equipment: ['Large Stock Pot', 'Soup Bowl'],
        kcal: 520,
      ),
      _createStaticRecipe(
        'jp_4',
        'Tempura',
        'assets/images/others.png',
        20,
        15,
        ingredients: [
          _ri('Shrimp', '4 units'),
          _ri('Sweet Potato', '4 slices'),
          _ri('Tempura Batter', '1 cup'),
          _ri('Ice Water', '1 cup'),
        ],
        steps: [
          'Mix cold water and flour to make a light batter.',
          'Dip shrimp and vegetables into batter.',
          'Fry in hot oil until light golden and crispy.',
          'Serve with tentsuyu dipping sauce.'
        ],
        equipment: ['Deep Skillet or Wok'],
        kcal: 450,
      ),
      _createStaticRecipe(
        'jp_5',
        'Miso Soup',
        'assets/images/others.png',
        5,
        10,
        ingredients: [
          _ri('Dashi Stock', '2 cups'),
          _ri('Miso Paste', '2 tbsp'),
          _ri('Tofu', '100g cubed'),
          _ri('Seaweed (Wakame)', '1 tsp'),
        ],
        steps: [
          'Bring dashi stock to a boil.',
          'Add seaweed and tofu.',
          'Whisk in miso paste through a strainer.',
          'Serve hot immediately (do not boil after adding miso).'
        ],
        equipment: ['Small Pot'],
        kcal: 80,
      ),
      _createStaticRecipe(
        'jp_6',
        'Yakisoba',
        'assets/images/others.png',
        15,
        15,
        ingredients: [
          _ri('Yakisoba Noodles', '200g'),
          _ri('Pork Belly', '100g'),
          _ri('Cabbage', '1 cup'),
          _ri('Yakisoba Sauce', '3 tbsp'),
        ],
        steps: [
          'Fry pork and cabbage in a pan.',
          'Add noodles and a splash of water.',
          'Pour in sauce and stir-fry until combined.',
          'Garnish with pickled ginger and seaweed powder.'
        ],
        equipment: ['Large Skillet or Griddle'],
        kcal: 520,
      ),
      _createStaticRecipe(
        'jp_7',
        'Katsu Chicken',
        'assets/images/others.png',
        15,
        20,
        ingredients: [
          _ri('Chicken Breast', '2 units'),
          _ri('Panko Breadcrumbs', '1 cup'),
          _ri('Flour', '1/2 cup'),
          _ri('Egg', '1 unit'),
        ],
        steps: [
          'Flatten chicken and season.',
          'Coat in flour, then egg, then panko.',
          'Fry until golden and crispy.',
          'Serve sliced with tonkatsu sauce and shredded cabbage.'
        ],
        equipment: ['Frying Pan'],
        kcal: 580,
      ),
    ]),
    _createStaticCookbook('c_thai', 'Thai', 'assets/images/thai.png', [
      _createStaticRecipe(
        'th_1',
        'Pad Thai',
        'assets/images/others.png',
        15,
        15,
        ingredients: [
          _ri('Rice Noodles', '200g'),
          _ri('Shrimp or Tofu', '150g'),
          _ri('Tamarind Paste', '2 tbsp'),
          _ri('Fish Sauce', '1 tbsp'),
          _ri('Peanuts', 'crushed for garnish'),
        ],
        steps: [
          'Soak noodles in warm water until soft.',
          'Stir-fry shrimp or tofu in a wok.',
          'Add noodles and tamarind sauce mixture.',
          'Toss with bean sprouts and scrambled eggs.',
          'Serve with lime and crushed peanuts.'
        ],
        equipment: ['Wok', 'Spatula'],
        kcal: 480,
      ),
      _createStaticRecipe(
        'th_2',
        'Green Curry',
        'assets/images/others.png',
        15,
        20,
        ingredients: [
          _ri('Green Curry Paste', '2 tbsp'),
          _ri('Coconut Milk', '1 can'),
          _ri('Chicken Breast', '250g'),
          _ri('Bamboo Shoots', '1/2 cup'),
          _ri('Thai Basil', 'handful'),
        ],
        steps: [
          'Sauté curry paste in coconut milk fat until fragrant.',
          'Add chicken and cook until opaque.',
          'Pour in remaining coconut milk and bamboo shoots.',
          'Simmer for 10 minutes.',
          'Finish with Thai basil and fish sauce to taste.'
        ],
        equipment: ['Pot'],
        kcal: 550,
      ),
      _createStaticRecipe(
        'th_3',
        'Red Curry',
        'assets/images/others.png',
        15,
        20,
        ingredients: [
          _ri('Red Curry Paste', '2 tbsp'),
          _ri('Coconut Milk', '1 can'),
          _ri('Beef or Duck', '250g'),
          _ri('Eggplant', '1/2 cup'),
          _ri('Thai Basil', 'handful'),
        ],
        steps: [
          'Sauté red curry paste in coconut milk fat.',
          'Add meat and cook until tender.',
          'Pour in remaining coconut milk and vegetables.',
          'Simmer for 15 minutes.',
          'Garnish with basil and serve with jasmine rice.'
        ],
        equipment: ['Pot'],
        kcal: 580,
      ),
      _createStaticRecipe(
        'th_4',
        'Thai Basil Chicken',
        'assets/images/others.png',
        10,
        10,
        ingredients: [
          _ri('Ground Chicken', '300g'),
          _ri('Thai Basil Leaves', '2 cups'),
          _ri('Birdseye Chilies', '3 units'),
          _ri('Garlic', '4 cloves'),
          _ri('Oyster Sauce', '1 tbsp'),
        ],
        steps: [
          'Pound chilies and garlic into a paste.',
          'Stir-fry the paste until fragrant.',
          'Add chicken and cook until browned.',
          'Stir in sauces and a lot of basil leaves.',
          'Serve with a fried egg on top of rice.'
        ],
        equipment: ['Wok', 'Mortar and Pestle'],
        kcal: 420,
      ),
      _createStaticRecipe(
        'th_5',
        'Mango Sticky Rice',
        'assets/images/others.png',
        15,
        30,
        ingredients: [
          _ri('Sticky Rice', '1 cup'),
          _ri('Ripe Mango', '2 units'),
          _ri('Coconut Cream', '1/2 cup'),
          _ri('Sugar', '3 tbsp'),
          _ri('Salt', 'pinch'),
        ],
        steps: [
          'Steam sticky rice until tender.',
          'Mix warm rice with sweetened coconut cream.',
          'Let it sit for 20 minutes to absorb.',
          'Serve with sliced fresh mango on the side.'
        ],
        equipment: ['Steamer', 'Bowl'],
        kcal: 350,
      ),
      _createStaticRecipe(
        'th_6',
        'Tom Yum Soup',
        'assets/images/others.png',
        15,
        20,
        ingredients: [
          _ri('Shrimp', '200g'),
          _ri('Lemongrass', '2 stalks'),
          _ri('Galangal', '3 slices'),
          _ri('Kaffir Lime Leaves', '4 units'),
          _ri('Mushrooms', '1 cup'),
        ],
        steps: [
          'Boil water with lemongrass, galangal, and lime leaves.',
          'Add mushrooms and shrimp.',
          'Season with fish sauce, lime juice, and chili paste.',
          'Simmer until shrimp is cooked.',
          'Garnish with cilantro.'
        ],
        equipment: ['Pot'],
        kcal: 250,
      ),
    ]),
    _createStaticCookbook('c_indian', 'Indian', 'assets/images/others.png', [
      _createStaticRecipe(
        'in_1',
        'Butter Chicken',
        'assets/images/others.png',
        20,
        30,
        ingredients: [
          _ri('Chicken Thighs', '400g'),
          _ri('Tomato Puree', '1 cup'),
          _ri('Heavy Cream', '1/2 cup'),
          _ri('Garam Masala', '1 tsp'),
          _ri('Butter', '3 tbsp'),
        ],
        steps: [
          'Marinate chicken in yogurt and spices.',
          'Grill or pan-fry chicken until charred.',
          'Simmer tomato puree, butter, and spices in a pot.',
          'Add cream and chicken to the sauce.',
          'Simmer until thickened and serve with naan.'
        ],
        equipment: ['Large Pot', 'Skillet'],
        kcal: 680,
      ),
      _createStaticRecipe(
        'in_2',
        'Chicken Tikka Masala',
        'assets/images/others.png',
        20,
        30,
        ingredients: [
          _ri('Chicken Breast', '400g'),
          _ri('Yogurt', '1/2 cup'),
          _ri('Turmeric', '1 tsp'),
          _ri('Cumin', '1 tsp'),
          _ri('Heavy Cream', '1/2 cup'),
        ],
        steps: [
          'Marinate chicken in yogurt and spices for 2 hours.',
          'Roast chicken until cooked through.',
          'Prepare a spiced tomato cream sauce.',
          'Combine chicken and sauce and simmer.'
        ],
        equipment: ['Oven or Tandoor', 'Saucepan'],
        kcal: 650,
      ),
      _createStaticRecipe(
        'in_3',
        'Biryani',
        'assets/images/others.png',
        30,
        40,
        ingredients: [
          _ri('Basmati Rice', '2 cups'),
          _ri('Lamb or Chicken', '400g'),
          _ri('Biryani Spices', '2 tbsp'),
          _ri('Onions', '2 large fried'),
          _ri('Saffron Milk', '2 tbsp'),
        ],
        steps: [
          'Parboil rice with whole spices.',
          'Cook meat with biryani spices and yogurt.',
          'Layer meat and rice in a heavy pot.',
          'Top with fried onions and saffron milk.',
          'Seal and cook on low heat (Dum) for 20 minutes.'
        ],
        equipment: ['Heavy Bottom Pot', 'Lid'],
        kcal: 750,
      ),
      _createStaticRecipe(
        'in_4',
        'Naan',
        'assets/images/others.png',
        20,
        10,
        ingredients: [
          _ri('All-purpose Flour', '2 cups'),
          _ri('Yogurt', '1/4 cup'),
          _ri('Yeast', '1 tsp'),
          _ri('Garlic Butter', '2 tbsp'),
        ],
        steps: [
          'Knead flour, yogurt, and yeast into a soft dough.',
          'Let it rise for 2 hours.',
          'Roll into flat circles.',
          'Cook in a very hot oven or on a skillet until bubbly.',
          'Brush with garlic butter.'
        ],
        equipment: ['Skillet or Pizza Stone', 'Rolling Pin'],
        kcal: 280,
      ),
      _createStaticRecipe(
        'in_5',
        'Chana Masala',
        'assets/images/others.png',
        15,
        25,
        ingredients: [
          _ri('Chickpeas', '2 cans'),
          _ri('Onion', '1 unit'),
          _ri('Tomato Puree', '1 cup'),
          _ri('Ginger-Garlic Paste', '1 tbsp'),
          _ri('Chana Masala Spice', '2 tbsp'),
        ],
        steps: [
          'Sauté onions and ginger-garlic paste.',
          'Add tomato puree and spices.',
          'Stir in chickpeas and a bit of water.',
          'Simmer for 15 minutes.',
          'Garnish with fresh coriander.'
        ],
        equipment: ['Pot'],
        kcal: 380,
      ),
      _createStaticRecipe(
        'in_6',
        'Dal',
        'assets/images/others.png',
        10,
        30,
        ingredients: [
          _ri('Red Lentils', '1 cup'),
          _ri('Turmeric', '1/2 tsp'),
          _ri('Cumin Seeds', '1 tsp'),
          _ri('Garlic', '3 cloves'),
          _ri('Ghee', '1 tbsp'),
        ],
        steps: [
          'Boil lentils with turmeric until soft.',
          'In a small pan, heat ghee and sizzle cumin and garlic.',
          'Pour the spiced ghee over the lentils (Tadka).',
          'Season with salt and serve.'
        ],
        equipment: ['Pot', 'Small Tempering Pan'],
        kcal: 320,
      ),
      _createStaticRecipe(
        'in_7',
        'Samosas',
        'assets/images/others.png',
        30,
        20,
        ingredients: [
          _ri('Potatoes', '2 units boiled'),
          _ri('Peas', '1/4 cup'),
          _ri('Samosa Pastry', '10 units'),
          _ri('Cumin', '1 tsp'),
          _ri('Oil', 'for frying'),
        ],
        steps: [
          'Mash potatoes and mix with peas and spices.',
          'Fold pastry into triangles around the filling.',
          'Seal edges with a bit of water.',
          'Deep fry until golden brown and crispy.'
        ],
        equipment: ['Deep Fryer or Wok'],
        kcal: 450,
      ),
    ]),
    _createStaticCookbook('c_korean', 'Korean', 'assets/images/others.png', [
      _createStaticRecipe(
        'kr_1',
        'Bibimbap',
        'assets/images/others.png',
        20,
        20,
        ingredients: [
          _ri('Rice', '1 cup'),
          _ri('Spinach', '1 bunch'),
          _ri('Bean Sprouts', '1 cup'),
          _ri('Carrot', '1 unit'),
          _ri('Fried Egg', '1 unit'),
          _ri('Gochujang', '1 tbsp'),
        ],
        steps: [
          'Sauté each vegetable separately with a bit of sesame oil.',
          'Place rice in a bowl and arrange vegetables on top.',
          'Add a fried egg in the center.',
          'Serve with gochujang sauce and mix before eating.'
        ],
        equipment: ['Small Frying Pan', 'Mixing Bowl'],
        kcal: 450,
      ),
      _createStaticRecipe(
        'kr_2',
        'Korean BBQ Beef (Bulgogi)',
        'assets/images/others.png',
        15,
        15,
        ingredients: [
          _ri('Thinly Sliced Beef', '300g'),
          _ri('Soy Sauce', '3 tbsp'),
          _ri('Sugar', '1 tbsp'),
          _ri('Sesame Oil', '1 tbsp'),
          _ri('Garlic', '2 cloves minced'),
        ],
        steps: [
          'Marinate beef in soy sauce, sugar, and garlic for 30 minutes.',
          'Stir-fry beef over high heat until caramelized.',
          'Garnish with green onions and sesame seeds.'
        ],
        equipment: ['Skillet or Grill'],
        kcal: 500,
      ),
      _createStaticRecipe(
        'kr_3',
        'Kimchi Fried Rice',
        'assets/images/others.png',
        10,
        10,
        ingredients: [
          _ri('Cooked Rice', '2 cups'),
          _ri('Kimchi', '1 cup chopped'),
          _ri('Kimchi Juice', '2 tbsp'),
          _ri('Gochujang', '1 tbsp'),
          _ri('Fried Egg', '1 unit'),
        ],
        steps: [
          'Stir-fry kimchi in a pan with a bit of oil.',
          'Add rice and break up any clumps.',
          'Mix in gochujang and kimchi juice.',
          'Stir-fry for 5 minutes until well combined.',
          'Serve with a fried egg on top.'
        ],
        equipment: ['Skillet'],
        kcal: 420,
      ),
      _createStaticRecipe(
        'kr_4',
        'Tteokbokki',
        'assets/images/others.png',
        10,
        20,
        ingredients: [
          _ri('Rice Cakes', '200g'),
          _ri('Gochujang', '2 tbsp'),
          _ri('Fish Cakes', '100g'),
          _ri('Sugar', '1 tbsp'),
          _ri('Green Onions', '2 units'),
        ],
        steps: [
          'Boil rice cakes and fish cakes in a small amount of water.',
          'Stir in gochujang and sugar.',
          'Simmer until the sauce thickens and rice cakes are soft.',
          'Garnish with green onions.'
        ],
        equipment: ['Saucepan'],
        kcal: 380,
      ),
      _createStaticRecipe(
        'kr_5',
        'Korean Fried Chicken',
        'assets/images/others.png',
        20,
        30,
        ingredients: [
          _ri('Chicken Wings', '500g'),
          _ri('Cornstarch', '1/2 cup'),
          _ri('Sweet and Spicy Glaze', '1/2 cup'),
          _ri('Oil', 'for frying'),
        ],
        steps: [
          'Coat chicken wings in cornstarch.',
          'Double-fry for extra crispiness.',
          'Toss wings in the spicy Korean glaze while hot.',
          'Sprinkle with sesame seeds.'
        ],
        equipment: ['Deep Fryer', 'Large Bowl'],
        kcal: 750,
      ),
    ]),
    _createStaticCookbook('c_french', 'French', 'assets/images/others.png', [
      _createStaticRecipe('fr_1', 'Omelette', 'assets/images/recipe_omelet.png', 5, 5, 
        ingredients: [_ri('Eggs', '3 units'), _ri('Butter', '1 tbsp'), _ri('Salt', 'pinch')],
        steps: ['Whisk eggs.', 'Melt butter in pan.', 'Cook eggs until set.', 'Fold and serve.'],
        kcal: 300
      ),
      _createStaticRecipe(
        'fr_2',
        'Ratatouille',
        'assets/images/others.png',
        20,
        40,
        ingredients: [
          _ri('Eggplant', '1 unit'),
          _ri('Zucchini', '1 unit'),
          _ri('Red Bell Pepper', '1 unit'),
          _ri('Tomato Puree', '1 cup'),
          _ri('Herbes de Provence', '1 tsp'),
        ],
        steps: [
          'Slice all vegetables into thin rounds.',
          'Arrange vegetables in a spiral pattern in a dish over tomato puree.',
          'Drizzle with olive oil and sprinkle with herbs.',
          'Cover and bake for 40 minutes until tender.'
        ],
        equipment: ['Round Baking Dish', 'Mandoline Slicer'],
        kcal: 180,
      ),
      _createStaticRecipe(
        'fr_3',
        'Coq au Vin',
        'assets/images/others.png',
        30,
        60,
        ingredients: [
          _ri('Chicken Quarters', '4 units'),
          _ri('Red Wine (Burgundy)', '2 cups'),
          _ri('Bacon Lardons', '100g'),
          _ri('Mushrooms', '1 cup'),
          _ri('Pearl Onions', '1/2 cup'),
        ],
        steps: [
          'Brown chicken in a heavy pot and remove.',
          'Sauté bacon, onions, and mushrooms.',
          'Return chicken to pot and pour in wine.',
          'Simmer on low for 1 hour until tender.',
          'Thicken sauce with a bit of flour and butter.'
        ],
        equipment: ['Dutch Oven'],
        kcal: 680,
      ),
      _createStaticRecipe(
        'fr_4',
        'Croque Monsieur',
        'assets/images/others.png',
        10,
        10,
        ingredients: [
          _ri('Sourdough Bread', '2 slices'),
          _ri('Ham', '2 slices'),
          _ri('Gruyère Cheese', '1/2 cup'),
          _ri('Béchamel Sauce', '2 tbsp'),
        ],
        steps: [
          'Butter bread and toast one side.',
          'Layer ham and cheese between bread slices.',
          'Top with béchamel sauce and extra cheese.',
          'Broil in the oven until bubbly and brown.'
        ],
        equipment: ['Oven', 'Baking Sheet'],
        kcal: 550,
      ),
      _createStaticRecipe(
        'fr_5',
        'French Onion Soup',
        'assets/images/others.png',
        20,
        45,
        ingredients: [
          _ri('Yellow Onions', '4 large'),
          _ri('Beef Broth', '4 cups'),
          _ri('Baguette Slices', '4 units'),
          _ri('Gruyère Cheese', '1 cup'),
          _ri('Thyme', '1 sprig'),
        ],
        steps: [
          'Caramelize onions in butter for 30 minutes until deep brown.',
          'Add broth and thyme, simmer for 15 minutes.',
          'Ladle soup into crocks.',
          'Top with baguette and cheese, broil until melted.'
        ],
        equipment: ['Pot', 'Oven-safe Bowls'],
        kcal: 400,
      ),
      _createStaticRecipe(
        'fr_6',
        'Crepes',
        'assets/images/others.png',
        15,
        15,
        ingredients: [
          _ri('Flour', '1 cup'),
          _ri('Eggs', '2 units'),
          _ri('Milk', '1.5 cups'),
          _ri('Butter', '1 tbsp melted'),
          _ri('Sugar', '1 tbsp'),
        ],
        steps: [
          'Whisk ingredients until smooth.',
          'Pour a thin layer of batter into a hot non-stick pan.',
          'Cook for 1 minute per side.',
          'Fill with chocolate, fruit, or sugar.'
        ],
        equipment: ['Crepe Pan or Non-stick Skillet'],
        kcal: 250,
      ),
    ]),
    _createStaticCookbook('c_med', 'Mediterranean', 'assets/images/others.png', [
      _createStaticRecipe(
        'md_1',
        'Grilled Chicken Bowl',
        'assets/images/others.png',
        15,
        20,
        ingredients: [
          _ri('Chicken Breast', '250g'),
          _ri('Quinoa', '1 cup cooked'),
          _ri('Cherry Tomatoes', '1/2 cup'),
          _ri('Cucumber', '1/2 unit'),
          _ri('Hummus', '2 tbsp'),
        ],
        steps: [
          'Grill chicken until cooked through.',
          'Assemble bowl with quinoa, tomatoes, and cucumber.',
          'Top with grilled chicken and a dollop of hummus.'
        ],
        equipment: ['Grill', 'Bowl'],
        kcal: 450,
      ),
      _createStaticRecipe(
        'md_2',
        'Falafel',
        'assets/images/others.png',
        20,
        15,
        ingredients: [
          _ri('Chickpeas', '1 can drained'),
          _ri('Parsley', '1/2 cup'),
          _ri('Garlic', '2 cloves'),
          _ri('Cumin', '1 tsp'),
          _ri('Flour', '2 tbsp'),
        ],
        steps: [
          'Pulse chickpeas, herbs, and spices in a food processor.',
          'Form mixture into small balls.',
          'Fry in hot oil until brown and crispy.',
          'Serve with pita and tahini sauce.'
        ],
        equipment: ['Food Processor', 'Deep Skillet'],
        kcal: 320,
      ),
      _createStaticRecipe(
        'md_3',
        'Hummus',
        'assets/images/others.png',
        15,
        0,
        ingredients: [
          _ri('Chickpeas', '1 can'),
          _ri('Tahini', '1/2 cup'),
          _ri('Lemon Juice', '2 tbsp'),
          _ri('Garlic', '1 clove'),
        ],
        steps: [
          'Blend all ingredients in a food processor until smooth.',
          'Drizzle with olive oil and serve with pita.'
        ],
        equipment: ['Food Processor'],
        kcal: 180,
      ),
      _createStaticRecipe(
        'md_4',
        'Greek Salad',
        'assets/images/others.png',
        15,
        0,
        ingredients: [
          _ri('Cucumber', '1 unit'),
          _ri('Tomato', '2 units'),
          _ri('Feta Cheese', '100g'),
          _ri('Olives', '1/2 cup'),
        ],
        steps: [
          'Chop veggies and toss with olives and feta.',
          'Drizzle with olive oil and oregano.'
        ],
        equipment: ['Bowl'],
        kcal: 220,
      ),
      _createStaticRecipe(
        'md_5',
        'Shawarma',
        'assets/images/others.png',
        20,
        20,
        ingredients: [
          _ri('Chicken', '400g'),
          _ri('Shawarma Spices', '2 tbsp'),
          _ri('Pita Bread', '4 units'),
        ],
        steps: [
          'Season and grill chicken.',
          'Slice and serve in pita with garlic sauce.'
        ],
        equipment: ['Grill'],
        kcal: 550,
      ),
      _createStaticRecipe(
        'md_6',
        'Couscous Bowl',
        'assets/images/others.png',
        10,
        15,
        ingredients: [
          _ri('Couscous', '1 cup'),
          _ri('Roasted Veggies', '1 cup'),
          _ri('Chickpeas', '1/2 cup'),
        ],
        steps: [
          'Prepare couscous and fluff.',
          'Top with roasted veggies and chickpeas.'
        ],
        equipment: ['Bowl'],
        kcal: 380,
      ),
    ]),
    _createStaticCookbook('c_mid', 'Middle Eastern', 'assets/images/middle.png', [
      _createStaticRecipe(
        'me_1',
        'Chicken Shawarma',
        'assets/images/others.png',
        20,
        20,
        ingredients: [
          _ri('Chicken', '400g'),
          _ri('Cumin', '1 tsp'),
          _ri('Turmeric', '1 tsp'),
        ],
        steps: [
          'Grill spiced chicken and slice thinly.'
        ],
        kcal: 480,
      ),
      _createStaticRecipe(
        'me_2',
        'Lamb Kofta',
        'assets/images/others.png',
        15,
        15,
        ingredients: [
          _ri('Ground Lamb', '300g'),
          _ri('Parsley', '1/2 cup'),
          _ri('Onion', '1 unit'),
        ],
        steps: [
          'Mix ingredients, form onto skewers and grill.'
        ],
        kcal: 420,
      ),
      _createStaticRecipe(
        'me_3',
        'Hummus Plate',
        'assets/images/others.png',
        15,
        0,
        ingredients: [
          _ri('Hummus', '1 cup'),
          _ri('Olive Oil', '1 tbsp'),
          _ri('Paprika', 'pinch'),
        ],
        steps: [
          'Spread hummus on a plate and drizzle with oil.'
        ],
        kcal: 200,
      ),
      _createStaticRecipe(
        'me_4',
        'Falafel Wrap',
        'assets/images/others.png',
        20,
        15,
        ingredients: [
          _ri('Falafel', '4 units'),
          _ri('Pita', '1 unit'),
          _ri('Tahini', '1 tbsp'),
        ],
        steps: [
          'Place falafel in pita and top with tahini.'
        ],
        kcal: 450,
      ),
      _createStaticRecipe(
        'me_5',
        'Tabbouleh',
        'assets/images/others.png',
        20,
        0,
        ingredients: [
          _ri('Parsley', '2 cups'),
          _ri('Bulgur', '1/4 cup'),
          _ri('Tomato', '1 unit'),
        ],
        steps: [
          'Finely chop parsley and tomato, mix with soaked bulgur.'
        ],
        kcal: 150,
      ),
      _createStaticRecipe(
        'me_6',
        'Rice Pilaf',
        'assets/images/others.png',
        10,
        20,
        ingredients: [
          _ri('Rice', '1 cup'),
          _ri('Vermicelli', '1/4 cup'),
          _ri('Butter', '1 tbsp'),
        ],
        steps: [
          'Brown vermicelli in butter, add rice and water, then cook.'
        ],
        kcal: 320,
      ),
    ]),
    _createStaticCookbook('c_french_2', 'French Specialties', 'assets/images/others.png', [
      _createStaticRecipe(
        'fr_7',
        'Quiche Lorraine',
        'assets/images/others.png',
        20,
        35,
        ingredients: [
          _ri('Pie Crust', '1 unit'),
          _ri('Bacon', '150g'),
          _ri('Eggs', '4 units'),
          _ri('Heavy Cream', '1 cup'),
          _ri('Nutmeg', 'pinch'),
        ],
        steps: [
          'Pre-bake pie crust for 10 minutes.',
          'Cook bacon until crispy and place in crust.',
          'Whisk eggs, cream, and nutmeg.',
          'Pour over bacon and bake at 180°C for 30 minutes.'
        ],
        equipment: ['Tart Pan'],
        kcal: 480,
      ),
      _createStaticRecipe(
        'fr_8',
        'Beef Bourguignon',
        'assets/images/others.png',
        40,
        120,
        ingredients: [
          _ri('Beef Chuck', '500g'),
          _ri('Red Wine', '2 cups'),
          _ri('Carrots', '2 units'),
          _ri('Mushrooms', '1 cup'),
          _ri('Garlic', '3 cloves'),
        ],
        steps: [
          'Sear beef cubes in a hot pot.',
          'Add vegetables and sauté.',
          'Deglaze with wine and add herbs.',
          'Slow cook for 2 hours until meat falls apart.'
        ],
        equipment: ['Slow Cooker or Dutch Oven'],
        kcal: 620,
      ),
    ]),
    _createStaticCookbook('c_spanish', 'Spanish', 'assets/images/others.png', [
      _createStaticRecipe(
        'sp_1',
        'Paella',
        'assets/images/others.png',
        20,
        40,
        ingredients: [
          _ri('Paella Rice', '1 cup'),
          _ri('Shrimp', '200g'),
          _ri('Saffron', 'pinch'),
          _ri('Peas', '1/2 cup'),
          _ri('Chicken Thighs', '2 units'),
        ],
        steps: [
          'Brown chicken in a wide shallow pan.',
          'Add rice and saffron, stirring to coat.',
          'Pour in broth and simmer without stirring.',
          'Add shrimp and peas for the last 10 minutes.',
          'Let rest for 5 minutes before serving.'
        ],
        equipment: ['Paella Pan or Large Skillet'],
        kcal: 580,
      ),
      _createStaticRecipe(
        'sp_2',
        'Tortilla Española',
        'assets/images/others.png',
        15,
        25,
        ingredients: [
          _ri('Potatoes', '3 units sliced'),
          _ri('Eggs', '5 units'),
          _ri('Onion', '1 unit'),
          _ri('Olive Oil', '1/2 cup'),
        ],
        steps: [
          'Fry potatoes and onions in oil until soft.',
          'Drain oil and mix with beaten eggs.',
          'Cook in a pan on medium heat until set.',
          'Flip using a plate and cook the other side.'
        ],
        equipment: ['Non-stick Pan', 'Large Plate'],
        kcal: 350,
      ),
      _createStaticRecipe(
        'sp_3',
        'Patatas Bravas',
        'assets/images/others.png',
        15,
        30,
        ingredients: [
          _ri('Potatoes', '4 units cubed'),
          _ri('Tomato Puree', '1/2 cup'),
          _ri('Smoked Paprika', '1 tbsp'),
          _ri('Garlic Aioli', '2 tbsp'),
        ],
        steps: [
          'Deep fry or roast potato cubes until crispy.',
          'Make a spicy tomato sauce with paprika.',
          'Toss potatoes in sauce and top with aioli.'
        ],
        equipment: ['Deep Fryer or Oven'],
        kcal: 420,
      ),
      _createStaticRecipe(
        'sp_4',
        'Garlic Shrimp',
        'assets/images/others.png',
        10,
        10,
        ingredients: [
          _ri('Shrimp', '250g'),
          _ri('Garlic', '4 cloves sliced'),
          _ri('Olive Oil', '3 tbsp'),
          _ri('Red Chili Flakes', '1/2 tsp'),
        ],
        steps: [
          'Sizzle garlic and chili in olive oil.',
          'Add shrimp and cook until pink (2 mins).',
          'Serve sizzling hot with bread.'
        ],
        equipment: ['Small Cast Iron Skillet'],
        kcal: 310,
      ),
      _createStaticRecipe(
        'sp_5',
        'Churros',
        'assets/images/others.png',
        20,
        20,
        ingredients: [
          _ri('Water', '1 cup'),
          _ri('Flour', '1 cup'),
          _ri('Butter', '2 tbsp'),
          _ri('Cinnamon Sugar', 'for coating'),
        ],
        steps: [
          'Boil water and butter, then stir in flour.',
          'Pipe dough through a star tip into hot oil.',
          'Fry until golden and roll in cinnamon sugar.',
          'Serve with chocolate dipping sauce.'
        ],
        equipment: ['Piping Bag with Star Tip', 'Deep Fryer'],
        kcal: 400,
      ),
    ]),
    _createStaticCookbook('c_greek', 'Greek', 'assets/images/others.png', [
      _createStaticRecipe(
        'gr_1',
        'Gyro',
        'assets/images/others.png',
        15,
        15,
        ingredients: [
          _ri('Pita Bread', '2 units'),
          _ri('Lamb or Chicken', '200g sliced'),
          _ri('Tzatziki', '2 tbsp'),
          _ri('Tomato and Onion', 'sliced'),
        ],
        steps: [
          'Grill meat with Mediterranean spices.',
          'Warm pita and spread with tzatziki.',
          'Fill with meat, tomato, and onion.',
          'Roll up and serve.'
        ],
        equipment: ['Grill Pan'],
        kcal: 480,
      ),
      _createStaticRecipe(
        'gr_2',
        'Greek Salad',
        'assets/images/others.png',
        10,
        0,
        ingredients: [
          _ri('Cucumber', '1 unit'),
          _ri('Tomato', '2 units'),
          _ri('Feta Cheese', '100g'),
          _ri('Kalamata Olives', '1/2 cup'),
          _ri('Olive Oil', '2 tbsp'),
        ],
        steps: [
          'Chop vegetables into large chunks.',
          'Mix in a bowl with olives and feta.',
          'Drizzle with olive oil and dried oregano.'
        ],
        equipment: ['Bowl'],
        kcal: 220,
      ),
      _createStaticRecipe(
        'gr_3',
        'Moussaka',
        'assets/images/others.png',
        40,
        60,
        ingredients: [
          _ri('Eggplant', '2 large sliced'),
          _ri('Ground Lamb', '300g'),
          _ri('Tomato Sauce', '1 cup'),
          _ri('Béchamel Sauce', '2 cups'),
        ],
        steps: [
          'Fry eggplant slices until golden.',
          'Layer lamb sauce and eggplant in a dish.',
          'Top with a thick layer of béchamel.',
          'Bake at 180°C for 45 minutes.'
        ],
        equipment: ['Casserole Dish'],
        kcal: 650,
      ),
      _createStaticRecipe(
        'gr_4',
        'Souvlaki',
        'assets/images/others.png',
        20,
        15,
        ingredients: [
          _ri('Pork or Chicken Skewers', '4 units'),
          _ri('Lemon Juice', '2 tbsp'),
          _ri('Oregano', '1 tsp'),
          _ri('Garlic', '2 cloves'),
        ],
        steps: [
          'Marinate skewers in lemon, garlic, and oregano.',
          'Grill until charred and cooked through.',
          'Serve with pita and lemon wedges.'
        ],
        equipment: ['Grill'],
        kcal: 380,
      ),
      _createStaticRecipe(
        'gr_5',
        'Tzatziki',
        'assets/images/others.png',
        10,
        0,
        ingredients: [
          _ri('Greek Yogurt', '1 cup'),
          _ri('Grated Cucumber', '1/2 cup'),
          _ri('Garlic', '1 clove minced'),
          _ri('Dill', '1 tsp'),
        ],
        steps: [
          'Squeeze excess water from cucumber.',
          'Mix all ingredients in a bowl.',
          'Chill for 30 minutes before serving.'
        ],
        equipment: ['Bowl', 'Grater'],
        kcal: 120,
      ),
    ]),
    _createStaticCookbook('c_caribbean', 'Caribbean', 'assets/images/caribbean.png', [
      _createStaticRecipe(
        'cb_1',
        'Jerk Chicken',
        'assets/images/others.png',
        20,
        45,
        ingredients: [
          _ri('Chicken Quarters', '2 units'),
          _ri('Jerk Seasoning', '3 tbsp'),
          _ri('Scotch Bonnet Pepper', '1 unit minced'),
          _ri('Thyme', '3 sprigs'),
          _ri('Allspice', '1 tsp'),
        ],
        steps: [
          'Rub chicken with jerk seasoning and let marinate.',
          'Grill over medium heat, turning occasionally.',
          'Baste with extra sauce during cooking.',
          'Serve with rice and peas.'
        ],
        equipment: ['Grill', 'Tongs'],
        kcal: 520,
      ),
      _createStaticRecipe(
        'cb_2',
        'Rice and Peas',
        'assets/images/others.png',
        10,
        40,
        ingredients: [
          _ri('Basmati Rice', '2 cups'),
          _ri('Kidney Beans (Peas)', '1 can'),
          _ri('Coconut Milk', '1 cup'),
          _ri('Scotch Bonnet Pepper', '1 unit whole'),
          _ri('Thyme', '2 sprigs'),
        ],
        steps: [
          'Rinse rice and place in a pot with coconut milk and water.',
          'Add beans, whole pepper (do not burst), and thyme.',
          'Bring to a boil then simmer on low for 20 minutes.',
          'Remove thyme and pepper before fluffing with a fork.'
        ],
        equipment: ['Large Pot'],
        kcal: 420,
      ),
      _createStaticRecipe(
        'cb_3',
        'Curry Chicken',
        'assets/images/others.png',
        20,
        35,
        ingredients: [
          _ri('Chicken Pieces', '500g'),
          _ri('Jamaican Curry Powder', '3 tbsp'),
          _ri('Potatoes', '2 units cubed'),
          _ri('Carrots', '1 unit sliced'),
          _ri('Coconut Milk', '1/2 cup'),
        ],
        steps: [
          'Season chicken with curry powder and let marinate.',
          'Brown chicken in a pot.',
          'Add vegetables and coconut milk.',
          'Simmer for 30 minutes until chicken is tender.'
        ],
        equipment: ['Large Pot'],
        kcal: 480,
      ),
      _createStaticRecipe(
        'cb_4',
        'Fried Plantains',
        'assets/images/others.png',
        5,
        10,
        ingredients: [
          _ri('Ripe Plantains', '2 units'),
          _ri('Vegetable Oil', 'for frying'),
          _ri('Salt', 'pinch'),
        ],
        steps: [
          'Peel and slice plantains diagonally.',
          'Fry in hot oil until golden brown and caramelized.',
          'Drain on paper towels and sprinkle with salt.'
        ],
        equipment: ['Frying Pan'],
        kcal: 220,
      ),
      _createStaticRecipe(
        'cb_5',
        'Oxtail',
        'assets/images/others.png',
        20,
        120,
        ingredients: [
          _ri('Oxtail Pieces', '1kg'),
          _ri('Broad Beans', '1 can'),
          _ri('Browning Sauce', '1 tbsp'),
          _ri('Allspice', '1 tsp'),
          _ri('Ginger', '1 tbsp minced'),
        ],
        steps: [
          'Season oxtail and brown in a pot.',
          'Add water and spices, simmer for 2 hours until tender.',
          'Add broad beans for the last 15 minutes to thicken sauce.',
          'Serve with rice and peas.'
        ],
        equipment: ['Pressure Cooker or Heavy Pot'],
        kcal: 750,
      ),
    ]),
    _createStaticCookbook('c_west_african', 'West African', 'assets/images/west.png', [
      _createStaticRecipe(
        'wa_1',
        'Jollof Rice',
        'assets/images/others.png',
        20,
        45,
        ingredients: [
          _ri('Long Grain Rice', '2 cups'),
          _ri('Tomato Paste', '3 tbsp'),
          _ri('Red Bell Peppers', '2 units blended'),
          _ri('Onions', '2 units'),
          _ri('Thyme', '1 tsp'),
        ],
        steps: [
          'Fry onions and tomato paste in oil.',
          'Add blended pepper mixture and spices, cook for 10 minutes.',
          'Add rice and enough water/broth to cover.',
          'Cover tightly and steam until rice is tender and dry.'
        ],
        equipment: ['Large Heavy Pot with Lid'],
        kcal: 480,
      ),
      _createStaticRecipe(
        'wa_2',
        'Suya',
        'assets/images/others.png',
        20,
        15,
        ingredients: [
          _ri('Beef Sirloin', '300g thinly sliced'),
          _ri('Kuli-Kuli (Peanut Spice)', '1/2 cup'),
          _ri('Cayenne Pepper', '1 tsp'),
          _ri('Ginger Powder', '1 tsp'),
        ],
        steps: [
          'Coat beef slices heavily with Suya spice mix.',
          'Thread onto skewers.',
          'Grill over high heat for 3-4 minutes per side.',
          'Serve with sliced onions and tomatoes.'
        ],
        equipment: ['Grill', 'Metal Skewers'],
        kcal: 400,
      ),
      _createStaticRecipe(
        'wa_3',
        'Egusi Soup',
        'assets/images/others.png',
        20,
        40,
        ingredients: [
          _ri('Ground Egusi Seeds', '1 cup'),
          _ri('Spinach', '2 cups chopped'),
          _ri('Assorted Meat', '300g'),
          _ri('Palm Oil', '1/4 cup'),
          _ri('Crayfish Powder', '1 tbsp'),
        ],
        steps: [
          'Cook meat until tender.',
          'Mix egusi with a little water to form a paste.',
          'Fry egusi paste in palm oil until it forms lumps.',
          'Add meat broth and crayfish, simmer for 15 minutes.',
          'Add spinach and cook for 5 more minutes.'
        ],
        equipment: ['Large Pot'],
        kcal: 550,
      ),
      _createStaticRecipe(
        'wa_4',
        'Fried Rice (West African style)',
        'assets/images/others.png',
        20,
        30,
        ingredients: [
          _ri('Parboiled Rice', '2 cups'),
          _ri('Mixed Vegetables', '1 cup'),
          _ri('Liver or Shrimp', '100g diced'),
          _ri('Curry Powder', '1 tsp'),
          _ri('Thyme', '1/2 tsp'),
        ],
        steps: [
          'Sauté vegetables and meat in oil.',
          'Add parboiled rice and spices.',
          'Stir-fry until rice is well coated and heated through.',
          'Serve with fried plantain and chicken.'
        ],
        equipment: ['Large Skillet or Wok'],
        kcal: 480,
      ),
      _createStaticRecipe(
        'wa_5',
        'Grilled Fish',
        'assets/images/others.png',
        15,
        30,
        ingredients: [
          _ri('Whole Tilapia', '1 unit'),
          _ri('Ginger and Garlic', 'minced'),
          _ri('Scotch Bonnet', '1 unit'),
          _ri('Lemon', '1 unit'),
        ],
        steps: [
          'Score the fish and marinate with spices.',
          'Grill over charcoal or in an oven.',
          'Baste with spicy oil during grilling.',
          'Serve with fried yam or plantain.'
        ],
        equipment: ['Grill or Oven'],
        kcal: 400,
      ),
      _createStaticRecipe(
        'wa_6',
        'Plantain',
        'assets/images/others.png',
        5,
        10,
        ingredients: [
          _ri('Ripe Plantain', '2 units'),
          _ri('Oil', 'for frying'),
        ],
        steps: [
          'Slice and fry until golden brown.',
          'Serve as a side dish.'
        ],
        equipment: ['Frying Pan'],
        kcal: 220,
      ),
    ]),
  ];

  static final List<({Cookbook cookbook, String image})> niches = [
    _createStaticCookbook('n_hp_lc', 'High Protein, Low Calorie', 'assets/images/explore_autumn.png', [
      _createStaticRecipe(
        'n1_1',
        'Grilled Chicken Bowl',
        'assets/images/others.png',
        15,
        20,
        ingredients: [
          _ri('Chicken Breast', '200g'),
          _ri('Brown Rice', '1 cup'),
          _ri('Broccoli', '1 cup steamed'),
          _ri('Avocado', '1/2 unit'),
        ],
        steps: [
          'Grill chicken with simple spices.',
          'Steam broccoli until tender.',
          'Assemble bowl with rice, chicken, and broccoli.',
          'Top with sliced avocado.'
        ],
        kcal: 450,
      ),
      _createStaticRecipe(
        'n1_2',
        'Turkey Lettuce Wraps',
        'assets/images/others.png',
        15,
        15,
        ingredients: [
          _ri('Ground Turkey', '300g'),
          _ri('Butter Lettuce Leaves', '8 units'),
          _ri('Water Chestnuts', '1/4 cup'),
          _ri('Hoisin Sauce', '1 tbsp'),
        ],
        steps: [
          'Brown turkey in a pan.',
          'Add chopped chestnuts and hoisin sauce.',
          'Spoon mixture into lettuce leaves and serve.'
        ],
        kcal: 320,
      ),
      _createStaticRecipe(
        'n1_3',
        'Garlic Shrimp with Vegetables',
        'assets/images/others.png',
        10,
        10,
        ingredients: [
          _ri('Shrimp', '200g'),
          _ri('Zucchini', '1 unit'),
          _ri('Bell Peppers', '1 unit'),
          _ri('Garlic', '3 cloves'),
        ],
        steps: [
          'Sauté vegetables in a pan.',
          'Add shrimp and garlic, cook until pink.',
          'Serve hot.'
        ],
        kcal: 280,
      ),
      _createStaticRecipe(
        'n1_4',
        'Baked Salmon with Asparagus',
        'assets/images/recipe_salmon.png',
        10,
        20,
        ingredients: [
          _ri('Salmon Fillet', '200g'),
          _ri('Asparagus', '1 bunch'),
          _ri('Lemon', '1/2 unit'),
        ],
        steps: [
          'Bake salmon and asparagus at 200°C for 15 minutes.'
        ],
        kcal: 380,
      ),
      _createStaticRecipe(
        'n1_5',
        'Chicken Stir-Fry',
        'assets/images/recipe_stir_fry.png',
        15,
        15,
        ingredients: [
          _ri('Chicken', '200g'),
          _ri('Bell Peppers', '1 cup'),
          _ri('Soy Sauce', '2 tbsp'),
        ],
        steps: [
          'Stir-fry chicken and peppers in a hot pan.'
        ],
        kcal: 420,
      ),
      _createStaticRecipe(
        'n1_6',
        'Greek Yogurt Chicken Salad',
        'assets/images/others.png',
        15,
        0,
        ingredients: [
          _ri('Chicken Breast', '200g cooked'),
          _ri('Greek Yogurt', '1/4 cup'),
          _ri('Celery', '1/2 cup'),
        ],
        steps: [
          'Mix all ingredients in a bowl and serve on lettuce.'
        ],
        kcal: 310,
      ),
      _createStaticRecipe(
        'n1_7',
        'Egg White Omelet',
        'assets/images/others.png',
        5,
        10,
        ingredients: [
          _ri('Egg Whites', '4 units'),
          _ri('Spinach', '1/2 cup'),
          _ri('Feta', '1 tbsp'),
        ],
        steps: [
          'Cook egg whites with spinach and top with feta.'
        ],
        kcal: 180,
      ),
    ]),
    _createStaticCookbook('n_desserts', 'Easy Desserts', 'assets/images/cookbook_healthy.png', [
      _createStaticRecipe(
        'n2_1',
        'Chocolate Chip Cookies',
        'assets/images/others.png',
        15,
        15,
        ingredients: [
          _ri('Flour', '2 cups'),
          _ri('Chocolate Chips', '1 cup'),
          _ri('Butter', '1/2 cup'),
          _ri('Sugar', '1/2 cup'),
          _ri('Egg', '1 unit'),
        ],
        steps: [
          'Cream butter and sugar, then add egg.',
          'Mix in flour and chocolate chips.',
          'Drop spoonfuls onto a baking sheet.',
          'Bake at 180°C for 10-12 minutes.'
        ],
        equipment: ['Baking Sheet', 'Mixing Bowl'],
        kcal: 150,
      ),
      _createStaticRecipe(
        'n2_2',
        'Brownies',
        'assets/images/others.png',
        15,
        30,
        ingredients: [
          _ri('Cocoa Powder', '1/2 cup'),
          _ri('Flour', '1/2 cup'),
          _ri('Butter', '1/2 cup'),
          _ri('Sugar', '1 cup'),
          _ri('Eggs', '2 units'),
        ],
        steps: [
          'Melt butter and mix with sugar and cocoa.',
          'Whisk in eggs and fold in flour.',
          'Pour into a square pan and bake at 170°C for 25 minutes.'
        ],
        equipment: ['8x8 Square Pan'],
        kcal: 220,
      ),
      _createStaticRecipe(
        'n2_3',
        'Cheesecake Cups',
        'assets/images/others.png',
        20,
        0,
        ingredients: [
          _ri('Cream Cheese', '200g'),
          _ri('Graham Cracker Crumbs', '1/2 cup'),
          _ri('Sugar', '1/4 cup'),
        ],
        steps: [
          'Beat cream cheese and sugar, spoon over crumbs in cups and chill.'
        ],
        kcal: 250,
      ),
      _createStaticRecipe(
        'n2_4',
        'Banana Bread',
        'assets/images/others.png',
        15,
        60,
        ingredients: [
          _ri('Ripe Bananas', '3 units'),
          _ri('Flour', '1.5 cups'),
          _ri('Sugar', '3/4 cup'),
        ],
        steps: [
          'Mash bananas, mix with other ingredients and bake in a loaf pan.'
        ],
        kcal: 200,
      ),
      _createStaticRecipe(
        'n2_5',
        'Strawberry Shortcake',
        'assets/images/others.png',
        20,
        15,
        ingredients: [
          _ri('Shortcakes', '4 units'),
          _ri('Strawberries', '2 cups'),
          _ri('Whipped Cream', '1 cup'),
        ],
        steps: [
          'Top shortcakes with sliced strawberries and whipped cream.'
        ],
        kcal: 320,
      ),
      _createStaticRecipe(
        'n2_6',
        'Chocolate Mug Cake',
        'assets/images/others.png',
        5,
        2,
        ingredients: [
          _ri('Flour', '4 tbsp'),
          _ri('Cocoa', '2 tbsp'),
          _ri('Milk', '3 tbsp'),
        ],
        steps: [
          'Mix in a mug and microwave for 90 seconds.'
        ],
        kcal: 280,
      ),
      _createStaticRecipe(
        'n2_7',
        'Fruit Yogurt Parfait',
        'assets/images/others.png',
        10,
        0,
        ingredients: [
          _ri('Yogurt', '1 cup'),
          _ri('Granola', '1/4 cup'),
          _ri('Berries', '1/2 cup'),
        ],
        steps: [
          'Layer yogurt, granola, and berries in a glass.'
        ],
        kcal: 220,
      ),
    ]),
    _createStaticCookbook('n_30_min', '30-Minute Meals', 'assets/images/explore_spring.png', [
      _createStaticRecipe(
        'n3_1',
        'Chicken Stir-Fry',
        'assets/images/recipe_stir_fry.png',
        10,
        15,
        ingredients: [
          _ri('Chicken Breast', '250g'),
          _ri('Mixed Veggies', '2 cups'),
          _ri('Soy Sauce', '2 tbsp'),
        ],
        steps: [
          'Sear chicken in a pan.',
          'Add veggies and stir-fry.',
          'Add soy sauce and serve over rice.'
        ],
        kcal: 400,
      ),
      _createStaticRecipe(
        'n3_2',
        'Garlic Butter Shrimp',
        'assets/images/others.png',
        10,
        10,
        ingredients: [
          _ri('Shrimp', '300g'),
          _ri('Butter', '2 tbsp'),
          _ri('Garlic', '4 cloves'),
        ],
        steps: [
          'Sauté garlic in butter.',
          'Add shrimp and cook for 3 minutes.',
          'Serve with bread or pasta.'
        ],
        kcal: 350,
      ),
      _createStaticRecipe(
        'n3_3',
        'Beef Tacos',
        'assets/images/others.png',
        10,
        15,
        ingredients: [
          _ri('Ground Beef', '300g'),
          _ri('Taco Shells', '6 units'),
          _ri('Shredded Lettuce', '1 cup'),
        ],
        steps: [
          'Cook beef with spices.',
          'Fill taco shells with beef and lettuce.',
          'Serve with salsa.'
        ],
        kcal: 500,
      ),
      _createStaticRecipe(
        'n3_4',
        'Fried Rice',
        'assets/images/others.png',
        10,
        15,
        ingredients: [
          _ri('Rice', '2 cups cooked'),
          _ri('Peas and Carrots', '1/2 cup'),
          _ri('Egg', '1 unit'),
        ],
        steps: [
          'Stir-fry veggies and rice, then scramble in an egg.'
        ],
        kcal: 380,
      ),
      _createStaticRecipe(
        'n3_5',
        'Pasta Alfredo',
        'assets/images/recipe_pasta.png',
        10,
        15,
        ingredients: [
          _ri('Pasta', '200g'),
          _ri('Alfredo Sauce', '1 cup'),
        ],
        steps: [
          'Boil pasta and toss with warm alfredo sauce.'
        ],
        kcal: 450,
      ),
      _createStaticRecipe(
        'n3_6',
        'Chicken Quesadilla',
        'assets/images/others.png',
        10,
        10,
        ingredients: [
          _ri('Tortilla', '2 units'),
          _ri('Cheese', '1/2 cup'),
          _ri('Chicken', '100g'),
        ],
        steps: [
          'Place chicken and cheese in tortillas and grill until melted.'
        ],
        kcal: 420,
      ),
    ]),
    _createStaticCookbook('n_meal_prep', 'Meal Prep Favorites', 'assets/images/others.png', [
      _createStaticRecipe(
        'n4_1',
        'Chicken and Rice Bowl',
        'assets/images/others.png',
        15,
        30,
        ingredients: [
          _ri('Chicken', '500g'),
          _ri('Rice', '2 cups'),
          _ri('Vegetables', '2 cups'),
        ],
        steps: [
          'Cook rice and chicken separately.',
          'Divide into 4 containers with vegetables.',
          'Reheat and enjoy for lunch.'
        ],
        kcal: 520,
      ),
      _createStaticRecipe(
        'n4_2',
        'Ground Turkey Bowls',
        'assets/images/others.png',
        15,
        20,
        ingredients: [
          _ri('Ground Turkey', '500g'),
          _ri('Sweet Potato', '2 units'),
          _ri('Spinach', '2 cups'),
        ],
        steps: [
          'Roast potatoes and cook turkey.',
          'Combine in meal prep containers.',
        ],
        kcal: 480,
      ),
      _createStaticRecipe(
        'n4_3',
        'Salmon with Veggies',
        'assets/images/recipe_salmon.png',
        10,
        20,
        ingredients: [
          _ri('Salmon', '400g'),
          _ri('Broccoli', '2 cups'),
        ],
        steps: [
          'Bake salmon and broccoli, then portion for the week.'
        ],
        kcal: 450,
      ),
      _createStaticRecipe(
        'n4_4',
        'Egg Muffins',
        'assets/images/others.png',
        15,
        25,
        ingredients: [
          _ri('Eggs', '6 units'),
          _ri('Spinach', '1 cup'),
          _ri('Cheese', '1/4 cup'),
        ],
        steps: [
          'Bake whisked eggs and veggies in muffin tins.'
        ],
        kcal: 180,
      ),
      _createStaticRecipe(
        'n4_5',
        'Pasta Meal Prep',
        'assets/images/recipe_pasta.png',
        15,
        20,
        ingredients: [
          _ri('Penne', '300g'),
          _ri('Marinara Sauce', '2 cups'),
          _ri('Meatballs', '12 units'),
        ],
        steps: [
          'Cook pasta and meatballs, then portion with sauce.'
        ],
        kcal: 550,
      ),
      _createStaticRecipe(
        'n4_6',
        'Stir-Fry Boxes',
        'assets/images/recipe_stir_fry.png',
        15,
        15,
        ingredients: [
          _ri('Beef', '400g'),
          _ri('Mixed Veggies', '3 cups'),
        ],
        steps: [
          'Stir-fry and portion with rice or noodles.'
        ],
        kcal: 480,
      ),
    ]),
    _createStaticCookbook('n_comfort', 'Comfort Food', 'assets/images/others.png', [
      _createStaticRecipe(
        'n5_1',
        'Mac and Cheese',
        'assets/images/others.png',
        15,
        30,
        ingredients: [
          _ri('Macaroni', '250g'),
          _ri('Cheddar Cheese', '2 cups'),
          _ri('Milk', '1 cup'),
        ],
        steps: [
          'Boil pasta.',
          'Melt cheese and milk into a sauce.',
          'Combine and bake until bubbly.'
        ],
        kcal: 650,
      ),
      _createStaticRecipe(
        'n5_2',
        'Fried Chicken',
        'assets/images/others.png',
        20,
        30,
        ingredients: [
          _ri('Chicken Drumsticks', '4 units'),
          _ri('Flour', '1 cup'),
          _ri('Buttermilk', '1 cup'),
        ],
        steps: [
          'Dip chicken in buttermilk then flour.',
          'Deep fry until golden brown.'
        ],
        kcal: 750,
      ),
      _createStaticRecipe(
        'n5_3',
        'Mashed Potatoes',
        'assets/images/others.png',
        15,
        20,
        ingredients: [
          _ri('Potatoes', '4 units'),
          _ri('Butter', '2 tbsp'),
          _ri('Cream', '1/4 cup'),
        ],
        steps: [
          'Boil potatoes and mash with butter and cream.'
        ],
        kcal: 300,
      ),
      _createStaticRecipe(
        'n5_4',
        'Chicken Pot Pie',
        'assets/images/others.png',
        30,
        40,
        ingredients: [
          _ri('Pie Crust', '2 units'),
          _ri('Chicken', '1 cup'),
          _ri('Mixed Veggies', '1 cup'),
        ],
        steps: [
          'Fill crust with chicken and veggies in gravy and bake.'
        ],
        kcal: 580,
      ),
      _createStaticRecipe(
        'n5_5',
        'Beef Stew',
        'assets/images/others.png',
        20,
        90,
        ingredients: [
          _ri('Beef Cubes', '500g'),
          _ri('Potatoes', '2 units'),
          _ri('Beef Broth', '4 cups'),
        ],
        steps: [
          'Slow cook beef and veggies in broth until tender.'
        ],
        kcal: 520,
      ),
      _createStaticRecipe(
        'n5_6',
        'Grilled Cheese',
        'assets/images/others.png',
        5,
        10,
        ingredients: [
          _ri('Bread', '2 slices'),
          _ri('Cheese', '2 slices'),
          _ri('Butter', '1 tbsp'),
        ],
        steps: [
          'Grill sandwich in buttered pan until golden.'
        ],
        kcal: 350,
      ),
    ]),
    _createStaticCookbook('n_healthy_bfast', 'Healthy Breakfasts', 'assets/images/others.png', [
      _createStaticRecipe(
        'n6_1',
        'Avocado Toast',
        'assets/images/others.png',
        5,
        5,
        ingredients: [
          _ri('Sourdough Bread', '1 slice'),
          _ri('Avocado', '1/2 unit'),
          _ri('Egg', '1 unit'),
        ],
        steps: [
          'Toast bread.',
          'Mash avocado on top.',
          'Add a poached egg and seasoning.'
        ],
        kcal: 320,
      ),
      _createStaticRecipe(
        'n6_2',
        'Oatmeal Bowl',
        'assets/images/others.png',
        5,
        5,
        ingredients: [
          _ri('Oats', '1/2 cup'),
          _ri('Milk', '1 cup'),
          _ri('Berries', '1/4 cup'),
        ],
        steps: [
          'Cook oats in milk.',
          'Top with fresh berries and honey.'
        ],
        kcal: 280,
      ),
      _createStaticRecipe(
        'n6_3',
        'Smoothie Bowl',
        'assets/images/others.png',
        10,
        0,
        ingredients: [
          _ri('Frozen Berries', '1 cup'),
          _ri('Banana', '1 unit'),
          _ri('Almond Milk', '1/2 cup'),
        ],
        steps: [
          'Blend thick and top with granola and seeds.'
        ],
        kcal: 310,
      ),
      _createStaticRecipe(
        'n6_4',
        'Egg Scramble',
        'assets/images/others.png',
        5,
        5,
        ingredients: [
          _ri('Eggs', '2 units'),
          _ri('Spinach', '1/2 cup'),
        ],
        steps: [
          'Scramble eggs with spinach.'
        ],
        kcal: 220,
      ),
      _createStaticRecipe(
        'n6_5',
        'Greek Yogurt Bowl',
        'assets/images/others.png',
        5,
        0,
        ingredients: [
          _ri('Greek Yogurt', '1 cup'),
          _ri('Honey', '1 tbsp'),
          _ri('Nuts', '1/4 cup'),
        ],
        steps: [
          'Top yogurt with nuts and honey.'
        ],
        kcal: 280,
      ),
      _createStaticRecipe(
        'n6_6',
        'Protein Pancakes',
        'assets/images/others.png',
        10,
        15,
        ingredients: [
          _ri('Protein Powder', '1 scoop'),
          _ri('Egg', '1 unit'),
          _ri('Banana', '1 unit'),
        ],
        steps: [
          'Mash banana, mix with egg and powder, then fry.'
        ],
        kcal: 350,
      ),
    ]),
    _createStaticCookbook('n_quick_lunches', 'Quick Lunches', 'assets/images/others.png', [
      _createStaticRecipe(
        'n7_1',
        'Chicken Wrap',
        'assets/images/others.png',
        10,
        5,
        ingredients: [
          _ri('Tortilla', '1 unit'),
          _ri('Grilled Chicken', '100g'),
          _ri('Lettuce', 'handful'),
        ],
        steps: [
          'Place ingredients on tortilla.',
          'Roll up and serve cold or toasted.'
        ],
        kcal: 350,
      ),
      _createStaticRecipe(
        'n7_2',
        'Turkey Sandwich',
        'assets/images/others.png',
        5,
        0,
        ingredients: [
          _ri('Whole Wheat Bread', '2 slices'),
          _ri('Turkey Slices', '3 units'),
          _ri('Cheese', '1 slice'),
        ],
        steps: [
          'Assemble sandwich with mayo or mustard.'
        ],
        kcal: 310,
      ),
      _createStaticRecipe(
        'n7_3',
        'Caesar Salad',
        'assets/images/others.png',
        15,
        0,
        ingredients: [
          _ri('Romaine Lettuce', '2 cups'),
          _ri('Croutons', '1/2 cup'),
          _ri('Caesar Dressing', '2 tbsp'),
        ],
        steps: [
          'Toss lettuce with dressing and croutons.'
        ],
        kcal: 380,
      ),
      _createStaticRecipe(
        'n7_4',
        'Rice Bowl',
        'assets/images/others.png',
        10,
        10,
        ingredients: [
          _ri('Rice', '1 cup cooked'),
          _ri('Canned Beans', '1/2 cup'),
          _ri('Salsa', '2 tbsp'),
        ],
        steps: [
          'Heat rice and beans, then top with salsa.'
        ],
        kcal: 400,
      ),
      _createStaticRecipe(
        'n7_5',
        'Tuna Salad',
        'assets/images/others.png',
        10,
        0,
        ingredients: [
          _ri('Canned Tuna', '1 can'),
          _ri('Mayo', '1 tbsp'),
          _ri('Crackers', '6 units'),
        ],
        steps: [
          'Mix tuna and mayo, serve with crackers.'
        ],
        kcal: 320,
      ),
      _createStaticRecipe(
        'n7_6',
        'Quesadilla',
        'assets/images/others.png',
        5,
        10,
        ingredients: [
          _ri('Tortilla', '1 unit'),
          _ri('Cheese', '1/4 cup'),
        ],
        steps: [
          'Fold cheese in tortilla and grill.'
        ],
        kcal: 300,
      ),
    ]),
    _createStaticCookbook('n_vegan', 'Vegan Essentials', 'assets/images/others.png', [
      _createStaticRecipe(
        'n8_1',
        'Vegan Stir-Fry',
        'assets/images/others.png',
        15,
        15,
        ingredients: [
          _ri('Tofu', '200g'),
          _ri('Broccoli', '1 cup'),
          _ri('Soy Sauce', '2 tbsp'),
        ],
        steps: [
          'Sauté tofu until golden.',
          'Add broccoli and sauce.',
          'Stir-fry for 5 minutes.'
        ],
        kcal: 380,
      ),
      _createStaticRecipe(
        'n8_2',
        'Lentil Soup',
        'assets/images/others.png',
        15,
        40,
        ingredients: [
          _ri('Lentils', '1 cup'),
          _ri('Carrots', '1 unit'),
          _ri('Vegetable Broth', '4 cups'),
        ],
        steps: [
          'Boil everything until lentils are soft.',
          'Season with salt and pepper.'
        ],
        kcal: 320,
      ),
      _createStaticRecipe(
        'n8_3',
        'Chickpea Salad',
        'assets/images/others.png',
        15,
        0,
        ingredients: [
          _ri('Chickpeas', '1 can'),
          _ri('Cucumber', '1/2 unit'),
          _ri('Tahini Dressing', '2 tbsp'),
        ],
        steps: [
          'Toss chickpeas and cucumber with dressing.'
        ],
        kcal: 310,
      ),
      _createStaticRecipe(
        'n8_4',
        'Vegan Tacos',
        'assets/images/others.png',
        15,
        15,
        ingredients: [
          _ri('Lentils', '1 cup cooked'),
          _ri('Taco Shells', '3 units'),
          _ri('Guacamole', '1/4 cup'),
        ],
        steps: [
          'Fill shells with lentils and top with guac.'
        ],
        kcal: 420,
      ),
      _createStaticRecipe(
        'n8_5',
        'Buddha Bowl',
        'assets/images/others.png',
        20,
        20,
        ingredients: [
          _ri('Quinoa', '1 cup cooked'),
          _ri('Roasted Chickpeas', '1/2 cup'),
          _ri('Kale', '1 cup'),
        ],
        steps: [
          'Assemble bowl with all ingredients and a lemon dressing.'
        ],
        kcal: 450,
      ),
      _createStaticRecipe(
        'n8_6',
        'Vegan Curry',
        'assets/images/others.png',
        15,
        25,
        ingredients: [
          _ri('Coconut Milk', '1 can'),
          _ri('Sweet Potato', '1 unit'),
          _ri('Chickpeas', '1 can'),
        ],
        steps: [
          'Simmer veggies and chickpeas in coconut milk and curry spices.'
        ],
        kcal: 480,
      ),
    ]),
    _createStaticCookbook('n_low_carb', 'Low-Carb Meals', 'assets/images/others.png', [
      _createStaticRecipe(
        'n9_1',
        'Grilled Chicken Salad',
        'assets/images/others.png',
        15,
        15,
        ingredients: [
          _ri('Chicken Breast', '200g'),
          _ri('Mixed Greens', '2 cups'),
          _ri('Olive Oil', '1 tbsp'),
        ],
        steps: [
          'Grill chicken and slice.',
          'Toss with greens and oil.'
        ],
        kcal: 350,
      ),
      _createStaticRecipe(
        'n9_2',
        'Zucchini Noodles',
        'assets/images/others.png',
        15,
        10,
        ingredients: [
          _ri('Zucchini', '2 units spiraled'),
          _ri('Tomato Sauce', '1/2 cup'),
          _ri('Garlic', '2 cloves'),
        ],
        steps: [
          'Sauté garlic and zucchini noodles for 3 minutes.',
          'Top with warm tomato sauce.'
        ],
        kcal: 180,
      ),
      _createStaticRecipe(
        'n9_3',
        'Lettuce Wrap Burgers',
        'assets/images/others.png',
        15,
        15,
        ingredients: [
          _ri('Beef Patty', '1 unit'),
          _ri('Lettuce Leaves', '2 large'),
          _ri('Tomato and Onion', 'slices'),
        ],
        steps: [
          'Grill patty and wrap in lettuce with veggies.'
        ],
        kcal: 380,
      ),
      _createStaticRecipe(
        'n9_4',
        'Egg Scramble',
        'assets/images/others.png',
        5,
        5,
        ingredients: [
          _ri('Eggs', '3 units'),
          _ri('Avocado', '1/2 unit'),
        ],
        steps: [
          'Scramble eggs and serve with sliced avocado.'
        ],
        kcal: 320,
      ),
      _createStaticRecipe(
        'n9_5',
        'Salmon and Veggies',
        'assets/images/recipe_salmon.png',
        10,
        20,
        ingredients: [
          _ri('Salmon', '200g'),
          _ri('Asparagus', '1 bunch'),
        ],
        steps: [
          'Bake together at 200°C for 15 minutes.'
        ],
        kcal: 380,
      ),
      _createStaticRecipe(
        'n9_6',
        'Cauliflower Rice Bowl',
        'assets/images/others.png',
        15,
        15,
        ingredients: [
          _ri('Cauliflower Rice', '2 cups'),
          _ri('Ground Beef', '200g'),
          _ri('Peppers', '1/2 cup'),
        ],
        steps: [
          'Sauté beef and peppers, then stir in cauliflower rice until warm.'
        ],
        kcal: 420,
      ),
    ]),
  ];

  static final List<Recipe> popularNow = [
    _createStaticRecipe(
      'pn_1',
      'Chicken Stir-Fry',
      'assets/images/recipe_stir_fry.png',
      15,
      15,
      ingredients: [
        _ri('Chicken Breast', '250g'),
        _ri('Bell Peppers', '2 units'),
        _ri('Broccoli', '1 head'),
        _ri('Soy Sauce', '2 tbsp'),
        _ri('Ginger', '1 tsp'),
      ],
      steps: [
        'Cut chicken and vegetables into bite-sized pieces.',
        'Stir-fry chicken in a hot wok until cooked.',
        'Add vegetables and cook until tender-crisp.',
        'Pour in soy sauce and ginger, toss to coat.',
        'Serve hot over rice or noodles.'
      ],
      equipment: ['Wok or Large Skillet', 'Knife', 'Cutting Board'],
      kcal: 380,
      category: 'Chinese',
    ),
    _createStaticRecipe(
      'pn_2',
      'Grilled Salmon',
      'assets/images/recipe_salmon.png',
      10,
      15,
      ingredients: [
        _ri('Salmon Fillet', '2 units'),
        _ri('Lemon', '1 unit'),
        _ri('Asparagus', '1 bunch'),
        _ri('Olive Oil', '1 tbsp'),
        _ri('Salt and Pepper', 'to taste'),
      ],
      steps: [
        'Season salmon with salt, pepper, and olive oil.',
        'Preheat grill or pan over medium-high heat.',
        'Grill salmon for 4-5 minutes per side.',
        'Steam or grill asparagus simultaneously.',
        'Garnish with lemon slices before serving.'
      ],
      equipment: ['Grill Pan', 'Tongs'],
      kcal: 420,
      category: 'Japanese',
    ),
    _createStaticRecipe(
      'pn_3',
      'Cheese Omelet',
      'assets/images/recipe_omelet.png',
      5,
      5,
      ingredients: [
        _ri('Large Eggs', '3 units'),
        _ri('Cheddar Cheese', '1/4 cup shredded'),
        _ri('Butter', '1 tsp'),
        _ri('Chives', 'for garnish'),
      ],
      steps: [
        'Whisk eggs in a bowl with a pinch of salt.',
        'Melt butter in a non-stick pan over medium heat.',
        'Pour in eggs and let them set slightly.',
        'Sprinkle cheese over one half and fold.',
        'Cook for 1 more minute and serve.'
      ],
      equipment: ['Non-stick Pan', 'Whisk', 'Spatula'],
      kcal: 310,
      category: 'French',
    ),
    _createStaticRecipe(
      'pn_4',
      'Chicken Alfredo Pasta',
      'assets/images/recipe_pasta.png',
      10,
      20,
      ingredients: [
        _ri('Penne Pasta', '200g'),
        _ri('Grilled Chicken', '1 cup'),
        _ri('Alfredo Sauce', '1 jar'),
        _ri('Parsley', 'garnish'),
      ],
      steps: [
        'Boil pasta in salted water until tender.',
        'Heat alfredo sauce in a small pot.',
        'Combine pasta, chicken, and sauce in a large bowl.',
        'Toss well and garnish with fresh parsley.'
      ],
      equipment: ['Large Pot', 'Mixing Bowl'],
      kcal: 550,
      category: 'Italian',
    ),
    _createStaticRecipe('pn_5', 'Tacos', 'assets/images/others.png', 15, 15,
        category: 'Mexican'),
    _createStaticRecipe('pn_6', 'Fried Rice', 'assets/images/others.png', 10, 15,
        category: 'Chinese'),
  ];
}
