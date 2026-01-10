import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:bsm_frontend/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  Uint8List? memberPhotoBytes;
  File? memberPhotoFile;
  String? memberPhotoFilename;

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

  Future<void> _pickMemberPhoto(Function setModalState) async {
    if (kIsWeb) {
      final input = html.FileUploadInputElement()..accept = 'image/*';
      input.click();

      input.onChange.listen((event) {
        final file = input.files!.first;
        final reader = html.FileReader();

        reader.readAsArrayBuffer(file);
        reader.onLoadEnd.listen((_) {
          setModalState(() {
            memberPhotoBytes = reader.result as Uint8List;
            memberPhotoFilename = file.name;
            memberPhotoFile = null;
          });
        });
      });
    } else {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);

      if (picked != null) {
        setModalState(() {
          memberPhotoFile = File(picked.path);
          memberPhotoBytes = null;
        });
      }
    }
  }

  Future<void> validateMemberPhoto(int memberId) async {
    try {
      ShowSnackBar.show(context, "Memvalidasi member...", "warning");

      final res = await ApiService.post(
        "admin/members/$memberId/validate",
        {}, // 👈 WAJIB ADA, meskipun kosong
      );

      if (res.statusCode == 200) {
        ShowSnackBar.show(context, "Member berhasil diaktifkan", "success");
        fetchMembers();
      } else {
        final body = jsonDecode(res.body);
        ShowSnackBar.show(
          context,
          body["message"] ?? "Gagal memvalidasi member",
          "error",
        );
      }
    } catch (e) {
      ShowSnackBar.show(context, "Terjadi kesalahan: $e", "error");
    }
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
    memberPhotoBytes = null;
    memberPhotoFile = null;
    memberPhotoFilename = null;

    final String? photoUrl = member["member_photo"] != null
        ? "${AppConfig.baseUrl}/media/${member["member_photo"]}"
        : null;

    print("PHOTO URL => ${member["member_photo_url"]}");
    print("MEMBER => $member");

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
    int? membershipTypeId =
    int.tryParse(member["membership_type_id"]?.toString() ?? "");
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
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          // ======================
                          // FOTO MEMBER (PREVIEW)
                          // ======================
                          GestureDetector(
                            onTap: () {
                              if (memberPhotoBytes != null) {
                                showFullImage(
                                  context,
                                  MemoryImage(memberPhotoBytes!),
                                );
                              } else if (memberPhotoFile != null) {
                                showFullImage(
                                  context,
                                  FileImage(memberPhotoFile!),
                                );
                              } else if (photoUrl != null) {
                                showFullImage(context, NetworkImage(photoUrl));
                              } else {
                                _pickMemberPhoto(setModalState);
                              }
                            },
                            child: CircleAvatar(
                              radius: 46,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: memberPhotoBytes != null
                                  ? MemoryImage(memberPhotoBytes!)
                                  : memberPhotoFile != null
                                  ? FileImage(memberPhotoFile!)
                                  : photoUrl != null
                                  ? NetworkImage(photoUrl)
                                  : null,
                              child:
                                  memberPhotoBytes == null &&
                                      memberPhotoFile == null &&
                                      photoUrl == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 36,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),

                          // ======================
                          // TOMBOL GANTI FOTO
                          // ======================
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _pickMemberPhoto(setModalState),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: adminPrimary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    _sectionCard(
                      title: "Membership",
                      icon: Icons.workspace_premium,
                      children: [
                        loadingTypes
                            ? const Center(child: CircularProgressIndicator())
                            : DropdownButtonFormField<int>(
  value: membershipTypes.any(
    (e) =>
        int.tryParse(e["id"].toString()) == membershipTypeId,
  )
      ? membershipTypeId
      : null,
  items: membershipTypes.map<DropdownMenuItem<int>>((e) {
    final id = int.tryParse(e["id"].toString());
    return DropdownMenuItem<int>(
      value: id,
      child: Text(e["display_name"].toString()),
    );
  }).toList(),
  onChanged: (v) => setModalState(() => membershipTypeId = v),
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

                                final fields = <String, String>{
                                  "_method": "PUT",
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
                                        member["membership_type_id"] &&
                                    membershipTypeId != null) {
                                  fields["membership_type_id"] =
                                      membershipTypeId.toString();
                                }

                                late final res;

                                if (kIsWeb && memberPhotoBytes != null) {
                                  res = await ApiService.multipartPostBytes(
                                    "admin/members/${member["id"]}",
                                    fields: fields,
                                    bytes: memberPhotoBytes!,
                                    filename: memberPhotoFilename!,
                                    fieldName: "member_photo",
                                  );
                                } else if (!kIsWeb && memberPhotoFile != null) {
                                  res = await ApiService.multipartPost(
                                    "admin/members/${member["id"]}",
                                    fields: fields,
                                    files: {"member_photo": memberPhotoFile!},
                                  );
                                } else {
                                  res = await ApiService.multipartPost(
                                    "admin/members/${member["id"]}",
                                    fields: fields,
                                    files: {},
                                  );
                                }

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
                                  String message = "Gagal update member";

                                  try {
                                    final responseText = await res.stream
                                        .bytesToString();
                                    final body = jsonDecode(responseText);
                                    message = body["message"] ?? message;
                                  } catch (_) {}

                                  ShowSnackBar.show(context, message, "error");
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

  void showFullImage(BuildContext context, ImageProvider image) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.95),
      builder: (_) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4.0,
                    child: Image(image: image),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
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

  void confirmValidatePhoto(Map member) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Validasi Foto Member",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Apakah foto member ini sudah sesuai dan ingin mengaktifkan member?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                Navigator.pop(context);
                validateMemberPhoto(member["id"]);
              },
              child: const Text("Ya, Aktifkan"),
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
              GestureDetector(
                onTap: m["member_photo"] != null
                    ? () {
                        showMemberPhotoPreview(
                          context,
                          "${AppConfig.baseUrl}/media/${m["member_photo"]}",
                        );
                      }
                    : null,
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: m["member_photo"] != null
                      ? NetworkImage(
                          "${AppConfig.baseUrl}/media/${m["member_photo"]}",
                        )
                      : null,
                  child: m["member_photo"] == null
                      ? Text(
                          initial,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
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
                    Row(
                      children: [
                        _statusBadge(m["status"]),
                        const SizedBox(width: 8),
                        Text(
                          m["membership_type"]["name"],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                      ],
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

                  if (m["status"] == "pending" &&
                      m["member_photo"] != null) ...[
                    _iconAction(
                      icon: Icons.verified,
                      color: Colors.green,
                      onTap: () => confirmValidatePhoto(m),
                    ),
                    const SizedBox(height: 8),
                  ],

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

  void showMemberPhotoPreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (_) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4,
                    child: Hero(
                      tag: imageUrl,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const CircularProgressIndicator();
                        },
                      ),
                    ),
                  ),
                ),

                // ❌ Close button
                Positioned(
                  top: 40,
                  right: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statusBadge(String status) {
    final map = {
      "active": Colors.green,
      "pending": Colors.orange,
      "expired": Colors.red,
      "non_active": Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: map[status]?.withOpacity(0.15) ?? Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: map[status] ?? Colors.grey,
        ),
      ),
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
