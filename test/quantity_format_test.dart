import 'package:cooked/core/utils/quantity_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sums parts that share a unit', () {
    expect(summarizeQuantity('1 /4 tsp + 1 /4 tsp + 1 /4 tsp'), '3/4 tsp');
    expect(summarizeQuantity('1/4 tsp + 1/4 tsp'), '1/2 tsp');
    expect(summarizeQuantity('250 g + 250 g'), '500 g');
    expect(summarizeQuantity('1 1/2 cup + 1/2 cup'), '2 cup');
    expect(summarizeQuantity('3 + 3'), '6');
  });

  test('keeps text when parts differ or are not numbers', () {
    expect(summarizeQuantity('16 g (1 tbsp), *optional* + 15 g (1 tbsp)'),
        '16 g (1 tbsp), optional + 15 g (1 tbsp)');
    expect(summarizeQuantity('1 cup + 2 tbsp'), '1 cup + 2 tbsp');
    expect(summarizeQuantity('223 g (1 Cup)'), '223 g (1 Cup)');
    expect(summarizeQuantity('30 mL (2 tbsp) + 30 mL (2 tbsp)'), '30 mL (2 tbsp) + 30 mL (2 tbsp)');
  });
}
