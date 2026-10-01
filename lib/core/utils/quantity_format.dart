/// Display helpers for grocery quantities.
///
/// When the same ingredient is added several times (e.g. the same recipe
/// added twice), the backend joins the quantities: "1 /4 tsp + 1 /4 tsp".
/// [summarizeQuantity] shows the total instead ("1/2 tsp") when every part
/// is a number with the same unit; otherwise the text is kept as-is (never
/// guess a wrong amount).
String summarizeQuantity(String raw) {
  final cleaned = raw
      .replaceAll('*', '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll(RegExp(r'\s+,'), ',')
      .replaceAll(RegExp(r'^[\s,+]+|[\s,+]+$'), '')
      .trim();
  final parts = cleaned.split('+').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
  if (parts.length < 2) return cleaned;

  double total = 0;
  String? unit;
  for (final part in parts) {
    final parsed = _parse(part);
    // A unit that itself holds numbers ("mL (2 tbsp)") can't be summed safely.
    if (parsed == null || RegExp(r'\d').hasMatch(parsed.unit)) return cleaned;
    if (unit == null) {
      unit = parsed.unit;
    } else if (unit.toLowerCase() != parsed.unit.toLowerCase()) {
      return cleaned;
    }
    total += parsed.value;
  }
  final amount = _format(total);
  return unit!.isEmpty ? amount : '$amount $unit';
}

({double value, String unit})? _parse(String part) {
  final mixed = RegExp(r'^(\d+)\s+(\d+)\s*/\s*(\d+)\s*(.*)$').firstMatch(part);
  if (mixed != null) {
    final den = int.parse(mixed.group(3)!);
    if (den == 0) return null;
    return (
      value: int.parse(mixed.group(1)!) + int.parse(mixed.group(2)!) / den,
      unit: mixed.group(4)!.trim(),
    );
  }
  final frac = RegExp(r'^(\d+)\s*/\s*(\d+)\s*(.*)$').firstMatch(part);
  if (frac != null) {
    final den = int.parse(frac.group(2)!);
    if (den == 0) return null;
    return (value: int.parse(frac.group(1)!) / den, unit: frac.group(3)!.trim());
  }
  final dec = RegExp(r'^(\d+(?:[.,]\d+)?)\s*(.*)$').firstMatch(part);
  if (dec != null) {
    return (
      value: double.parse(dec.group(1)!.replaceAll(',', '.')),
      unit: dec.group(2)!.trim(),
    );
  }
  return null;
}

String _format(double v) {
  final whole = v.floor();
  final rest = v - whole;
  final fractions = <double, String>{0.25: '1/4', 1 / 3: '1/3', 0.5: '1/2', 2 / 3: '2/3', 0.75: '3/4'};
  if (rest < 0.02) return '$whole';
  if (rest > 0.98) return '${whole + 1}';
  for (final entry in fractions.entries) {
    if ((rest - entry.key).abs() < 0.02) {
      return whole == 0 ? entry.value : '$whole ${entry.value}';
    }
  }
  final s = v.toStringAsFixed(2);
  return s.replaceAll(RegExp(r'\.?0+$'), '');
}
