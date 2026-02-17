class CloudinaryConfig {
  static const String cloudName = 'dh7pcxi5q';
  static const String apiKey = '583146936248515';
  static const String apiSecret = 'kvidfY-oTsYCElli-oN6Q2TiMXQ';
  static const String uploadPreset = 'ecommerce_preset';

  // Helper to generate HLS URL
  static String getHlsUrl(String publicId) {
    return 'https://res.cloudinary.com/$cloudName/video/upload/sp_hd/v1/$publicId.m3u8';
  }

  // Helper to generate Thumbnail URL
  static String getThumbnailUrl(String publicId) {
    return 'https://res.cloudinary.com/$cloudName/video/upload/so_0,w_400/v1/$publicId.jpg';
  }
}
