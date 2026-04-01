import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app_ecommerce/widgets/global_header.dart';
import 'package:app_ecommerce/services/testimonial_service.dart';
import 'package:app_ecommerce/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ReviewFormScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const ReviewFormScreen({super.key, required this.order});

  @override
  State<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends State<ReviewFormScreen> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  File? _selectedFile;
  bool _isSubmitting = false;

  // Audio Recording states
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _audioPath;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile.path);
        _audioPath = null; // Clear audio if image/video is picked
      });
    }
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile.path);
        _audioPath = null;
      });
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _audioPath = path;
        if (path != null) {
          _selectedFile = File(path);
        }
      });
    } else {
      if (await Permission.microphone.request().isGranted) {
        final dir = await getTemporaryDirectory();
        final path =
            '${dir.path}/review_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        const config = RecordConfig(); // Default config
        await _audioRecorder.start(config, path: path);
        setState(() {
          _isRecording = true;
          _selectedFile = null;
          _audioPath = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission micro refusée.')),
        );
      }
    }
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez donner une note.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = AuthService().currentUser.value;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final Map<String, dynamic> data = {
        'clientId': user['id']?.toString() ?? 'unknown',
        'orderId': widget.order['id'].toString(),
        'content': _commentController.text,
        'rating': _rating,
        // mediaType is now detected by backend, so we pass a placeholder or null
      };

      await TestimonialService.createTestimonial(data, _selectedFile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Merci pour votre avis ! Il sera visible après modération.',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur lors de l\'envoi : $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> itemsList = widget.order['items'].split(', ');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          // Persist GlobalHeader
          GlobalHeader(
            onSearch: (query) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),

          // Sub-Header: Back Button and Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: Color(0xFF1E2832),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                const Text(
                  'Donner mon avis',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2832),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Order Summary Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Commande ${widget.order['id']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF1E2832),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.order['date'],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...itemsList.map(
                          (item) => Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '1x $item',
                              style: const TextStyle(
                                color: Color(0xFF4B5563),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Review Form Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notez votre expérience',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF1E2832),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _rating = index + 1;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                child: Icon(
                                  index < _rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 45,
                                  color: index < _rating
                                      ? const Color(0xFFFACC15)
                                      : Colors.grey[300],
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 30),

                        const Text(
                          'Votre commentaire',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF1E2832),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _commentController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText:
                                'Partagez votre expérience avec ces produits...',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8F9FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(15),
                          ),
                        ),
                        const SizedBox(height: 25),

                        const Text(
                          'Ajouter un média (Facultatif)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF1E2832),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _MediaOption(
                              label: 'Photo',
                              icon: Icons.camera_alt_outlined,
                              onTap: _pickImage,
                              isSelected:
                                  _selectedFile != null &&
                                  _audioPath == null &&
                                  !_selectedFile!.path.endsWith('.mp4'),
                            ),
                            const SizedBox(width: 12),
                            _MediaOption(
                              label: 'Vidéo',
                              icon: Icons.videocam_outlined,
                              onTap: _pickVideo,
                              isSelected:
                                  _selectedFile != null &&
                                  _selectedFile!.path.endsWith('.mp4'),
                            ),
                            const SizedBox(width: 12),
                            _MediaOption(
                              label: _isRecording ? 'Arrêter' : 'Audio',
                              icon: _isRecording
                                  ? Icons.stop_circle_outlined
                                  : Icons.mic_none_outlined,
                              onTap: _toggleRecording,
                              isSelected: _audioPath != null || _isRecording,
                              isRecording: _isRecording,
                            ),
                          ],
                        ),
                        if (_selectedFile != null || _isRecording) ...[
                          const SizedBox(height: 15),
                          if (_selectedFile != null &&
                              !_selectedFile!.path.endsWith('.m4a'))
                            Container(
                              height: 200,
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _selectedFile!.path.endsWith('.mp4')
                                    ? Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          const Icon(
                                            Icons.videocam,
                                            size: 50,
                                            color: Colors.grey,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            color: Colors.black.withOpacity(
                                              0.3,
                                            ),
                                            child: const Text(
                                              'Aperçu vidéo disponible après envoi',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Image.file(
                                        _selectedFile!,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _isRecording
                                      ? Icons.mic
                                      : (_audioPath != null
                                            ? Icons.audiotrack
                                            : (_selectedFile!.path.endsWith(
                                                    '.mp4',
                                                  )
                                                  ? Icons.videocam
                                                  : Icons.image)),
                                  color: _isRecording
                                      ? Colors.red
                                      : const Color(0xFFFF6F00),
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _isRecording
                                        ? 'Enregistrement en cours...'
                                        : (_audioPath != null
                                              ? 'Audio enregistré'
                                              : (_selectedFile!.path.endsWith(
                                                      '.mp4',
                                                    )
                                                    ? 'Vidéo sélectionnée'
                                                    : 'Photo sélectionnée')),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _isRecording
                                          ? Colors.red
                                          : const Color(0xFF4B5563),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (!_isRecording)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedFile = null;
                                        _audioPath = null;
                                      });
                                    },
                                    child: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitReview,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6F00),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'ENVOYER MON AVIS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 1,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isRecording;

  const _MediaOption({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isSelected = false,
    this.isRecording = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6F00) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF6F00) : Colors.grey[300]!,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF6F00).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
