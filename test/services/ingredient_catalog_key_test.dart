import 'package:cooked/services/ingredient_catalog_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ingredient keys match the backend IngredientKeys normalization', () {
    const expected = {
      'Green Onions': 'green_onion',
      'Nététou': 'netetou',
      'Baby carrots': 'baby_carrot',
      'Cherries': 'cherry',
      'Tomatoes': 'tomato',
      'Glass': 'glass',
      'Cilantro, chopped': 'cilantro_chopped',
      'Crème fraîche': 'creme_fraiche',
      'Peaches': 'peach',
    };
    expected.forEach((name, key) => expect(ingredientKey(name), key, reason: name));
  });
}
