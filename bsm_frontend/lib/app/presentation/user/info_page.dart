import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../../../services/api_service.dart';
import 'package:lucide_icons/lucide_icons.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  bool loading = true;
  Map info = {};

  getInfo() async {
    final res = await ApiService.get("infos");
    final data = jsonDecode(res.body);

    setState(() {
      info = data['data'];
      loading = false;
    });
  }

  Future<void> _openMaps(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callPhone(String phone) async {
    final uri = Uri.parse("tel:$phone");

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  void initState() {
    super.initState();
    getInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
      body: Column(
        children: [
          // ============================================================
          // 🔵 CUSTOM APP BAR
          // ============================================================
          Container(
            padding: const EdgeInsets.only(
              top: 48,
              bottom: 26,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1F3C88), Color(0xFF3A6EA5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Row(
              children: [
                InkResponse(
                  onTap: () => Navigator.pop(context),
                  radius: 24,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      LucideIcons.arrowLeft,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Text(
                  "Informasi Bengkel",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // ============================================================
          // 🔽 CONTENT
          // ============================================================
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ======================
                        // 🏥 HEADER INFO
                        // ======================
                        Text(
                          info['clinic_name'] ?? "Nama Bengkel",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F3C88),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          info['description'] ?? "-",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 24),

                        _section(
                          title: "Informasi Dasar",
                          icon: LucideIcons.info,
                          children: [
                            _infoTile(
                              Icons.location_on,
                              "Alamat",
                              info['address'],
                            ),
                            _infoTile(
                              Icons.access_time,
                              "Jam Operasional",
                              info['operational_hours'],
                            ),
                            _infoTile(
                              Icons.phone,
                              "Kontak",
                              info['phone'],
                              onTap: () => _callPhone(info['phone']),
                            ),
                          ],
                        ),

                        _section(
                          title: "Layanan Bengkel",
                          icon: LucideIcons.stethoscope,
                          children: [_listCard(info['services'] ?? [])],
                        ),

                        _section(
                          title: "Fasilitas",
                          icon: LucideIcons.building,
                          children: [_listCard(info['facilities'] ?? [])],
                        ),

                        _section(
                          title: "Sosial Media",
                          icon: LucideIcons.share2,
                          children: [
                            _infoTile(
                              Icons.location_on,
                              "Maps",
                              "Lihat Lokasi Bengkel",
                              onTap: () => _openMaps(info['maps_url']),
                            ),
                            _infoTile(
                              Icons.web,
                              "Instagram",
                              info['instagram'],
                              onTap: () async {
                                final uri = Uri.parse(info['instagram']);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              },
                            ),
                            _infoTile(
                              Icons.web,
                              "Website",
                              info['website'],
                              onTap: () async {
                                final uri = Uri.parse(info['website']);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🔹 SECTION WRAPPER
  // ============================================================
  Widget _section({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF1F3C88), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F3C88),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  // ============================================================
  // 🔹 INFO TILE
  // ============================================================
  Widget _infoTile(
    IconData icon,
    String title,
    String? value, {
    VoidCallback? onTap,
  }) {
    if (value == null || value.isEmpty) return const SizedBox();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1F3C88).withOpacity(0.1),
          child: Icon(icon, color: const Color(0xFF1F3C88)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: onTap != null
            ? const Icon(Icons.open_in_new, size: 18, color: Colors.grey)
            : null,
      ),
    );
  }

  // ============================================================
  // 🔹 LIST CARD
  // ============================================================
  Widget _listCard(List items) {
    if (items.isEmpty) {
      return const Text(
        "Tidak ada data.",
        style: TextStyle(color: Colors.grey),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.toString(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
