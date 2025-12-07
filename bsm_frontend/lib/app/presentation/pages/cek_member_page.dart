import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../services/api_service.dart';

class CekMemberPage extends StatefulWidget {
  const CekMemberPage({super.key});

  @override
  State<CekMemberPage> createState() => _CekMemberPageState();
}

class _CekMemberPageState extends State<CekMemberPage> {
  final phoneCtrl = TextEditingController();
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

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  Color _statusColor(String status) {
    final s = status.toLowerCase();

    if (s == "active" || s == "aktif") {
      return Colors.green;
    }
    return Colors.red; // selain itu otomatis merah
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),

      // ==========================
      // 🌟 HEADER sama dengan dashboard
      // ==========================
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

                  if (memberData != null) _memberCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================
  // 🌟 KARTU HASIL MEMBER — Sama style dengan DashboardCard
  // ==========================
  Widget _memberCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER PROFILE
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.blue.shade100,
                child: const Icon(
                  CupertinoIcons.person_fill,
                  size: 36,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 18),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    memberData!['name'] ?? "-",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(memberData!['status']),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      memberData!['status'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(),

          const SizedBox(height: 14),

          // DETAIL ITEMS
          _detailItem(
            icon: LucideIcons.badgeCheck,
            title: "Kode Member",
            value: memberData!['member_code'],
          ),
          _detailItem(
            icon: LucideIcons.phone,
            title: "Nomor HP",
            value: memberData!['phone'],
          ),
          _detailItem(
            icon: LucideIcons.calendar,
            title: "Join Date",
            value: memberData!['join_date'],
          ),
        ],
      ),
    );
  }

  Widget _detailItem({
    required IconData icon,
    required String title,
    required String? value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1F3C88)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value ?? "-",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
