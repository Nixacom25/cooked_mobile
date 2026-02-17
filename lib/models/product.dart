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
      mediaList = List<String>.from(json['media']);
    }

    List<String> videos = [];
    String? thumb;
    List<String> imgs = [];

    // Simple media sorting logic
    for (var m in mediaList) {
      if (m.endsWith('.mp4') || m.endsWith('.m3u8')) {
        videos.add(m);
      } else {
        imgs.add(m);
        if (thumb == null) thumb = m;
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
    );
  }
}
