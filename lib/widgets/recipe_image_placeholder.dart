import 'package:flutter/material.dart';

class RecipeImagePlaceholder extends StatelessWidget {
  const RecipeImagePlaceholder({super.key, this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placeholder = ColoredBox(
      color: isDark ? const Color(0xFF2D2A26) : const Color(0xFFF4EFE5),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 30,
          color: isDark ? const Color(0xFFAAA197) : const Color(0xFFA49A8B),
        ),
      ),
    );
    if (width == null && height == null) {
      return SizedBox.expand(child: placeholder);
    }
    return SizedBox(width: width, height: height, child: placeholder);
  }
}
