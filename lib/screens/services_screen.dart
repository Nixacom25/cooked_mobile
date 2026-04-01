import 'package:flutter/material.dart';
import 'package:app_ecommerce/screens/service_category_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:app_ecommerce/services/whatsapp_service.dart';
import 'package:app_ecommerce/models/service_video.dart';
import 'package:app_ecommerce/services/service_video_service.dart';
import 'package:app_ecommerce/screens/service_video_detail_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  late Future<List<ServiceVideo>> _presentationsFuture;

  @override
  void initState() {
    super.initState();
    _presentationsFuture = ServiceVideoService.getVideos(
      type: 'COMPANY_PRESENTATION',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8), // #f5f6f8
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Presentation Title
            const Text(
              'Présentation',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2832),
              ),
            ),
            const SizedBox(height: 20),

            FutureBuilder<List<ServiceVideo>>(
              future: _presentationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF6F00),
                      ),
                    ),
                  );
                }

                final videos = snapshot.data ?? [];
                final pinnedVideo = videos.cast<ServiceVideo?>().firstWhere(
                  (v) => v!.isPinned,
                  orElse: () => null,
                );
                final otherVideos = videos.where((v) => !v.isPinned).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Laptop Video Presentation Card (Pinned)
                    GestureDetector(
                      onTap: () {
                        if (pinnedVideo != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ServiceVideoDetailScreen(video: pinnedVideo),
                            ),
                          );
                        }
                      },
                      child: Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.network(
                                  pinnedVideo?.thumbnailUrl ??
                                      'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&q=80&w=2426',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(color: Colors.grey[800]),
                                ),
                              ),
                              Container(color: Colors.black.withOpacity(0.2)),
                              Center(
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white.withOpacity(0.9),
                                  size: 80,
                                ),
                              ),
                              if (pinnedVideo != null)
                                Positioned(
                                  bottom: 15,
                                  left: 15,
                                  right: 15,
                                  child: Text(
                                    pinnedVideo.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black54,
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Subtitle
                    const Text(
                      'Découvrez notre boutique et nos meilleurs produits',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2832),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // WhatsApp Button
                    GestureDetector(
                      onTap: () {
                        WhatsAppService.sendMessage(
                          "Bonjour, je suis intéressé par votre boutique et vos produits. Pouvons-nous échanger ?",
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.whatsapp,
                              color: Colors.green,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Je suis intéressé',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E2832),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Service Category Cards Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildServiceCard(
                            context,
                            'Trouvez un technicien',
                            'TECHNICIAN',
                            Icons.handyman_outlined,
                            const Color(0xFFFF6F00),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildServiceCard(
                            context,
                            'Utilisation produit',
                            'PRODUCT_USAGE',
                            Icons.menu_book_outlined,
                            const Color(0xFFFF6F00),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildServiceCard(
                            context,
                            'Vlog clients',
                            'VLOG',
                            Icons.videocam_outlined,
                            const Color(0xFFFF6F00),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Presentations List
                    if (otherVideos.isNotEmpty) ...[
                      const Text(
                        'Nos présentations',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E2832),
                        ),
                      ),
                      const SizedBox(height: 15),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: otherVideos.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 15),
                        itemBuilder: (context, index) {
                          final video = otherVideos[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ServiceVideoDetailScreen(video: video),
                                ),
                              );
                            },
                            child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: const Color(0xFFEEEEEE),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      bottomLeft: Radius.circular(15),
                                    ),
                                    child: SizedBox(
                                      width: 120,
                                      height: 100,
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: Image.network(
                                              video.thumbnailUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Container(
                                                    color: Colors.grey[800],
                                                  ),
                                            ),
                                          ),
                                          const Center(
                                            child: Icon(
                                              Icons.play_circle_fill,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            video.title,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E2832),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.remove_red_eye,
                                                size: 12,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${video.views} vues',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    String title,
    String type,
    IconData icon,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ServiceCategoryScreen(title: title, type: type),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2832),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
