import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../services/api_service.dart';
import '../widgets/show_snackbar.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class EditProfileModal extends StatefulWidget {
  const EditProfileModal({super.key});

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  // Controllers
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final cityCtrl = TextEditingController();

  final vehicleBrandCtrl = TextEditingController();
  final vehicleModelCtrl = TextEditingController();
  final vehicleSerialNumberCtrl = TextEditingController();

  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  bool showPassword = false;
  bool showConfirmPassword = false;

  String? selectedVehicleType;

  bool loading = false;
  List<Map<String, dynamic>> members = [];
  int? selectedMemberId;
  Map<String, dynamic>? selectedMember;

  File? memberPhotoFile; // mobile
  Uint8List? memberPhotoBytes; // web
  String? memberPhotoFilename; // web
  String? memberPhotoUrl;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void selectMember(Map<String, dynamic> member) {
    selectedMember = member;
    selectedMemberId = member["id"];

    addressCtrl.text = member["address"] ?? "";
    cityCtrl.text = member["city"] ?? "";
    selectedVehicleType = member["vehicle_type"];
    vehicleBrandCtrl.text = member["vehicle_brand"] ?? "";
    vehicleModelCtrl.text = member["vehicle_model"] ?? "";
    vehicleSerialNumberCtrl.text = member["vehicle_serial_number"] ?? "";

    // ✅ SIMPAN FOTO LAMA (TRIM)
    memberPhotoUrl = member["member_photo_url"]?.toString().trim();

    // reset foto baru
    memberPhotoFile = null;
    memberPhotoBytes = null;
    memberPhotoFilename = null;

    setState(() {});
  }

  Future<Map<String, dynamic>> readResponseBody(dynamic res) async {
    if (res is http.Response) {
      return jsonDecode(res.body);
    } else {
      final bodyString = await res.stream.bytesToString();
      return jsonDecode(bodyString);
    }
  }

  Future<void> loadData() async {
    try {
      setState(() => loading = true);

      final res = await ApiService.get("member/profile");
      if (res.statusCode != 200) {
        ShowSnackBar.show(context, "Gagal memuat data profil", "error");
        return;
      }

      final data = jsonDecode(res.body);
      final user = data["user"];

      members = List<Map<String, dynamic>>.from(data["members"] ?? []);

      nameCtrl.text = user?["name"] ?? "";
      phoneCtrl.text = user?["phone"] ?? "";
      emailCtrl.text = user?["email"] ?? "";

      if (members.isNotEmpty) {
        selectMember(members.first);
      } else {
        selectedMember = null;
        selectedMember = null;

        addressCtrl.clear();
        cityCtrl.clear();
        selectedVehicleType = null;
        vehicleBrandCtrl.clear();
        vehicleModelCtrl.clear();
        vehicleSerialNumberCtrl.clear();
      }
    } catch (e) {
      ShowSnackBar.show(context, "Terjadi kesalahan: $e", "error");
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> pickMemberPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked == null) return;

    if (kIsWeb) {
      memberPhotoBytes = await picked.readAsBytes();
      memberPhotoFilename = picked.name;
    } else {
      memberPhotoFile = File(picked.path);
    }

    setState(() {});
  }

  Future<void> save() async {
    try {
      setState(() => loading = true);

      if (selectedMemberId == null) {
        ShowSnackBar.show(context, "Pilih member terlebih dahulu", "error");
        return;
      }

      if (passwordCtrl.text.isNotEmpty &&
          passwordCtrl.text != confirmPasswordCtrl.text) {
        ShowSnackBar.show(context, "Konfirmasi password tidak cocok", "error");
        return;
      }

      // ======================
      // 1️⃣ UPDATE USER
      // ======================
      final userFields = {
        "name": nameCtrl.text.trim(),
        "phone": phoneCtrl.text.trim(),
        "email": emailCtrl.text.trim(),
      };

      if (passwordCtrl.text.isNotEmpty) {
        userFields["password"] = passwordCtrl.text;
      }

      final userRes = await ApiService.put("me", body: userFields);

      if (userRes.statusCode != 200) {
        final body = jsonDecode(userRes.body);
        ShowSnackBar.show(
          context,
          body["message"] ?? "Gagal memperbarui data user",
          "error",
        );
        return;
      }

      // ======================
      // 2️⃣ UPDATE MEMBER
      // ======================
      final memberFields = {
        "address": addressCtrl.text.trim(),
        "city": cityCtrl.text.trim(),
        "vehicle_type": selectedVehicleType ?? "",
        "vehicle_brand": vehicleBrandCtrl.text.trim(),
        "vehicle_model": vehicleModelCtrl.text.trim(),
        "vehicle_serial_number": vehicleSerialNumberCtrl.text.trim(),
      };

      final endpoint = "member/$selectedMemberId";
      late final memberRes;

      // ======================
      // 📸 JIKA ADA FOTO → POST + _method=PUT
      // ======================
      if (kIsWeb && memberPhotoBytes != null) {
        memberRes = await ApiService.multipartPostBytes(
          endpoint,
          fields: {
            ...memberFields,
            "_method": "PUT", // 🔥 KUNCI
          },
          bytes: memberPhotoBytes!,
          filename: memberPhotoFilename!,
          fieldName: "member_photo",
        );
      } else if (!kIsWeb && memberPhotoFile != null) {
        memberRes = await ApiService.multipartPost(
          endpoint,
          fields: {
            ...memberFields,
            "_method": "PUT", // 🔥 KUNCI
          },
          files: {"member_photo": memberPhotoFile!},
        );
      }
      // ======================
      // TANPA FOTO → PUT BIASA
      // ======================
      else {
        memberRes = await ApiService.put(endpoint, body: memberFields);
      }

      if (memberRes.statusCode != 200) {
        final body = await readResponseBody(memberRes);
        ShowSnackBar.show(
          context,
          body["message"] ?? "Gagal memperbarui data member",
          "error",
        );
        return;
      }

      Navigator.pop(context);
      ShowSnackBar.show(context, "Profil berhasil diperbarui", "success");
    } catch (e) {
      ShowSnackBar.show(context, "Terjadi kesalahan: $e", "error");
    } finally {
      setState(() => loading = false);
    }
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

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.90,
      maxChildSize: 0.95,
      minChildSize: 0.50,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF6F9FC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          children: [
            // ==========================
            // HEADER BLUE
            // ==========================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 30, 22, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1F3C88), Color(0xFF3A6EA5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: Row(
                children: const [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.edit, color: Color(0xFF1F3C88)),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Edit Profil",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // ==========================
            // FORM
            // ==========================
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(22),
                children: [
                  _card(
                    title: "Data Pribadi",
                    children: [
                      _input("Nama Lengkap", nameCtrl),
                      const SizedBox(height: 14),
                      _input(
                        "No Telepon",
                        phoneCtrl,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 14),
                      _input(
                        "Email",
                        emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),
                      _input("Alamat", addressCtrl, maxLines: 3),
                      const SizedBox(height: 14),
                      _input("Kota/Kabupaten", cityCtrl, maxLines: 3),
                    ],
                  ),

                  // ==========================
                  // PILIH MEMBER
                  // ==========================
                  if (members.isNotEmpty)
                    _card(
                      title: "Pilih Member",
                      children: [
                        DropdownButtonFormField<int>(
                          value: selectedMemberId,
                          isExpanded: true,
                          hint: const Text("Pilih Member"),
                          items: members.map((m) {
                            return DropdownMenuItem<int>(
                              value: m["id"],
                              child: Text(
                                "${m["vehicle_type"] ?? "-"} • ${m["vehicle_brand"] ?? "-"}",
                              ),
                            );
                          }).toList(),
                          onChanged: (id) {
                            if (id == null) return;
                            final member = members.firstWhere(
                              (m) => m["id"] == id,
                            );
                            selectMember(member);
                          },
                        ),
                      ],
                    ),

                  _card(
                    title: "Foto Member",
                    children: [
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            // ======================
                            // FOTO (PREVIEW)
                            // ======================
                            GestureDetector(
                              onTap: () {
                                final image = _memberPhotoProvider();
                                if (image != null) {
                                  showFullImage(context, image);
                                }
                              },
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: const Color(0xFFF4F6FA),
                                backgroundImage: _memberPhotoProvider(),
                                child: _memberPhotoProvider() == null
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Icon(
                                            Icons.person,
                                            size: 36,
                                            color: Color(0xFF1F3C88),
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            "Belum ada foto",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF1F3C88),
                                            ),
                                          ),
                                        ],
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
                                onTap: selectedMember != null
                                    ? pickMemberPhoto
                                    : null,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1F3C88),
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
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Tap foto untuk melihat full screen\nTekan ikon kamera untuk mengganti foto",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),

                  _card(
                    title: "Data Kendaraan",
                    children: [
                      _vehicleDropdown(),
                      const SizedBox(height: 14),
                      _input("Merk Kendaraan", vehicleBrandCtrl),
                      const SizedBox(height: 14),
                      _input("Model Kendaraan", vehicleModelCtrl),
                      const SizedBox(height: 14),
                      _input("Nomor Rangka (Serial)", vehicleSerialNumberCtrl),
                    ],
                  ),

                  _card(
                    title: "Keamanan Akun",
                    children: [
                      _passwordInput(
                        "Password Baru (opsional)",
                        passwordCtrl,
                        showPassword,
                        () => setState(() => showPassword = !showPassword),
                      ),
                      const SizedBox(height: 14),
                      _passwordInput(
                        "Konfirmasi Password",
                        confirmPasswordCtrl,
                        showConfirmPassword,
                        () => setState(
                          () => showConfirmPassword = !showConfirmPassword,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Kosongkan jika tidak ingin mengubah password",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),

                  _saveButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================
  // CUSTOM INPUT FIELD
  // ==========================
  Widget _input(
    String label,
    TextEditingController controller, {
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F3C88),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: icon != null
                ? Icon(icon, color: const Color(0xFF1F3C88))
                : null,
            filled: true,
            fillColor: Colors.white,
            hintText: label,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFD0D7E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFD0D7E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF3A6EA5),
                width: 1.6,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _card({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F3C88),
            ),
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }

  Widget _vehicleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tipe Kendaraan",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F3C88),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD0D7E1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedVehicleType,
              hint: const Text("Pilih Tipe Kendaraan"),
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: "Motor Listrik",
                  child: Text("Motor Listrik"),
                ),
                DropdownMenuItem(
                  value: "Sepeda Listrik",
                  child: Text("Sepeda Listrik"),
                ),
              ],
              onChanged: selectedMember != null
                  ? (v) => setState(() => selectedVehicleType = v)
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _passwordInput(
    String label,
    TextEditingController controller,
    bool obscure,
    VoidCallback toggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F3C88),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: !obscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD0D7E1)),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: toggle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1F3C88),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 4,
        ),
        onPressed: loading ? null : save,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: loading
              ? const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                )
              : const Text(
                  "Simpan Perubahan",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  ImageProvider? _memberPhotoProvider() {
    // 1️⃣ Foto BARU (prioritas tertinggi)
    if (kIsWeb && memberPhotoBytes != null) {
      return MemoryImage(memberPhotoBytes!);
    }

    if (!kIsWeb && memberPhotoFile != null) {
      return FileImage(memberPhotoFile!);
    }

    // 2️⃣ Foto LAMA dari server (Flutter Web FIX)
    if (memberPhotoUrl != null && memberPhotoUrl!.isNotEmpty) {
      final url = "$memberPhotoUrl?v=${DateTime.now().millisecondsSinceEpoch}";
      return NetworkImage(url);
    }

    return null;
  }
}
