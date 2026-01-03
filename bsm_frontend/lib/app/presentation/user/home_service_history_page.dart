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

  int? selectedMemberId;
  List<Map<String, dynamic>> members = [];

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

      if (!mounted) return; // 🔥 WAJIB

      if (res.statusCode != 200) {
        throw "Server mengembalikan status ${res.statusCode}";
      }

      final json = jsonDecode(res.body);

      setState(() {
        items = List<Map<String, dynamic>>.from(json["data"] ?? []);
        loading = false;

        // Ambil member unik
        final map = <int, Map<String, dynamic>>{};
        for (final item in items) {
          final member = item["member"];
          if (member != null) {
            map[member["id"]] = member;
          }
        }
        members = map.values.toList();
      });
    } catch (e) {
      if (!mounted) return; // 🔥 WAJIB

      setState(() => loading = false);
      ShowSnackBar.show(context, "Gagal memuat riwayat: $e", "error");
    }
  }

  List<Map<String, dynamic>> get filteredItems {
    if (selectedMemberId == null) return items;

    return items.where((e) => e["member"]?["id"] == selectedMemberId).toList();
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

    if (confirm != true || !mounted) return;

    try {
      final res = await ApiService.post("/home-service/$id/cancel", {});
      final data = jsonDecode(res.body);

      if (!mounted) return;

      ShowSnackBar.show(
        context,
        data['message'] ?? "Berhasil",
        data['success'] == true ? "success" : "error",
      );

      loadHistory(); // aman, karena loadHistory sudah pakai mounted
    } catch (e) {
      if (!mounted) return;

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

  Color memberColor(int memberId) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
    ];
    return colors[memberId % colors.length];
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "-";
    try {
      return DateFormat(
        "EEEE, d MMM yyyy",
        "id_ID",
      ).format(DateTime.parse(date));
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

  Widget _memberFilter() {
  if (members.isEmpty) return const SizedBox();

  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonFormField<int?>(
        value: selectedMemberId,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        decoration: const InputDecoration(
          contentPadding:
              EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          labelText: "Filter Member",
          prefixIcon: Icon(Icons.directions_car),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
        items: [
          const DropdownMenuItem<int?>(
            value: null,
            child: Row(
              children: [
                Icon(Icons.group, size: 18, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  "Semua Member",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          ...members.map((m) {
            return DropdownMenuItem<int?>(
  value: m["id"],
  child: Row(
    children: [
      Icon(
        Icons.person,
        size: 18,
        color: memberColor(m["id"]),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          "${m["member_code"]} • ${m["vehicle_type"]}",
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    ],
  ),
);
          }).toList(),
        ],
        onChanged: (val) {
          setState(() => selectedMemberId = val);
        },
      ),
    ),
  );
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
          _memberFilter(),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : filteredItems.isEmpty
                ? _emptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredItems.length,
                    itemBuilder: (_, i) {
                      final item = filteredItems[i];
                      final memberId = item["member"]?["id"] ?? 0;

                      return HistoryCard(
                        data: item,
                        memberColor: memberColor(memberId),
                        formatDate: formatDate,
                        formatTime: formatTime,
                        statusColor: statusColor,
                        onCancel: () => cancelRequest(item["id"]),
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
  final Color memberColor;

  const HistoryCard({
    super.key,
    required this.data,
    required this.memberColor,
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
            if (data["member"] != null) _memberBadge(),

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

  Widget _memberBadge() {
    final member = data["member"];
    if (member == null) return const SizedBox();

    final memberName = member["user"]?["name"] ?? "-";
    final memberCode = member["member_code"] ?? "-";
    final vehicleType = member["vehicle_type"] ?? "-";

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: memberColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nama user
          Text(
            memberName,
            style: TextStyle(
              color: memberColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 2),

          // Identitas member
          Text(
            "$memberCode • $vehicleType",
            style: TextStyle(color: memberColor, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
