import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/api_service.dart';
import 'dart:convert';
import '../widgets/show_snackbar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DaftarMemberPage extends StatefulWidget {
  const DaftarMemberPage({super.key});

  @override
  State<DaftarMemberPage> createState() => _DaftarMemberPageState();
}

class _DaftarMemberPageState extends State<DaftarMemberPage> {
  // USER (read-only)
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  // MEMBER data
  final brandCtrl = TextEditingController();
  final modelCtrl = TextEditingController();
  final serialCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final cityCtrl = TextEditingController();

  String? selectedVehicleType;
  int? selectedMembership;

  List<Map<String, dynamic>> membershipTypes = [];
  List<dynamic>? selectedBenefits;

  bool loading = false;
  bool loadingMembership = true;
  bool loadingUser = true; // NEW

  bool isAlreadyMember = false;
  Map<String, dynamic>? memberData;

  final ImagePicker picker = ImagePicker();

  File? memberPhotoFile; // MOBILE
  Uint8List? memberPhotoBytes; // WEB
  String? memberPhotoFilename; // WEB

  @override
  void initState() {
    super.initState();
    loadUserData(); // NEW
    loadMembershipTypes();
    initializeDateFormatting('id_ID', null);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    brandCtrl.dispose();
    modelCtrl.dispose();
    serialCtrl.dispose();
    addressCtrl.dispose();
    cityCtrl.dispose();
    super.dispose();
  }

  // ============================
  // LOAD USER PROFILE
  // ============================
  Future<void> loadUserData() async {
    try {
      final res = await ApiService.get("member/profile");
      final data = jsonDecode(res.body);

      if (data["user"] != null) {
        nameCtrl.text = data["user"]["name"] ?? "";
        phoneCtrl.text = data["user"]["phone"] ?? "";
        emailCtrl.text = data["user"]["email"] ?? "";
      }
    } catch (e) {
      _showMsg("Gagal memuat data user", isError: true);
    } finally {
      setState(() => loadingUser = false);
    }
  }

  // ============================
  // LOAD MEMBERSHIP TYPES
  // ============================
  Future<void> loadMembershipTypes() async {
    try {
      final res = await ApiService.get("membership-types");
      final data = jsonDecode(res.body);

      if (data['success'] == true) {
        membershipTypes = (data['types'] as List).map((item) {
          return {
            "id": item['id'],
            "name": item['name'],
            "duration": item['duration_months'],
            "benefits": item['benefits'],
          };
        }).toList();
      }
    } catch (e) {
      _showMsg("Gagal memuat tipe membership", isError: true);
    } finally {
      setState(() => loadingMembership = false);
    }
  }

  Future<void> pickMemberPhoto({
    ImageSource source = ImageSource.gallery,
  }) async {
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1024,
    );

    if (picked == null) return;

    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      setState(() {
        memberPhotoBytes = bytes;
        memberPhotoFilename = picked.name;
        memberPhotoFile = null;
      });
    } else {
      setState(() {
        memberPhotoFile = File(picked.path);
        memberPhotoBytes = null;
        memberPhotoFilename = null;
      });
    }
  }

  // ============================
  // SUBMIT FORM
  // ============================
  Future<void> daftar() async {
    // =====================
    // VALIDASI
    // =====================
    if (selectedMembership == null) {
      _showMsg("Pilih jenis membership", isError: true);
      return;
    }

    if (selectedVehicleType == null ||
        brandCtrl.text.isEmpty ||
        modelCtrl.text.isEmpty ||
        serialCtrl.text.isEmpty) {
      _showMsg("Lengkapi data kendaraan", isError: true);
      return;
    }

    if (kIsWeb) {
      if (memberPhotoBytes == null || memberPhotoFilename == null) {
        _showMsg("Upload foto member terlebih dahulu", isError: true);
        return;
      }
    } else {
      if (memberPhotoFile == null) {
        _showMsg("Upload foto member terlebih dahulu", isError: true);
        return;
      }
    }

    try {
      setState(() => loading = true);

      // =====================
      // WEB
      // =====================
      if (kIsWeb) {
        final response = await ApiService.multipartPostBytes(
          "member/register",
          fields: {
            "membership_type_id": selectedMembership.toString(),
            "vehicle_type": selectedVehicleType!,
            "vehicle_brand": brandCtrl.text,
            "vehicle_model": modelCtrl.text,
            "vehicle_serial_number": serialCtrl.text,
            "address": addressCtrl.text,
            "city": cityCtrl.text,
          },
          bytes: memberPhotoBytes!,
          filename: memberPhotoFilename!,
          fieldName: "member_photo",
        );

        final body = await response.stream.bytesToString();
        final data = jsonDecode(body);

        _handleRegisterResponse(response.statusCode, data);
      }
      // =====================
      // MOBILE
      // =====================
      else {
        final response = await ApiService.multipartPost(
          "member/register",
          fields: {
            "membership_type_id": selectedMembership.toString(),
            "vehicle_type": selectedVehicleType!,
            "vehicle_brand": brandCtrl.text,
            "vehicle_model": modelCtrl.text,
            "vehicle_serial_number": serialCtrl.text,
            "address": addressCtrl.text,
            "city": cityCtrl.text,
          },
          files: {"member_photo": memberPhotoFile!},
        );

        final body = await response.stream.bytesToString();
        final data = jsonDecode(body);

        _handleRegisterResponse(response.statusCode, data);
      }
    } catch (e) {
      _showMsg("Error: $e", isError: true);
    } finally {
      setState(() => loading = false);
    }
  }

  void _handleRegisterResponse(int statusCode, Map data) {
    if (statusCode >= 200 && statusCode < 300) {
      if (data["success"] == true) {
        _showMsg("Pendaftaran berhasil. Foto menunggu verifikasi admin");

        brandCtrl.clear();
        modelCtrl.clear();
        serialCtrl.clear();
        addressCtrl.clear();
        cityCtrl.clear();

        setState(() {
          selectedVehicleType = null;
          selectedMembership = null;
          selectedBenefits = null;
          memberPhotoFile = null;
          memberPhotoBytes = null;
          memberPhotoFilename = null;
        });
      } else {
        _showMsg(data["message"] ?? "Pendaftaran gagal", isError: true);
      }
    } else {
      _showMsg(data["message"] ?? "Terjadi kesalahan server", isError: true);
    }
  }

  void _showPhotoSourcePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Ambil dari Kamera"),
              onTap: () {
                Navigator.pop(context);
                pickMemberPhoto(source: ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Pilih dari Galeri"),
              onTap: () {
                Navigator.pop(context);
                pickMemberPhoto(source: ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMsg(String msg, {bool isError = false}) {
    ShowSnackBar.show(context, msg, isError ? "error" : "success");
  }

  String formatDate(String isoDate) {
    final date = DateTime.parse(isoDate).toLocal();
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  // ============================
  // UI
  // ============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
      body: Column(
        children: [
          _header(),
          const SizedBox(height: 30),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  loadingUser
                      ? const Center(child: CupertinoActivityIndicator())
                      : _formContent(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
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
                "Daftar Membership",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Lengkapi data untuk menjadi member",
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _formContent() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Data User", icon: CupertinoIcons.person_crop_circle),
          const SizedBox(height: 12),

          _readOnlyField(nameCtrl, "Nama Lengkap", CupertinoIcons.person_fill),
          const SizedBox(height: 16),
          _readOnlyField(emailCtrl, "Email", CupertinoIcons.mail_solid),
          const SizedBox(height: 16),
          _readOnlyField(phoneCtrl, "Nomor HP", CupertinoIcons.phone_fill),

          const SizedBox(height: 24),

          const SizedBox(height: 24),
          _sectionTitle("Foto Member", icon: Icons.person),
          const SizedBox(height: 12),

          InkWell(
            onTap: () {
              if (kIsWeb) {
                pickMemberPhoto(); // web langsung galeri
              } else {
                _showPhotoSourcePicker();
              }
            },
            child: Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFFF4F6FA),

                // =====================
                // IMAGE PREVIEW (WEB + MOBILE)
                // =====================
                backgroundImage: kIsWeb
                    ? (memberPhotoBytes != null
                          ? MemoryImage(memberPhotoBytes!)
                          : null)
                    : (memberPhotoFile != null
                          ? FileImage(memberPhotoFile!)
                          : null),

                child:
                    (kIsWeb && memberPhotoBytes == null) ||
                        (!kIsWeb && memberPhotoFile == null)
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, color: primaryColor, size: 30),
                          SizedBox(height: 6),
                          Text(
                            "Upload Foto",
                            style: TextStyle(color: primaryColor),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
          ),

          _sectionTitle("Tipe Membership", icon: Icons.card_membership),
          const SizedBox(height: 12),

          loadingMembership
              ? const Center(child: CupertinoActivityIndicator())
              : DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: "Tipe Membership",
                    filled: true,
                    fillColor: const Color(0xFFF4F6FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  value: selectedMembership,
                  items: membershipTypes.map((item) {
                    return DropdownMenuItem<int>(
                      value: item['id'],
                      child: Text(
                        "${item['name']} (${item['duration']} bulan)",
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedMembership = value;
                      selectedBenefits = membershipTypes.firstWhere(
                        (t) => t['id'] == value,
                      )['benefits'];
                    });
                  },
                ),

          if (selectedBenefits != null) _benefitsList(selectedBenefits!),

          const SizedBox(height: 24),
          _sectionTitle("Data Kendaraan", icon: Icons.electric_bike),
          const SizedBox(height: 12),

          _dropdown(
            hint: "Pilih Tipe Kendaraan",
            value: selectedVehicleType,
            items: const ["Motor Listrik", "Sepeda Listrik"],
            onChanged: (v) => setState(() => selectedVehicleType = v),
          ),

          const SizedBox(height: 16),
          _inputField(
            brandCtrl,
            "Merek Kendaraan",
            CupertinoIcons.car_detailed,
          ),
          const SizedBox(height: 16),
          _inputField(
            modelCtrl,
            "Model Kendaraan",
            CupertinoIcons.gear_alt_fill,
          ),
          const SizedBox(height: 16),
          _inputField(
            serialCtrl,
            "Nomor Seri / Serial Number",
            CupertinoIcons.barcode_viewfinder,
          ),

          const SizedBox(height: 24),
          _sectionTitle("Alamat", icon: Icons.location_on),
          const SizedBox(height: 12),

          _inputField(
            addressCtrl,
            "Alamat Lengkap",
            CupertinoIcons.location_solid,
          ),
          const SizedBox(height: 16),
          _inputField(cityCtrl, "Kota / Kabupaten", CupertinoIcons.map_fill),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loading ? null : daftar,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: primaryColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: loading
                  ? const CupertinoActivityIndicator(color: Colors.white)
                  : const Text(
                      "Daftarkan Member",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (icon != null) Icon(icon, color: primaryColor, size: 20),
          if (icon != null) const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _readOnlyField(TextEditingController c, String label, IconData icon) {
    return TextField(
      controller: c,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF1F3C88)),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController c, String label, IconData icon) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF1F3C88)),
        filled: true,
        fillColor: const Color(0xFFF4F6FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _dropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF4F6FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      items: items
          .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      hint: Text(hint),
    );
  }

  Widget _benefitsList(List benefits) {
    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor.withOpacity(0.08), Colors.white],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Keuntungan Membership",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F3C88),
            ),
          ),
          const SizedBox(height: 12),
          ...benefits.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(b, style: const TextStyle(fontSize: 14)),
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

const primaryColor = Color(0xFF1F3C88);
const secondaryColor = Color(0xFF3A6EA5);
const bgColor = Color(0xFFF6F9FC);
