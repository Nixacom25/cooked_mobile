import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_ecommerce/services/cloudinary_service.dart';
import 'package:app_ecommerce/utils/cloudinary_config.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _videoFile;
  bool _isUploading = false;
  String? _uploadedPublicId;
  String? _errorMessage;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _videoFile = File(video.path);
        _uploadedPublicId = null; // Reset previous upload
        _errorMessage = null;
      });
    }
  }

  Future<void> _uploadVideo() async {
    if (_videoFile == null) return;

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    final publicId = await CloudinaryService.uploadVideo(_videoFile!);

    if (mounted) {
      setState(() {
        _isUploading = false;
        if (publicId != null) {
          _uploadedPublicId = publicId;
        } else {
          _errorMessage = "Upload failed. Check console for details.";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Video POC')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Step 1: Pick Video
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickVideo,
              icon: const Icon(Icons.video_library),
              label: const Text('Select Video from Gallery'),
            ),
            const SizedBox(height: 16),

            if (_videoFile != null) ...[
              Text('Selected: ${_videoFile!.path.split('/').last}'),
              const SizedBox(height: 16),

              // Step 2: Upload
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _uploadVideo,
                icon: const Icon(Icons.cloud_upload),
                label: _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Upload to Cloudinary'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ],

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ],

            const SizedBox(height: 24),

            // Step 3: Result Preview
            if (_uploadedPublicId != null) ...[
              const Divider(),
              const Text(
                'Upload Success! HLS Ready:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              SelectableText(
                'ID: $_uploadedPublicId\n'
                'HLS: ${CloudinaryConfig.getHlsUrl(_uploadedPublicId!)}',
              ),
              const SizedBox(height: 16),
              const Text('Preview (HLS Stream):'),
              const SizedBox(height: 8),
              AspectRatio(
                aspectRatio: 9 / 16,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    color: Colors.black87,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.play_circle_outline,
                          color: Colors.white54,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Video uploaded!\nID: $_uploadedPublicId',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
