import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/constants.dart';

class PromoDetailPage extends StatelessWidget {
  final Map promo;

  const PromoDetailPage({super.key, required this.promo});

  @override
  Widget build(BuildContext context) {
    final imageUrl = promo['banner'] != null
        ? "${AppConfig.baseUrl}/media/${promo['banner']}"
        : null;

    final isExpired =
        promo['end_date'] != null &&
        DateTime.parse(promo['end_date']).isBefore(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: CustomScrollView(
        slivers: [
          // ===========================
          // 🖼️ APP BAR + BANNER
          // ===========================
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: const Color(0xFF1F3C88),
            foregroundColor: Colors.white,
            title: const Text("Detail Promo"),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // ===========================
                  // 🖼️ IMAGE
                  // ===========================
                  if (imageUrl != null)
                    Hero(
                      tag: "promo-image-$imageUrl",
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 80,
                      ),
                    ),

                  // ===========================
                  // 🌗 GRADIENT (NO TAP BLOCK)
                  // ===========================
                  IgnorePointer(
                    ignoring: true,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.15),
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ===========================
                  // 🏷️ STATUS CHIP (LEFT)
                  // ===========================
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: _StatusChip(isExpired: isExpired),
                  ),

                  // ===========================
                  // 🔍 FLOATING PREVIEW BUTTON
                  // ===========================
                  if (imageUrl != null)
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: FloatingActionButton.small(
                        heroTag: "preview-btn-$imageUrl",
                        backgroundColor: Colors.black.withOpacity(0.75),
                        elevation: 8,
                        tooltip: "Preview Gambar",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  FullScreenImagePage(imageUrl: imageUrl),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.fullscreen,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ===========================
          // 📄 CONTENT
          // ===========================
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE
                  Text(
                    promo['title'] ?? "-",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // DATE RANGE
                  Row(
                    children: [
                      const Icon(Icons.date_range, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        _formatDateRange(
                          promo['start_date'],
                          promo['end_date'],
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // DESCRIPTION
                  const Text(
                    "Deskripsi Promo",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    promo['description'] ?? "Tidak ada deskripsi promo",
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.7,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.justify,
                  ),

                  const SizedBox(height: 36),

                  // SHARE BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _shareWhatsApp,
                      icon: const Icon(
                        LucideIcons.send,
                        size: 20,
                        color: Colors.white,
                      ),
                      label: const Text("Bagikan via WhatsApp"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 3,
                      ),
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

  // ===========================
  // 📅 DATE FORMAT
  // ===========================
  String _formatDateRange(String? start, String? end) {
    final formatter = DateFormat("dd MMM yyyy");

    String fmt(String? date) {
      if (date == null) return "-";
      return formatter.format(DateTime.parse(date));
    }

    if (start == null && end == null) {
      return "Periode tidak ditentukan";
    }

    if (end == null) {
      return "Mulai ${fmt(start)}";
    }

    return "${fmt(start)} – ${fmt(end)}";
  }

  // ===========================
  // 📤 SHARE WA
  // ===========================
  Future<void> _shareWhatsApp() async {
    final message =
        "🎉 *PROMO MENARIK* 🎉\n\n"
        "*${promo['title']}*\n\n"
        "${promo['description'] ?? ''}";

    final uri =
        Uri.parse("https://wa.me/?text=${Uri.encodeComponent(message)}");

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ===========================
// 🏷️ STATUS CHIP
// ===========================
class _StatusChip extends StatelessWidget {
  final bool isExpired;

  const _StatusChip({required this.isExpired});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isExpired ? Colors.red : Colors.green,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isExpired ? "BERAKHIR" : "AKTIF",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

// ===========================
// 🖼️ FULLSCREEN IMAGE
// ===========================
class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImagePage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: "promo-image-$imageUrl",
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return const CircularProgressIndicator(color: Colors.white);
                  },
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 80,
                  ),
                ),
              ),
            ),
          ),

          // CLOSE BUTTON
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon:
                  const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
