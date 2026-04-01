import 'package:app_ecommerce/utils/url_sanitizer.dart';

class Product {
  final String id;
  final String title;
  final String price; // Current price e.g. "21,000 FCFA"
  final List<String>
  videoUrls; // ⚠️ NE PAS TOUCHER - Utilisé par GlobalVideoCache
  final String category;
  final String? thumbnailUrl;
  final String? originalPrice; // Original price if on promo e.g. "42,000 FCFA"
  final String? promoLabel; // Promo badge text e.g. "BOGO", "-50%"

  // ✨ NEW FIELDS - Client requirements
  final String description; // Full product description
  final int deliveryFee; // Delivery fee in FCFA
  final bool hasInstallationOption; // Can user choose installation?
  final int installationFee; // Installation fee in FCFA (0 if not available)
  final List<String> keywords; // For search functionality
  final List<String> images; // Additional images for stories/status
  final int stock; // Current stock inventory
  final int commentCount; // Total number of approved comments
  final int shareCount; // Total number of shares to external networks

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.videoUrls,
    required this.category,
    this.thumbnailUrl,
    this.originalPrice,
    this.promoLabel,
    // New required fields
    this.description = '',
    this.deliveryFee = 0,
    this.hasInstallationOption = false,
    this.installationFee = 0,
    this.keywords = const [],
    this.images = const [],
    this.stock = 0,
    this.commentCount = 0,
    this.shareCount = 0,
  });

  // Getter for backward compatibility
  String get videoUrl => videoUrls.isNotEmpty ? videoUrls.first : '';

  // Helper to get numeric price (remove FCFA and commas)
  int get numericPrice {
    return int.tryParse(price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  // Helper to get numeric original price
  int? get numericOriginalPrice {
    if (originalPrice == null) return null;
    return int.tryParse(originalPrice!.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    // Extract media
    List<String> mediaList = [];
    if (json['media'] != null) {
      if (json['media'] is List) {
        for (var item in json['media']) {
          if (item is String) {
            mediaList.add(item);
          } else if (item is Map<String, dynamic>) {
            final url = item['url'] ?? item['mediaUrl'];
            if (url != null) mediaList.add(url.toString());
          }
        }
      }
    }

    List<String> videos = [];
    String? thumb;
    List<String> imgs = [];

    // Simple media sorting logic
    for (var m in mediaList) {
      final sanitized = UrlSanitizer.sanitize(m);
      if (sanitized == null) continue;

      if (sanitized.endsWith('.mp4') || sanitized.endsWith('.m3u8')) {
        videos.add(sanitized);
      } else {
        imgs.add(sanitized);
        if (thumb == null) thumb = sanitized;
      }
    }

    // Price formatting
    final double? priceVal = json['price'] != null
        ? (json['price'] is int
              ? (json['price'] as int).toDouble()
              : json['price'])
        : 0.0;
    final String formattedPrice = "${priceVal?.toStringAsFixed(0) ?? '0'} FCFA";

    // Promo logic
    final bool isPromo = json['is_promo'] ?? false;
    final double? promoPriceVal = json['promo_price'] != null
        ? (json['promo_price'] is int
              ? (json['promo_price'] as int).toDouble()
              : json['promo_price'])
        : null;

    String? originalPriceStr;
    String currentPriceStr = formattedPrice;
    String? promoLabelStr;

    if (isPromo && promoPriceVal != null) {
      originalPriceStr = formattedPrice;
      currentPriceStr = "${promoPriceVal.toStringAsFixed(0)} FCFA";
      // Calculate discount percentage
      if (priceVal != null && priceVal > 0) {
        final discount = ((priceVal - promoPriceVal) / priceVal * 100).round();
        promoLabelStr = "-$discount%";
      } else {
        promoLabelStr = "PROMO";
      }
    }

    // Category extraction
    String cat = 'General';
    if (json['category'] != null) {
      if (json['category'] is String) {
        cat = json['category'];
      } else if (json['category'] is Map) {
        cat = json['category']['name'] ?? 'General';
      }
    } else if (json['category_id'] != null) {
      // If only ID is provided, use ID or fetch name elsewhere. Using ID as fallback.
      cat = json['category_id'];
    }

    return Product(
      id: json['id'] ?? '',
      title: json['name'] ?? 'No Name',
      description: json['description'] ?? '',
      price: currentPriceStr,
      videoUrls: videos,
      category: cat,
      thumbnailUrl: thumb ?? (imgs.isNotEmpty ? imgs.first : null),
      originalPrice: originalPriceStr,
      promoLabel: promoLabelStr,
      // Map requires_assembly from backend
      hasInstallationOption:
          json['requires_assembly'] ?? json['requiresAssembly'] ?? false,
      deliveryFee:
          3000, // Standard delivery fee as per current validation screen
      installationFee: 5000, // Default installation fee if applicable
      keywords: [],
      images: imgs,
      stock: json['quantity'] ?? 0,
      commentCount: json['comment_count'] ?? json['commentCount'] ?? 0,
      shareCount: json['share_count'] ?? json['shareCount'] ?? 0,
    );
  }

  Product copyWith({int? shareCount, int? commentCount, int? stock}) {
    return Product(
      id: id,
      title: title,
      price: price,
      videoUrls: videoUrls,
      category: category,
      thumbnailUrl: thumbnailUrl,
      originalPrice: originalPrice,
      promoLabel: promoLabel,
      description: description,
      deliveryFee: deliveryFee,
      hasInstallationOption: hasInstallationOption,
      installationFee: installationFee,
      keywords: keywords,
      images: images,
      stock: stock ?? this.stock,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
    );
  }
}

class ProductComment {
  final String id;
  final String clientId;
  final String content;
  final String createdAt;

  ProductComment({
    required this.id,
    required this.clientId,
    required this.content,
    required this.createdAt,
  });

  factory ProductComment.fromJson(Map<String, dynamic> json) {
    return ProductComment(
      id: json['id'] ?? '',
      clientId: json['client_id'] ?? json['clientId'] ?? 'Anonyme',
      content: json['content'] ?? '',
      createdAt: json['created_at'] ?? json['createdAt'] ?? '',
    );
  }
}
