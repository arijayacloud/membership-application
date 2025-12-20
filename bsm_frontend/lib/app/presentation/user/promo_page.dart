import 'package:bsm_frontend/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../services/api_service.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import 'promo_detail_page.dart';

class PromoPage extends StatefulWidget {
  const PromoPage({super.key});

  @override
  State<PromoPage> createState() => _PromoPageState();
}

class _PromoPageState extends State<PromoPage> {
  List promos = [];
  bool loading = true;

  Future<void> getPromos() async {
    final res = await ApiService.get("promo");
    final decoded = jsonDecode(res.body);

    setState(() {
      promos = decoded['data']['data'];
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getPromos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : promos.isEmpty
                    ? _emptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: promos.length,
                        itemBuilder: (_, i) =>
                            _promoCard(context, promos[i]),
                      ),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1F3C88), Color(0xFF3A6EA5)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(LucideIcons.arrowLeft,
                  color: Colors.white),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            "Promo BSM Clinic",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  // ================= PROMO CARD =================
  Widget _promoCard(BuildContext context, dynamic promo) {
    final imageUrl = promo['banner'] != null
        ? "${AppConfig.baseUrl}/media/${promo['banner']}"
        : null;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PromoDetailPage(promo: promo),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 10,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 180,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 40),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    promo['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    promo['description'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[700]),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(Icons.date_range, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        _formatDateRange(
                          promo['start_date'],
                          promo['end_date'],
                        ),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ================= EMPTY STATE =================
  Widget _emptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.local_offer_outlined,
            size: 70, color: Colors.grey[400]),
        const SizedBox(height: 12),
        const Text(
          "Belum ada promo",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          "Pantau terus promo menarik dari kami",
          style: TextStyle(color: Colors.grey[600]),
        )
      ],
    );
  }

  // ================= DATE FORMAT =================
  String _formatDateRange(String? start, String? end) {
    final formatter = DateFormat("dd-MM-yy");

    String format(String? date) {
      if (date == null) return "-";
      return formatter.format(DateTime.parse(date));
    }

    if (start == null && end == null) return "Tanggal tidak tersedia";
    if (end == null) return "Mulai ${format(start)}";
    return "${format(start)} - ${format(end)}";
  }
}
