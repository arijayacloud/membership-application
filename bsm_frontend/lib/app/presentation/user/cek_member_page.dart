import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  final GlobalKey cardKey = GlobalKey();

  List members = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchMyMembers();
  }

  Future<void> fetchMyMembers() async {
    try {
      final res = await ApiService.get("member/me");
      final body = jsonDecode(res.body);

      if (res.statusCode == 200 && body['status'] == true) {
        setState(() {
          members = body['members'];
          loading = false;
        });
      } else {
        loading = false;
        _showError(body['message'] ?? "Belum memiliki member");
      }
    } catch (e) {
      loading = false;
      _showError("Gagal mengambil data member");
    }
  }

  Future<void> downloadCard(Map memberData) async {
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
      final fileName = "digital_member_${memberData['member_code']}.png";

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
          // =========================
          // 🌈 HEADER
          // =========================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 44, 20, 28),
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
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      CupertinoIcons.arrow_left,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Cek Member",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Lihat informasi member Anda",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // =========================
          // 📦 CONTENT
          // =========================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Member Saya",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F3C88),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (loading)
                    const Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Center(
                        child: CupertinoActivityIndicator(radius: 16),
                      ),
                    )
                  else if (members.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Center(
                        child: Column(
                          children: const [
                            Icon(
                              CupertinoIcons.person_crop_circle_badge_xmark,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Anda belum terdaftar sebagai member",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              RepaintBoundary(
                                key: index == 0 ? cardKey : null,
                                child: DigitalMemberCard(
                                  name: member['name'],
                                  memberCode: member['member_code'],
                                  membershipType:
                                      member['membership_type']['name'],
                                  expiredAt: member['expired_at'],
                                ),
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: ElevatedButton.icon(
                                  onPressed: () => downloadCard(member),
                                  icon: const Icon(Icons.download_rounded),
                                  label: const Text(
                                    "Download Kartu Member",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1F3C88),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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
