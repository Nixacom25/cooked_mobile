import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../core/api_config.dart';

/// Ingredient art from the published catalog (`/public/ingredient-catalog/manifest`).
///
/// The manifest is cached on disk, so icons show offline and at startup; a newer published version replaces it
/// in the background. Names resolve like the backend does: normalized key, then aliases, then the longest catalog
/// name inside the ingredient name ("Fresh basil leaves" → Basil).
class IngredientCatalogService {
  static final IngredientCatalogService instance = IngredientCatalogService._();
  IngredientCatalogService._();

  /// Bumped when the catalog changes, so icons on screen rebuild.
  final ValueNotifier<int> revision = ValueNotifier(0);

  Map<String, String> _hashByKey = const {};
  Map<String, String> _art = const {};
  String? _genericSvg;
  int _version = 0;
  final Map<String, String?> _resolved = {};
  Future<void>? _loading;

  /// Words that are usually a unit or a second ingredient ("garlic cloves", "salt pork"), never preferred.
  static const _weak = {'clove', 'salt', 'sprig', 'stick', 'sheet', 'strip', 'water', 'ice'};

  /// Loads the cached catalog, then checks once per app run for a newer one. Safe to call often.
  Future<void> ensureLoaded() => _loading ??= _load();

  /// True once a catalog (cached or downloaded) is available.
  bool get isReady => _art.isNotEmpty;

  /// The catalog's generic ingredient drawing, used when a name matches no catalog ingredient.
  String? get genericSvg => _genericSvg;

  /// The SVG for this ingredient name, or null when the catalog has no art for it.
  String? svgFor(String name) {
    if (_art.isEmpty) return null;
    return _resolved.putIfAbsent(name, () {
      final hash = _hashFor(name);
      return hash == null ? null : _art[hash];
    });
  }

  Future<void> _load() async {
    final file = await _cacheFile();
    try {
      if (file != null && await file.exists()) _apply(await compute(_parse, await file.readAsString()));
    } catch (e) {
      debugPrint('Ingredient catalog cache unreadable: $e');
    }
    try {
      final res = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/public/ingredient-catalog/manifest'), headers: ApiConfig.clientHeaders)
          .timeout(const Duration(seconds: 30));
      if (res.statusCode != 200) return;
      final body = utf8.decode(res.bodyBytes);
      final parsed = await compute(_parse, body);
      if (parsed == null || parsed.version <= _version) return;
      _apply(parsed);
      await file?.writeAsString(body, flush: true);
    } catch (e) {
      debugPrint('Ingredient catalog not refreshed: $e');
      _loading = null; // offline: the next icon on screen tries again
    }
  }

  void _apply(_Catalog? c) {
    if (c == null) return;
    _hashByKey = c.hashByKey;
    _art = c.art;
    _genericSvg = c.genericHash == null ? null : c.art[c.genericHash];
    _version = c.version;
    _resolved.clear();
    revision.value++;
  }

  Future<File?> _cacheFile() async {
    try {
      return File('${(await getApplicationSupportDirectory()).path}/ingredient_catalog.json');
    } catch (_) {
      return null;
    }
  }

  String? _hashFor(String name) {
    final full = ingredientKey(name);
    final direct = _hashByKey[full];
    if (direct != null) return direct;
    // the ingredient itself, not "(or lemon juice, for the icing)"
    final head = ingredientKey(name.split(RegExp(r'[(,;:]')).first);
    for (final key in [if (head.isNotEmpty) head, full]) {
      final exact = _hashByKey[key];
      if (exact != null) return exact;
      final hit = _closest(key.split('_'));
      if (hit != null) return hit;
    }
    return null;
  }

  /// Longest catalog name found as consecutive words; ties go to the last one (the noun: "cilantro lime rice").
  String? _closest(List<String> tokens) {
    String? best;
    var bestScore = const [-1, -1, -1];
    _hashByKey.forEach((key, hash) {
      final words = key.split('_');
      final n = words.length;
      for (var end = tokens.length; end >= n; end--) {
        var match = true;
        for (var j = 0; j < n; j++) {
          if (tokens[end - n + j] != words[j]) {
            match = false;
            break;
          }
        }
        if (!match) continue;
        final score = [_weak.contains(key) ? 0 : 1, n, end];
        if (_better(score, bestScore)) {
          best = hash;
          bestScore = score;
        }
        break;
      }
    });
    return best;
  }

  static bool _better(List<int> a, List<int> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return a[i] > b[i];
    }
    return false;
  }
}

class _Catalog {
  final int version;
  final Map<String, String> hashByKey;
  final Map<String, String> art;
  final String? genericHash;
  const _Catalog(this.version, this.hashByKey, this.art, this.genericHash);
}

/// Runs in a background isolate: the manifest is a few MB.
_Catalog? _parse(String body) {
  final root = json.decode(body);
  if (root is! Map) return null;
  final art = <String, String>{};
  final rawArt = root['art'];
  if (rawArt is Map) rawArt.forEach((k, v) => art['$k'] = '$v');
  final fallback = root['fallback']?.toString();
  String? genericHash;
  final byKey = <String, String>{};
  for (final item in (root['ingredients'] as List? ?? const [])) {
    if (item is! Map) continue;
    final hash = item['hash']?.toString();
    if (hash == null) continue;
    if (fallback != null && item['id']?.toString() == fallback) genericHash = hash;
    if (!art.containsKey(hash) && item['svg'] is String) art[hash] = item['svg']; // format 1
    if (!art.containsKey(hash)) continue;
    for (final k in (item['keys'] as List? ?? const [])) {
      byKey.putIfAbsent('$k', () => hash);
    }
  }
  // The generic drawing is not a match for every name, but it replaces the emoji for unknown ones.
  if (fallback != null) genericHash ??= byKey.remove(fallback);
  byKey.removeWhere((_, h) => h == genericHash);
  return _Catalog((root['version'] as num?)?.toInt() ?? 0, byKey, art, genericHash);
}

/// Same normalization as the backend's IngredientKeys: case, accent and simple-plural insensitive.
String ingredientKey(String name) {
  final s = _stripAccents(name.trim().toLowerCase());
  final out = <String>[];
  for (final t in s.split(RegExp(r'[^a-z0-9]+'))) {
    if (t.isNotEmpty) out.add(_singular(t));
  }
  final k = out.join('_');
  return k.length > 120 ? k.substring(0, 120) : k;
}

String _singular(String t) {
  if (t.length <= 3 || !t.endsWith('s')) return t;
  if (t.endsWith('ss') || t.endsWith('us') || t.endsWith('is')) return t;
  if (t.endsWith('ies')) return '${t.substring(0, t.length - 3)}y';
  for (final e in const ['oes', 'ches', 'shes', 'xes', 'ses', 'zes']) {
    if (t.endsWith(e)) return t.substring(0, t.length - 2);
  }
  return t.substring(0, t.length - 1);
}

const _accents = {
  'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a', 'ç': 'c', 'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
  'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i', 'ñ': 'n', 'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', 'ù': 'u',
  'ú': 'u', 'û': 'u', 'ü': 'u', 'ý': 'y', 'ÿ': 'y', 'œ': 'oe', 'æ': 'ae',
};

String _stripAccents(String s) {
  final b = StringBuffer();
  for (final ch in s.split('')) {
    b.write(_accents[ch] ?? ch);
  }
  return b.toString();
}
