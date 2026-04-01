import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UrlSanitizer {
  static bool isNetwork(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }

  static bool isLocal(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.startsWith('temp:') ||
        url.startsWith('/') ||
        url.startsWith('file://');
  }

  static String? sanitize(String? url) {
    if (url == null || url.isEmpty) return null;
    return url;
  }

  static String getCleanPath(String url) {
    if (url.startsWith('temp:')) return url.replaceFirst('temp:', '');
    if (url.startsWith('file://')) return url.replaceFirst('file://', '');
    return url;
  }

  static ImageProvider buildImageProvider(String? url) {
    if (url == null || url.isEmpty || (!isNetwork(url) && !isLocal(url))) {
      return const AssetImage('assets/images/placeholder.png'); // Fallback
    }

    if (isNetwork(url)) {
      return CachedNetworkImageProvider(url);
    } else {
      return FileImage(File(getCleanPath(url)));
    }
  }

  static Widget buildImage(
    String? url, {
    BoxFit fit = BoxFit.cover,
    Widget? errorWidget,
  }) {
    if (url == null || url.isEmpty) {
      return errorWidget ??
          const Icon(Icons.image_not_supported, color: Colors.white24);
    }

    if (isNetwork(url)) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        placeholder: (context, url) => const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) =>
            errorWidget ??
            const Icon(Icons.broken_image, color: Colors.white24),
      );
    } else if (isLocal(url)) {
      final path = getCleanPath(url);
      final file = File(path);
      return Image.file(
        file,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ??
            const Icon(Icons.broken_image, color: Colors.white24),
      );
    }

    return errorWidget ?? const Icon(Icons.broken_image, color: Colors.white24);
  }
}
