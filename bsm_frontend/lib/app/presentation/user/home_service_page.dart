import 'dart:typed_data';
import 'package:bsm_frontend/utils/constants.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../services/api_service.dart';
import 'home_service_history_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import "../widgets/show_snackbar.dart";

class HomeServicePage extends StatefulWidget {
  const HomeServicePage({super.key});

  @override
  _HomeServicePageState createState() => _HomeServicePageState();
}

class _HomeServicePageState extends State<HomeServicePage> {
  final serviceTypeCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final problemDescCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  final vehicleTypeCtrl = TextEditingController();
  final vehicleBrandCtrl = TextEditingController();
  final vehicleModelCtrl = TextEditingController();
  final vehicleSerialCtrl = TextEditingController();

  DateTime? scheduleDate;
  TimeOfDay? scheduleTime;
  String? scheduleTimeStr;
  bool loading = false;

  File? selectedImageFile; // Untuk Mobile
  Uint8List? selectedImageBytes; // Untuk Web
  String? selectedImageName; // Nama file (Wajib Web)
  String? uploadedPhoto; // Setelah berhasil upload, isi nama file dari server

  bool hasActiveService = false;
  Map<String, dynamic>? activeService;

  Future pickDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
    );
    if (selected != null) setState(() => scheduleDate = selected);
  }

  Future pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (selected != null) {
      setState(() {
        scheduleTime = selected;
        scheduleTimeStr =
            "${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  Future pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? img = await picker.pickImage(source: ImageSource.gallery);

    if (img != null) {
      if (kIsWeb) {
        // WEB
        selectedImageBytes = await img.readAsBytes();
        selectedImageName = img.name;
      } else {
        // MOBILE
        selectedImageFile = File(img.path);
      }

      setState(() {});
    }
  }

  void _removePhoto() {
    setState(() {
      selectedImageFile = null;
      selectedImageBytes = null;
      selectedImageName = null;
      uploadedPhoto = null;
    });
  }

  void _showFullscreenImage(ImageProvider image) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (_) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: InteractiveViewer(child: Image(image: image)),
          ),
        ),
      ),
    );
  }

  Future<void> registerHomeService() async {
  // =========================
  // ✅ VALIDASI FORM WAJIB
  // =========================
  if (serviceTypeCtrl.text.isEmpty ||
      scheduleDate == null ||
      scheduleTime == null) {
    ShowSnackBar.show(
      context,
      "Semua field wajib diisi!",
      "warning",
    );
    return;
  }

  // =========================
  // 🚫 CEK HOME SERVICE AKTIF
  // =========================
  if (hasActiveService) {
    ShowSnackBar.show(
      context,
      "Anda masih memiliki Home Service yang sedang diproses",
      "warning",
    );
    return;
  }

  setState(() => loading = true);

  try {
    final response = await ApiService.registerHomeService(
      serviceType: serviceTypeCtrl.text.trim(),

      scheduleDate:
          "${scheduleDate!.year}-${scheduleDate!.month.toString().padLeft(2, '0')}-${scheduleDate!.day.toString().padLeft(2, '0')}",

      scheduleTime: formatTimeOfDay(scheduleTime!), // ✅ TIDAK KOSONG

      address: addressCtrl.text.isNotEmpty
          ? addressCtrl.text.trim()
          : memberData?["address"],

      city: cityCtrl.text.isNotEmpty
          ? cityCtrl.text.trim()
          : memberData?["city"],

      problemDescription: problemDescCtrl.text.isNotEmpty
          ? problemDescCtrl.text.trim()
          : null,

      photoBytes: selectedImageBytes,
      filename: selectedImageName,
      photoFile: selectedImageFile,
    );

    setState(() => loading = false);

    if (response["success"] == true) {
      ShowSnackBar.show(
        context,
        "Berhasil membuat permintaan!",
        "success",
      );

      // =========================
      // 🔄 RESET FORM
      // =========================
      serviceTypeCtrl.clear();
      addressCtrl.clear();
      cityCtrl.clear();
      problemDescCtrl.clear();

      selectedImageFile = null;
      selectedImageBytes = null;
      selectedImageName = null;

      setState(() {});
    } else {
      ShowSnackBar.show(
        context,
        response["message"] ?? "Gagal mengirim permintaan",
        "error",
      );
    }
  } catch (e) {
    setState(() => loading = false);
    ShowSnackBar.show(
      context,
      "Terjadi kesalahan: $e",
      "error",
    );
  }
}

  Future checkActiveHomeService() async {
    final res = await ApiService.get("home-services/active");

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      if (data["success"] == true && data["data"] != null) {
        setState(() {
          hasActiveService = true;
          activeService = data["data"];
        });
      }
    }
  }

String formatTimeOfDay(TimeOfDay time) {
  final h = time.hour.toString().padLeft(2, '0');
  final m = time.minute.toString().padLeft(2, '0');
  return "$h:$m";
}

  Map<String, dynamic>? memberData;

  @override
  void initState() {
    super.initState();
    fetchMemberData();
    checkActiveHomeService();
  }

  Future fetchMemberData() async {
    final response = await ApiService.get("member/profile-member");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // JIKA BUKAN MEMBER
      if (data["success"] == false || data["data"] == null) {
        ShowSnackBar.show(
          context,
          "Anda belum menjadi member. Tidak bisa mengajukan Home Service.",
          "error",
        );

        // Kembali ke halaman sebelumnya
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
        return;
      }

      // JIKA MEMBER → lanjut isi data form
      setState(() {
        memberData = data["data"];
        vehicleTypeCtrl.text = memberData?["vehicle_type"] ?? "";
        vehicleBrandCtrl.text = memberData?["vehicle_brand"] ?? "";
        vehicleModelCtrl.text = memberData?["vehicle_model"] ?? "";
        vehicleSerialCtrl.text = memberData?["vehicle_serial_number"] ?? "";
        addressCtrl.text = memberData?["address"] ?? "";
        cityCtrl.text = memberData?["city"] ?? "";
        problemDescCtrl.text = "";
      });
    } else {
      // Jika API error
      ShowSnackBar.show(
        context,
        "Anda belum menjadi member. Tidak bisa mengajukan Home Service.",
        "error",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xff0054A5);

    return Scaffold(
      body: Column(
        children: [
          // ================= HEADER =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff004B92), Color(0xff0054A5)],
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
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Home Service",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Ajukan permintaan home service",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ================= CONTENT =================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  // INFO ACTIVE SERVICE
                  if (hasActiveService) _activeServiceInfo(),

                  // FORM (LOCKED JIKA ADA ACTIVE SERVICE)
                  IgnorePointer(
                    ignoring: hasActiveService,
                    child: Opacity(
                      opacity: hasActiveService ? 0.5 : 1,
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            inputLabel("Jenis Layanan"),
                            inputField(
                              serviceTypeCtrl,
                              "Jenis Layanan",
                              icon: Icons.medical_services_outlined,
                            ),

                            inputLabel("Tanggal Kunjungan"),
                            pickDateWidget(),

                            inputLabel("Jam Kunjungan"),
                            pickTimeWidget(),

                            inputLabel("Tipe Kendaraan"),
                            _readonlyField(vehicleTypeCtrl),

                            inputLabel("Merek Kendaraan"),
                            _readonlyField(vehicleBrandCtrl),

                            inputLabel("Model Kendaraan"),
                            _readonlyField(vehicleModelCtrl),

                            inputLabel("Nomor Rangka / Seri Kendaraan"),
                            _readonlyField(vehicleSerialCtrl),

                            inputLabel("Alamat"),
                            inputField(
                              addressCtrl,
                              "Masukkan alamat",
                              icon: Icons.location_on_outlined,
                              maxLines: 2,
                            ),

                            inputLabel("Kota (opsional)"),
                            inputField(
                              cityCtrl,
                              "Contoh: Bandung",
                              icon: Icons.location_city,
                            ),

                            inputLabel("Deskripsi Masalah (opsional)"),
                            inputField(
                              problemDescCtrl,
                              "Jelaskan masalah",
                              icon: Icons.info_outline,
                              maxLines: 3,
                            ),

                            inputLabel("Foto Masalah (opsional)"),
                            _uploadPhotoWidget(),

                            const SizedBox(height: 25),

                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const HomeServiceHistoryPage(),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.history),
                                    label: const Text("Riwayat"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey.shade600,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: loading || hasActiveService
                                        ? null
                                        : registerHomeService,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: loading
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : const Text(
                                            "Kirim Permintaan",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _readonlyField(TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      enabled: false,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _uploadPhotoWidget() {
    ImageProvider? imageProvider;

    if (selectedImageFile != null) {
      imageProvider = FileImage(selectedImageFile!);
    } else if (selectedImageBytes != null) {
      imageProvider = MemoryImage(selectedImageBytes!);
    } else if (uploadedPhoto != null) {
      imageProvider = NetworkImage(
        "${AppConfig.baseUrl}/storage/$uploadedPhoto",
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ================= BUTTON UPLOAD =================
        GestureDetector(
          onTap: pickImage,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.camera_alt_outlined),
                const SizedBox(width: 10),
                Text(
                  imageProvider != null ? "Ganti Foto" : "Upload Foto",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),

        // ================= PREVIEW FOTO =================
        if (imageProvider != null)
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => _showFullscreenImage(imageProvider!),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image(
                      image: imageProvider,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // ===== BUTTON HAPUS =====
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: _removePhoto,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // WIDGET REUSABLE
  Widget inputLabel(String text) => Padding(
    padding: const EdgeInsets.only(top: 14, bottom: 6),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
  );

  Widget inputField(
    TextEditingController controller,
    String hint, {
    IconData? icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget pickDateWidget() {
    return GestureDetector(
      onTap: pickDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade100,
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today),
            const SizedBox(width: 10),
            Text(
              scheduleDate == null
                  ? "Pilih tanggal"
                  : "${scheduleDate!.day.toString().padLeft(2, '0')}-"
                        "${scheduleDate!.month.toString().padLeft(2, '0')}-"
                        "${scheduleDate!.year}",
            ),
          ],
        ),
      ),
    );
  }

  Widget pickTimeWidget() {
    return GestureDetector(
      onTap: pickTime,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade100,
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time),
            const SizedBox(width: 10),
            Text(
              scheduleTime == null
                  ? "Pilih jam"
                  : formatTimeOfDay(scheduleTime!), // gunakan format 24 jam
            ),
          ],
        ),
      ),
    );
  }

  Widget _activeServiceInfo() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.orange.shade100],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.orange.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 54,
          ),
          const SizedBox(height: 12),
          const Text(
            "Home Service Sedang Berjalan",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            "Status: ${activeService?['status']?.toString().replaceAll('_', ' ').toUpperCase()}",
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            "Anda tidak dapat mengajukan Home Service baru\nselama permintaan ini belum selesai.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.history),
              label: const Text("Lihat Riwayat"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HomeServiceHistoryPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
