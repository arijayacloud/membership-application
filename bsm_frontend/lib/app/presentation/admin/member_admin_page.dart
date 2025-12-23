import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../../services/api_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import '../widgets/show_snackbar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class MemberAdminPage extends StatefulWidget {
  const MemberAdminPage({super.key});

  @override
  State<MemberAdminPage> createState() => _MemberAdminPageState();
}

class _MemberAdminPageState extends State<MemberAdminPage> {
  List members = [];
  bool isLoading = false;
  int currentPage = 1;
  int lastPage = 1;
  String searchQuery = "";
  TextEditingController searchController = TextEditingController();
  int totalMember = 0;
  List membershipTypes = [];
  bool loadingTypes = false;

  @override
  void initState() {
    super.initState();
    fetchMembers();
    fetchMembershipTypes();
  }

  Future<void> fetchMembers() async {
    setState(() => isLoading = true);

    final response = await ApiService.get(
      "admin/members",
      query: {
        "page": currentPage.toString(),
        if (searchQuery.isNotEmpty) "search": searchQuery,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final m = data["members"]["data"] as List;
      setState(() {
        members = m;
        currentPage = data["members"]["current_page"] ?? 1;
        lastPage = data["members"]["last_page"] ?? 1;
        totalMember = data["members"]["total"] ?? m.length;
      });
    } else {
      ShowSnackBar.show(context, "Gagal memuat data member", "error");
    }

    setState(() => isLoading = false);
  }

  Future<void> fetchMembershipTypes() async {
    setState(() => loadingTypes = true);

    final res = await ApiService.get("admin/membership-types");

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);

      final List list = json["types"] ?? [];

      setState(() {
        membershipTypes = list;
      });

      debugPrint("membershipTypes length: ${membershipTypes.length}");
    } else {
      setState(() => membershipTypes = []);
    }

    setState(() => loadingTypes = false);
  }

  Future<void> exportExcel() async {
    if (isLoading) return;

    try {
      ShowSnackBar.show(context, "Sedang meng-export...", "warning");

      final response = await ApiService.getFile("admin/members/export");

      if (response.statusCode != 200) {
        ShowSnackBar.show(
          context,
          "Gagal export: ${response.statusCode}",
          "error",
        );
        return;
      }

      final bytes = response.bodyBytes;

      String fileName = "data_member.xlsx";
      final contentDisposition = response.headers["content-disposition"];
      if (contentDisposition != null &&
          contentDisposition.toLowerCase().contains("filename=")) {
        fileName = contentDisposition
            .split("filename=")
            .last
            .replaceAll('"', '')
            .trim();
      }

      // =========================
      // 🌐 WEB
      // =========================
      if (kIsWeb) {
        final blob = html.Blob([Uint8List.fromList(bytes)]);
        final url = html.Url.createObjectUrlFromBlob(blob);

        html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..click();

        html.Url.revokeObjectUrl(url);

        ShowSnackBar.show(context, "Export berhasil!", "success");
        return;
      }

      // =========================
      // 📱 MOBILE (ANDROID / IOS)
      // =========================
      bool permissionGranted = true;

      if (Platform.isAndroid) {
        // Android 13+ tidak perlu storage permission untuk Download
        final sdkInt = await DeviceInfoPlugin().androidInfo.then(
          (info) => info.version.sdkInt,
        );

        if (sdkInt < 30) {
          final status = await Permission.storage.request();
          permissionGranted = status.isGranted;
        }
      }

      if (!permissionGranted) {
        ShowSnackBar.show(context, "Izin penyimpanan ditolak", "warning");
        return;
      }

      // =========================
      // 📂 DOWNLOAD DIRECTORY
      // =========================
      Directory downloadDir;

      if (Platform.isAndroid) {
        downloadDir = Directory('/storage/emulated/0/Download');
      } else {
        downloadDir = await getApplicationDocumentsDirectory();
      }

      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      final filePath = "${downloadDir.path}/$fileName";
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      ShowSnackBar.show(
        context,
        "Export berhasil disimpan di Download",
        "success",
      );
    } catch (e) {
      ShowSnackBar.show(context, "Gagal export: $e", "error");
    }
  }

  Future<void> editMemberDialog(Map member) async {
    if (membershipTypes.isEmpty) {
      await fetchMembershipTypes();
    }

    print("membershipTypes length: ${membershipTypes.length}");

    final user = member["user"];

    final nameC = TextEditingController(text: user["name"]);
    final phoneC = TextEditingController(text: user["phone"]);
    final emailC = TextEditingController(text: user["email"] ?? "");

    final vehicleTypeC = TextEditingController(
      text: member["vehicle_type"] ?? "",
    );
    final vehicleBrandC = TextEditingController(
      text: member["vehicle_brand"] ?? "",
    );
    final vehicleModelC = TextEditingController(
      text: member["vehicle_model"] ?? "",
    );
    final vehicleSerialC = TextEditingController(
      text: member["vehicle_serial_number"] ?? "",
    );
    final addressC = TextEditingController(text: member["address"] ?? "");
    final cityC = TextEditingController(text: member["city"] ?? "");

    String status = member["status"] ?? "active";
    int? membershipTypeId = member["membership_type_id"];
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                left: 20,
                right: 20,
                top: 16,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      "Edit Member",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _sectionCard(
                      title: "Data User",
                      icon: Icons.person,
                      children: [
                        _inputField("Nama", nameC, Icons.badge),
                        _inputField("Nomor HP", phoneC, Icons.phone),
                        _inputField("Email", emailC, Icons.email),
                      ],
                    ),

                    _sectionCard(
                      title: "Membership",
                      icon: Icons.workspace_premium,
                      children: [
                        loadingTypes
                            ? const Center(child: CircularProgressIndicator())
                            : DropdownButtonFormField<int>(
                                value:
                                    membershipTypes.any(
                                      (e) => e["id"] == membershipTypeId,
                                    )
                                    ? membershipTypeId
                                    : null,
                                items: membershipTypes
                                    .map<DropdownMenuItem<int>>(
                                      (e) => DropdownMenuItem<int>(
                                        value: e["id"] as int,
                                        child: Text(
                                          e["display_name"].toString(),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) =>
                                    setModalState(() => membershipTypeId = v),
                                decoration: _inputDecoration(
                                  "Upgrade Membership",
                                  Icons.upgrade,
                                ),
                              ),

                        const SizedBox(height: 12),

                        DropdownButtonFormField<String>(
                          value: status,
                          items: const [
                            DropdownMenuItem(
                              value: "active",
                              child: Text("Active"),
                            ),
                            DropdownMenuItem(
                              value: "non_active",
                              child: Text("Non Active"),
                            ),
                            DropdownMenuItem(
                              value: "expired",
                              child: Text("Expired"),
                            ),
                            DropdownMenuItem(
                              value: "pending",
                              child: Text("Pending"),
                            ),
                          ],
                          onChanged: (v) => setModalState(() => status = v!),
                          decoration: _inputDecoration(
                            "Status Member",
                            Icons.flag,
                          ),
                        ),
                      ],
                    ),

                    _sectionCard(
                      title: "Kendaraan",
                      icon: Icons.directions_car,
                      children: [
                        _inputField(
                          "Tipe Kendaraan",
                          vehicleTypeC,
                          Icons.category,
                        ),
                        _inputField(
                          "Merek",
                          vehicleBrandC,
                          Icons.directions_car,
                        ),
                        _inputField("Model", vehicleModelC, Icons.car_rental),
                        _inputField(
                          "Nomor Rangka",
                          vehicleSerialC,
                          Icons.confirmation_number,
                        ),
                      ],
                    ),

                    _sectionCard(
                      title: "Alamat",
                      icon: Icons.location_on,
                      children: [
                        _inputField("Alamat", addressC, Icons.home),
                        _inputField("Kota", cityC, Icons.location_city),
                      ],
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: saving
                            ? null
                            : () async {
                                setModalState(() => saving = true);

                                final Map<String, dynamic> payload = {
                                  "name": nameC.text,
                                  "phone": phoneC.text,
                                  "email": emailC.text,
                                  "status": status,
                                  "vehicle_type": vehicleTypeC.text,
                                  "vehicle_brand": vehicleBrandC.text,
                                  "vehicle_model": vehicleModelC.text,
                                  "vehicle_serial_number": vehicleSerialC.text,
                                  "address": addressC.text,
                                  "city": cityC.text,
                                };

                                if (membershipTypeId !=
                                    member["membership_type_id"]) {
                                  payload["membership_type_id"] =
                                      membershipTypeId;
                                }

                                final res = await ApiService.put(
                                  "admin/members/${member["id"]}",
                                  payload,
                                );

                                setModalState(() => saving = false);

                                if (res.statusCode == 200) {
                                  Navigator.pop(context);
                                  ShowSnackBar.show(
                                    context,
                                    "Member berhasil diperbarui",
                                    "success",
                                  );
                                  fetchMembers();
                                } else {
                                  ShowSnackBar.show(
                                    context,
                                    "Gagal update member",
                                    "error",
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: adminPrimary,
                          elevation: 2,
                          shadowColor: adminPrimary.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: saving
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Simpan Perubahan",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void deleteMember(int id) async {
    final res = await ApiService.delete("admin/members/$id");

    if (res.statusCode == 200) {
      ShowSnackBar.show(context, "Member berhasil dihapus", "success");
      fetchMembers();
    } else {
      ShowSnackBar.show(context, "Gagal menghapus member", "error");
    }
  }

  void confirmDeleteMember(int id) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Hapus Member?",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Apakah Anda yakin ingin menghapus member ini? Tindakan ini tidak dapat dibatalkan.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                Navigator.pop(context); // Tutup dialog
                deleteMember(id); // Lanjutkan hapus data
              },
              child: const Text("Ya, Hapus"),
            ),
          ],
        );
      },
    );
  }

  Widget _headerStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F2937), Color(0xFF374151)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.people_alt_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total Member",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "$totalMember",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: _inputDecoration(label, icon),
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Cari nama atau nomor HP...",
          border: InputBorder.none,
          icon: const Icon(Icons.search, color: adminMuted),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    searchQuery = "";
                    searchController.clear();
                    currentPage = 1;
                    fetchMembers();
                  },
                )
              : null,
        ),
        onSubmitted: (v) {
          searchQuery = v;
          currentPage = 1;
          fetchMembers();
        },
      ),
    );
  }

  Widget _memberList() {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 12),
      itemCount: members.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, i) {
        final m = members[i];
        final user = m["user"];

        final initial = user["name"].toString().isNotEmpty
            ? user["name"][0].toUpperCase()
            : "?";

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey.shade200,
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 22,
                    color: adminDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // DETAIL
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user["name"],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: adminDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          user["phone"],
                          style: const TextStyle(
                            fontSize: 13,
                            color: adminMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Kode: ${m["member_code"]}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),

              // AKSI
              Column(
                children: [
                  _iconAction(
                    icon: Icons.edit,
                    color: Colors.blue,
                    onTap: () => editMemberDialog(m),
                  ),
                  const SizedBox(height: 8),
                  _iconAction(
                    icon: Icons.delete,
                    color: Colors.red,
                    onTap: () => confirmDeleteMember(m["id"]),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _iconAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _shimmerList() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (_, i) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(14),
          ),
          height: 80,
        );
      },
    );
  }

  Widget _paginationBar() {
    if (isLoading) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: currentPage > 1
                ? () {
                    currentPage--;
                    fetchMembers();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            child: const Text("Prev"),
          ),
          Text(
            "Page $currentPage / $lastPage",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            onPressed: currentPage < lastPage
                ? () {
                    currentPage++;
                    fetchMembers();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            child: const Text("Next"),
          ),
        ],
      ),
    );
  }

  Widget buildHeader(BuildContext context, VoidCallback exportExcel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF374151)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Stack(
        children: [
          // 🔙 Tombol Back
          Positioned(
            left: 0,
            top: 0,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),

          // 📌 Judul + Deskripsi
          const Padding(
            padding: EdgeInsets.only(
              left: 46,
            ), // Biar tidak tabrakan dengan tombol back
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Kelola Member",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Export data member & kelola informasi",
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ],
            ),
          ),

          // 📥 Tombol Export
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: exportExcel,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.download_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // UI (Modern & Clean)
  // ================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FA),

      body: Column(
        children: [
          // 🌟 CUSTOM HEADER (GANTI APPBAR)
          buildHeader(context, exportExcel),

          const SizedBox(height: 10),

          // 🔵 HEADER STATISTIK
          _headerStats(),

          // 🔍 SEARCH BAR
          Padding(padding: const EdgeInsets.all(12), child: _searchBar()),

          Expanded(
            child: isLoading
                ? _shimmerList()
                : members.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 60,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Belum ada member",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : _memberList(),
          ),

          _paginationBar(),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}

const adminPrimary = Color(0xFF2563EB); // blue-600
const adminDark = Color(0xFF111827);
const adminMuted = Color(0xFF6B7280); // gray-500
