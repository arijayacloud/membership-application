import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import '../../../services/api_service.dart';
import 'digital_member_card_page.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../widgets/show_snackbar.dart';

class CekMemberPage extends StatefulWidget {
  const CekMemberPage({super.key});

  @override
  State<CekMemberPage> createState() => _CekMemberPageState();
}

class _CekMemberPageState extends State<CekMemberPage> {
  final phoneCtrl = TextEditingController();
  final GlobalKey cardKey = GlobalKey();

  Map? memberData;
  bool loading = false;

  Future cekMember() async {
    final input = phoneCtrl.text.trim();

    if (input.isEmpty) {
      _showError("Nomor HP atau Member Code tidak boleh kosong.");
      return;
    }

    setState(() => loading = true);

    // Deteksi apakah input adalah nomor HP atau member_code
    final isPhone = RegExp(r'^[0-9]+$').hasMatch(input);

    final endpoint = isPhone
        ? "member/check?phone=$input"
        : "member/check?member_code=$input";

    final res = await ApiService.get(endpoint);

    if (!mounted) return;
    setState(() => loading = false);

    final body = jsonDecode(res.body);

    if (res.statusCode == 200 && body['status'] == true) {
      setState(() => memberData = body['member']);
    } else {
      setState(() => memberData = null);
      _showError(body['message'] ?? "Member tidak ditemukan");
    }
  }

  Future<void> downloadCard() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));

      final boundary =
          cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      final image = await boundary.toImage(pixelRatio: 4);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception("Gagal generate gambar");
      }

      final pngBytes = byteData.buffer.asUint8List();
      final fileName = "digital_member_${memberData!['member_code']}.png";

      // =========================
      // 🌐 WEB
      // =========================
      if (kIsWeb) {
        final blob = html.Blob([pngBytes], 'image/png');
        final url = html.Url.createObjectUrlFromBlob(blob);

        html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..click();

        html.Url.revokeObjectUrl(url);

        ShowSnackBar.show(context, "Kartu berhasil diunduh 💳✨", "success");
        return;
      }

      // =========================
      // 📱 ANDROID / IOS
      // =========================
      late Directory directory;

      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        throw Exception("Platform tidak didukung");
      }

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final filePath = "${directory.path}/$fileName";
      final file = File(filePath);
      await file.writeAsBytes(pngBytes, flush: true);

      ShowSnackBar.show(
        context,
        Platform.isAndroid
            ? "Kartu tersimpan di Download 🎉"
            : "Kartu tersimpan di Dokumen 🎉",
        "success",
      );
    } catch (e) {
      ShowSnackBar.show(context, "Gagal menyimpan kartu: $e", "error");
    }
  }

  void _showError(String msg) {
    ShowSnackBar.show(context, "User belum mendaftar menjadi Member", "error");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 40,
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

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ======================================
                // 🔙 BACK BUTTON + TITLE (tidak bertumpuk)
                // ======================================
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          LucideIcons.arrowLeft,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Cek Member",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),
                const Text(
                  "Masukkan nomor HP atau ID Member",
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // =======================
                  // 🔍 SEARCH INPUT CARD STYLE
                  // =======================
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: CupertinoTextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      placeholder: "Masukkan No HP / Member ID...",
                      padding: const EdgeInsets.all(16),
                      prefix: const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Icon(CupertinoIcons.search, color: Colors.grey),
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // =======================
                  // BUTTON ala Dashboard UI
                  // =======================
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        backgroundColor: const Color(0xFF1F3C88),
                        elevation: 3,
                      ),
                      onPressed: loading ? null : cekMember,
                      child: loading
                          ? const CupertinoActivityIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              "Cek Sekarang",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (memberData != null)
                    Column(
                      children: [
                        RepaintBoundary(
                          key: cardKey,
                          child: DigitalMemberCard(
                            name: memberData!['name'],
                            memberCode: memberData!['member_code'],
                            membershipType:
                                memberData!['membership_type']['name'],
                            expiredAt: memberData!['expired_at'],
                          ),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          onPressed: downloadCard,
                          icon: const Icon(Icons.download, color: Colors.white),
                          label: const Text("Download Card"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1F3C88),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
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
    );
  }
}
