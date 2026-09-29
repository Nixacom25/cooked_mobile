import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'motion.dart';
import 'skeleton.dart';

/// Network image that crossfades in over its skeleton: the placeholder
/// stays underneath and is only covered once the image has rendered
/// (opacity 0 → 1, ~250 ms). Already-cached images show instantly.
class ImageCrossfade extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget Function(BuildContext context)? errorBuilder;
  final int? memCacheWidth;
  final Alignment alignment;

  const ImageCrossfade({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholder,
    this.errorBuilder,
    this.memCacheWidth,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final base = placeholder ??
        SkeletonBox(
          width: width,
          height: height,
          borderRadius: borderRadius ?? BorderRadius.zero,
        );
    Widget image = CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      alignment: alignment,
      memCacheWidth: memCacheWidth,
      fadeInDuration: Motion.of(context, const Duration(milliseconds: 250)),
      fadeOutDuration: Duration.zero,
      fadeInCurve: Motion.enter,
      placeholder: (context, _) => base,
      errorWidget: (context, _, __) =>
          errorBuilder?.call(context) ?? base,
    );
    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}
