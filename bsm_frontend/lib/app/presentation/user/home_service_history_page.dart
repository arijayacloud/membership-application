import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import '../widgets/show_snackbar.dart';

class HomeServiceHistoryPage extends StatefulWidget {
  const HomeServiceHistoryPage({super.key});

  @override
  State<HomeServiceHistoryPage> createState() => _HomeServiceHistoryPageState();
}

class _HomeServiceHistoryPageState extends State<HomeServiceHistoryPage> {
  List<Map<String, dynamic>> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  // ----------------------------
  // FETCH HISTORY
  // ----------------------------
  Future<void> loadHistory() async {
    try {
      final res = await ApiService.get("home-service/my");

      print("⏩ REQUEST: home-service/my");
      print("⏩ STATUS: ${res.statusCode}");
      print("⏩ BODY: ${res.body}");

      if (res.statusCode != 200) {
        throw "Server mengembalikan status ${res.statusCode}";
      }

      final json = jsonDecode(res.body);

      setState(() {
        items = List<Map<String, dynamic>>.from(json["data"] ?? []);
        loading = false;
      });
    } catch (e) {
      print("❌ ERROR: $e");
      setState(() => loading = false);
      ShowSnackBar.show(context, "Gagal memuat riwayat: $e", "error");
    }
  }

  // ----------------------------
  // CANCEL REQUEST
  // ----------------------------
  Future<void> cancelRequest(int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Batalkan Permintaan?"),
        content: const Text("Yakin ingin membatalkan permintaan ini?"),
        actions: [
          TextButton(
            child: const Text("Tidak"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Ya, Batalkan"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final res = await ApiService.post("/home-service/$id/cancel", {});
      final data = jsonDecode(res.body);

      ShowSnackBar.show(
        context,
        data['message'] ?? "Berhasil",
        data['success'] == true ? "success" : "error",
      );

      loadHistory();
    } catch (e) {
      ShowSnackBar.show(context, "Gagal membatalkan: $e", "error");
    }
  }

  // ----------------------------
  // HELPERS
  // ----------------------------
  Color statusColor(String? status) {
    switch (status) {
      case "pending":
        return Colors.orange;
      case "approved":
        return Colors.blue;
      case "on_process":
  return Colors.amber.shade800;
      case "done":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "-";
    try {
      return DateFormat("EEEE, d MMM yyyy", "id_ID")
          .format(DateTime.parse(date));
    } catch (_) {
      return date;
    }
  }

  String formatTime(String? time) {
    if (time == null || time.isEmpty) return "-";
    try {
      final t = DateFormat("HH:mm:ss").parse(time);
      return DateFormat("HH:mm").format(t);
    } catch (_) {
      return time;
    }
  }

  // ----------------------------
  // BUILD
  // ----------------------------
  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        _buildHeader(),
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : items.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        return HistoryCard(
                          data: items[i],
                          formatDate: formatDate,
                          formatTime: formatTime,
                          statusColor: statusColor,
                          onCancel: () =>
                              cancelRequest(items[i]["id"]),
                        );
                      },
                    ),
        ),
      ],
    ),
  );
}

  // ----------------------------
  // HEADER WIDGET
  // ----------------------------
  Widget _buildHeader() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 48, 20, 28),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xff004B92), Color(0xff0054A5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(26),
        bottomRight: Radius.circular(26),
      ),
    ),
    child: Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 14),
        const Icon(Icons.history, color: Colors.white, size: 30),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Riwayat Home Service",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Semua permintaan Anda",
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _emptyState() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: const [
      Icon(Icons.inbox_outlined, size: 80, color: Colors.grey),
      SizedBox(height: 12),
      Text(
        "Belum ada riwayat Home Service",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      SizedBox(height: 6),
      Text(
        "Permintaan Home Service Anda akan muncul di sini",
        style: TextStyle(color: Colors.grey),
      ),
    ],
  );
}
}

// =======================================================================
// COMPONENT: HISTORY CARD
// =======================================================================
class HistoryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String Function(String?) formatDate;
  final String Function(String?) formatTime;
  final Color Function(String?) statusColor;
  final VoidCallback onCancel;

  const HistoryCard({
    super.key,
    required this.data,
    required this.formatDate,
    required this.formatTime,
    required this.statusColor,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final status = data["status"] ?? "-";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITLE + STATUS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data["service_type"] ?? "-",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _statusChip(status),
              ],
            ),

            const SizedBox(height: 12),
            _row(Icons.calendar_today, formatDate(data["schedule_date"])),
            _row(Icons.access_time, formatTime(data["schedule_time"])),
            _row(Icons.location_on, data["address"] ?? "-"),

            if ((data["problem_description"] ?? "").toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: _row(Icons.notes, data["problem_description"]),
              ),

            if (status == "pending") ...[
              const Divider(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  label: const Text(
                    "Batalkan",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final color = statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.replaceAll("_", " ").toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
