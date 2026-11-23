import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/ingredient_catalog_service.dart';

/// The catalog drawing of an ingredient (admin Ingredient Library, published manifest).
///
/// A name the catalog does not know gets the catalog's generic drawing; [fallback] (or [fallbackEmoji])
/// only shows while no catalog is available yet (first launch offline, nothing published).
class IngredientIcon extends StatefulWidget {
  final String name;
  final double size;
  final String fallbackEmoji;
  final Widget? fallback;

  const IngredientIcon({super.key, required this.name, required this.size, this.fallbackEmoji = '🥗', this.fallback});

  @override
  State<IngredientIcon> createState() => _IngredientIconState();
}

class _IngredientIconState extends State<IngredientIcon> {
  @override
  void initState() {
    super.initState();
    IngredientCatalogService.instance.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = IngredientCatalogService.instance;
    return ValueListenableBuilder<int>(
      valueListenable: catalog.revision,
      builder: (context, _, __) {
        final svg = catalog.svgFor(widget.name) ?? catalog.genericSvg;
        if (svg == null) {
          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: Center(
              child: widget.fallback ?? Text(widget.fallbackEmoji, style: TextStyle(fontSize: widget.size * 0.8, height: 1)),
            ),
          );
        }
        return SvgPicture.string(
          svg,
          key: ValueKey(svg.hashCode),
          width: widget.size,
          height: widget.size,
          placeholderBuilder: (_) => SizedBox(width: widget.size, height: widget.size),
        );
      },
    );
  }
}
