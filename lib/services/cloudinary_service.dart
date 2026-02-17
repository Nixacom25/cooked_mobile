import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:app_ecommerce/utils/cloudinary_config.dart';

class CloudinaryService {
  static Future<String?> uploadVideo(File videoFile) async {
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/auto/upload',
    );

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', videoFile.path));

    try {
      final streamAddResponse = await request.send();
      final response = await http.Response.fromStream(streamAddResponse);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        // We return the public_id, so the app can construct HLS/Thumbnail URLs dynamically
        return jsonResponse['public_id'];
      } else {
        print(
          'Cloudinary Upload Failed: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      return null;
    }
  }
}
