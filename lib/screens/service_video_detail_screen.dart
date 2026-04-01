import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:app_ecommerce/widgets/global_header.dart';
import 'package:app_ecommerce/models/service_video.dart';
import 'package:app_ecommerce/services/service_video_service.dart';
import 'package:video_player/video_player.dart';
import 'package:app_ecommerce/services/whatsapp_service.dart';
import 'package:app_ecommerce/utils/date_formatter.dart';
import 'package:app_ecommerce/services/auth_service.dart';
import 'package:app_ecommerce/widgets/login_modal.dart';

class ServiceVideoDetailScreen extends StatefulWidget {
  final ServiceVideo video;

  const ServiceVideoDetailScreen({super.key, required this.video});

  @override
  State<ServiceVideoDetailScreen> createState() =>
      _ServiceVideoDetailScreenState();
}

class _ServiceVideoDetailScreenState extends State<ServiceVideoDetailScreen> {
  VideoPlayerController? _videoController;
  bool _isPlaying = false;
  bool _isMuted = false;
  late List<ServiceVideoComment> _comments;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmittingComment = false;

  @override
  void initState() {
    super.initState();
    _comments = List.from(widget.video.comments);
    _initializeVideo();
    _incrementViewRecord();
  }

  Future<void> _initializeVideo() async {
    final url = widget.video.videoUrl;
    if (url.isNotEmpty) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoController!.initialize();
      _videoController!.addListener(() {
        if (mounted) {
          setState(() {
            _isPlaying = _videoController!.value.isPlaying;
          });
        }
      });
      // Auto-play
      _videoController!.play();
      setState(() {});
    }
  }

  void _incrementViewRecord() {
    ServiceVideoService.incrementViews(widget.video.id);
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    if (!AuthService().isLoggedIn.value) {
      LoginModal.show(context);
      return;
    }

    setState(() => _isSubmittingComment = true);
    final newComment = await ServiceVideoService.addComment(
      widget.video.id,
      text,
    );

    if (newComment != null && mounted) {
      setState(() {
        _comments.insert(0, newComment);
        _commentController.clear();
      });
    }

    if (mounted) {
      setState(() => _isSubmittingComment = false);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_videoController == null) return;
    if (_videoController!.value.isPlaying) {
      _videoController!.pause();
    } else {
      _videoController!.play();
    }
  }

  void _toggleMute() {
    if (_videoController == null) return;
    setState(() {
      _isMuted = !_isMuted;
      _videoController!.setVolume(_isMuted ? 0 : 1);
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final double ratingOrViews = (widget.video.views / 1000);
    final String viewsText = widget.video.views >= 1000
        ? '${ratingOrViews.toStringAsFixed(1)}k vues'
        : '${widget.video.views} vues';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Global Header
          GlobalHeader(onSearch: (query) {}),

          // Secondary Header: Back Button and Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: Color(0xFF1E2832),
                  ),
                ),
                const Text(
                  'Retour',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E2832),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Video Player
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      color: Colors.black,
                      child: Stack(
                        children: [
                          if (_videoController != null &&
                              _videoController!.value.isInitialized)
                            GestureDetector(
                              onTap: _togglePlayPause,
                              child: Center(
                                child: AspectRatio(
                                  aspectRatio:
                                      _videoController!.value.aspectRatio,
                                  child: VideoPlayer(_videoController!),
                                ),
                              ),
                            )
                          else
                            Positioned.fill(
                              child: Image.network(
                                widget.video.thumbnailUrl.isNotEmpty
                                    ? widget.video.thumbnailUrl
                                    : 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&q=80&w=2400',
                                fit: BoxFit.cover,
                              ),
                            ),

                          // Overlay Gradient
                          IgnorePointer(
                            child: Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.6),
                                      Colors.transparent,
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.8),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Top Controls Row
                          Positioned(
                            top: 15,
                            left: 15,
                            right: 15,
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 18,
                                  backgroundImage: NetworkImage(
                                    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.video.title,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Big Play Icon Layer over video
                          if (_videoController == null ||
                              !_videoController!.value.isInitialized)
                            const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          else if (!_isPlaying)
                            Center(
                              child: GestureDetector(
                                onTap: _togglePlayPause,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black45,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 80,
                                  ),
                                ),
                              ),
                            ),

                          // Bottom Controls Row
                          Positioned(
                            bottom: 15,
                            left: 15,
                            right: 15,
                            child: Column(
                              children: [
                                // Progress Bar
                                if (_videoController != null &&
                                    _videoController!.value.isInitialized)
                                  VideoProgressIndicator(
                                    _videoController!,
                                    allowScrubbing: true,
                                    colors: VideoProgressColors(
                                      playedColor: const Color(0xFFFF6F00),
                                      bufferedColor: Colors.white.withOpacity(
                                        0.5,
                                      ),
                                      backgroundColor: Colors.white.withOpacity(
                                        0.3,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: _togglePlayPause,
                                      child: Icon(
                                        _isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    GestureDetector(
                                      onTap: _toggleMute,
                                      child: Icon(
                                        _isMuted
                                            ? Icons.volume_off
                                            : Icons.volume_up,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      _videoController != null &&
                                              _videoController!
                                                  .value
                                                  .isInitialized
                                          ? '${_formatDuration(_videoController!.value.position)} / ${_formatDuration(_videoController!.value.duration)}'
                                          : '0:00 / 0:00',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.subtitles_outlined,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 15),
                                    const Icon(
                                      Icons.settings_outlined,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 15),
                                    const FaIcon(
                                      FontAwesomeIcons.youtube,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 15),
                                    const Icon(
                                      Icons.fullscreen,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // WhatsApp "Je suis intéressé" Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: GestureDetector(
                      onTap: () {
                        // Launch WhatsApp Service mapped to video interest
                        WhatsAppService.sendMessage(
                          "Bonjour, je suis intéressé par votre service: ${widget.video.title}. Pouvons-nous échanger ?",
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: const Color(0xFFEEEEEE)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.whatsapp,
                              color: Colors.green,
                              size: 30,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Je suis intéressé',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E2832),
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Video Title & Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.video.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E2832),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$viewsText • ${DateFormatter.formatTimeAgo(widget.video.createdAt)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          widget.video.description.isNotEmpty
                              ? widget.video.description
                              : 'Aucune description fournie pour ce service.',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF1E2832),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Comments Section Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6F8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Commentaires',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E2832),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_comments.length}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Add Comment Input
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 18,
                                backgroundImage: NetworkImage(
                                  'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100', // Mock Current User profile
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _commentController,
                                          style: const TextStyle(
                                            color: Color(0xFF1E2832),
                                            fontSize: 14,
                                          ),
                                          decoration: const InputDecoration(
                                            hintText:
                                                'Ajouter un commentaire...',
                                            hintStyle: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 13,
                                            ),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: _isSubmittingComment
                                            ? null
                                            : _submitComment,
                                        child: _isSubmittingComment
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Color(0xFFFF6F00),
                                                    ),
                                              )
                                            : const Icon(
                                                Icons.send_rounded,
                                                color: Color(0xFFFF6F00),
                                                size: 20,
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),
                          // List of Comments
                          if (_comments.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Text(
                                  'Soyez le premier à commenter !',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            )
                          else
                            ..._comments.map((comment) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: _buildCommentItem(
                                  comment.clientId,
                                  comment.content,
                                  DateFormatter.formatTimeAgo(
                                    comment.createdAt,
                                  ),
                                ),
                              );
                            }).toList(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Vidéos recommandées Section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      'Vidéos associées',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2832),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Horizontal Recommendations
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        _buildRecommendedVideo(
                          'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&q=80&w=600',
                        ),
                        const SizedBox(width: 15),
                        _buildRecommendedVideo(
                          'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?auto=format&fit=crop&q=80&w=600',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(String name, String text, String time) {
    if (name.length > 8)
      name = name.substring(0, 8) + '...'; // Truncate ID for fake username
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFFFF6F00).withOpacity(0.1),
          child: Text(
            name.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Color(0xFFFF6F00),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    time,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: const TextStyle(color: Color(0xFF1E2832), fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedVideo(String imageUrl) {
    return Container(
      width: 250,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: const Center(
        child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 50),
      ),
    );
  }
}
