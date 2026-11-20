import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/ingredient_catalog_service.dart';

/// The catalog drawing of an ingredient, or [fallbackEmoji] while the catalog has none for it.
class IngredientIcon extends StatefulWidget {
  final String name;
  final double size;
  final String fallbackEmoji;

  const IngredientIcon({super.key, required this.name, required this.size, this.fallbackEmoji = '🥗'});

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
        final svg = catalog.svgFor(widget.name);
        if (svg == null) {
          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: Center(child: Text(widget.fallbackEmoji, style: TextStyle(fontSize: widget.size * 0.8, height: 1))),
          );
        }
        return SvgPicture.string(
          svg,
          width: widget.size,
          height: widget.size,
          placeholderBuilder: (_) => SizedBox(width: widget.size, height: widget.size),
        );
      },
    );
  }
}
