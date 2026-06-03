import 'package:flutter/widgets.dart';

class IconDataSolid implements IconData {
  @override
  final int codePoint;
  @override
  final String? fontFamily;
  @override
  final String? fontPackage;
  @override
  final bool matchTextDirection;
  
  @override
  final List<String>? fontFamilyFallback;

  const IconDataSolid(this.codePoint)
      : fontFamily = 'FontAwesomeSolid',
        fontPackage = 'font_awesome_flutter',
        matchTextDirection = false,
        fontFamilyFallback = null;
}
