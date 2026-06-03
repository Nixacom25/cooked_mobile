library;

import 'package:flutter/widgets.dart';

/// [IconData] for a font awesome brand icon from a code point
///
/// Code points can be obtained from fontawesome.com
class IconDataBrands implements IconData {
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

  const IconDataBrands(this.codePoint)
      : fontFamily = 'FontAwesomeBrands',
        fontPackage = 'font_awesome_flutter',
        matchTextDirection = false,
        fontFamilyFallback = null;
}

/// [IconData] for a font awesome solid icon from a code point
///
/// Code points can be obtained from fontawesome.com
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

/// [IconData] for a font awesome regular icon from a code point
///
/// Code points can be obtained from fontawesome.com
class IconDataRegular implements IconData {
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

  const IconDataRegular(this.codePoint)
      : fontFamily = 'FontAwesomeRegular',
        fontPackage = 'font_awesome_flutter',
        matchTextDirection = false,
        fontFamilyFallback = null;
}

/// [IconData] for a font awesome light icon from a code point. Only works if
/// light icons (font awesome pro) have been installed.
///
/// Code points can be obtained from fontawesome.com
class IconDataLight implements IconData {
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

  const IconDataLight(this.codePoint)
      : fontFamily = 'FontAwesomeLight',
        fontPackage = 'font_awesome_flutter',
        matchTextDirection = false,
        fontFamilyFallback = null;
}

/// [IconData] for a font awesome duotone icon from a code point. Only works if
/// duotone icons (font awesome pro) have been installed.
///
/// Code points can be obtained from fontawesome.com. Each duotone icon consists
/// of a primary [codePoint] and a [secondary].
class IconDataDuotone implements IconData {
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

  /// Secondary glyph of the duotone icon
  ///
  /// Due to tree-shaking restraints [secondary] cannot be the codepoint itself,
  /// but has to be an [IconData] object.
  final IconData? secondary;

  const IconDataDuotone(this.codePoint, {this.secondary})
      : fontFamily = 'FontAwesomeDuotone',
        fontPackage = 'font_awesome_flutter',
        matchTextDirection = false,
        fontFamilyFallback = null;
}

/// [IconData] for a font awesome thin icon from a code point. Only works if
/// thin icons (font awesome pro, v6+) have been installed.
///
/// Code points can be obtained from fontawesome.com
class IconDataThin implements IconData {
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

  const IconDataThin(this.codePoint)
      : fontFamily = 'FontAwesomeThin',
        fontPackage = 'font_awesome_flutter',
        matchTextDirection = false,
        fontFamilyFallback = null;
}

/// [IconData] for a font awesome sharp thin icon from a code point. Only works if
/// thin icons (font awesome pro, v6+) have been installed.
///
/// Code points can be obtained from fontawesome.com
class IconDataSharpThin implements IconData {
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

  const IconDataSharpThin(this.codePoint)
      : fontFamily = 'FontAwesomeSharpThin',
        fontPackage = 'font_awesome_flutter',
        matchTextDirection = false,
        fontFamilyFallback = null;
}

/// [IconData] for a font awesome sharp light icon from a code point. Only works if
/// thin icons (font awesome pro, v6+) have been installed.
///
/// Code points can be obtained from fontawesome.com
class IconDataSharpLight implements IconData {
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

  const IconDataSharpLight(this.codePoint)
      : fontFamily = 'FontAwesomeSharpLight',
        fontPackage = 'font_awesome_flutter',
        matchTextDirection = false,
        fontFamilyFallback = null;
}

/// [IconData] for a font awesome sharp regular icon from a code point. Only works if
/// thin icons (font awesome pro, v6+) have been installed.
///
/// Code points can be obtained from fontawesome.com
class IconDataSharpRegular implements IconData {
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

  const IconDataSharpRegular(this.codePoint)
      : fontFamily = 'FontAwesomeSharpRegular',
        fontPackage = 'font_awesome_flutter',
        matchTextDirection = false,
        fontFamilyFallback = null;
}

/// [IconData] for a font awesome sharp solid icon from a code point. Only works if
/// thin icons (font awesome pro, v6+) have been installed.
///
/// Code points can be obtained from fontawesome.com
class IconDataSharpSolid implements IconData {
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

  const IconDataSharpSolid(this.codePoint)
      : fontFamily = 'FontAwesomeSharpSolid',
        fontPackage = 'font_awesome_flutter',
        matchTextDirection = false,
        fontFamilyFallback = null;
}
