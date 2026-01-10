import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../widgets/show_snackbar.dart';

class HomeServiceAdminPage extends StatefulWidget {
  const HomeServiceAdminPage({super.key});

  @override
  State<HomeServiceAdminPage> createState() => _HomeServiceAdminPageState();
}

class _HomeServiceAdminPageState extends State<HomeServiceAdminPage> {
  final TextEditingController searchController = TextEditingController();

  List<dynamic> homeServices = [];
  bool isLoading = true;
  int currentPage = 1, lastPage = 1;
  String search = "";
  DateTime? lastSearch;
  final TextEditingController workNotesC = TextEditingController();
  File? completionPhoto;
  Uint8List? completionPhotoBytes; // khusus WEB
  String? uploadedCompletionPhotoUrl; // hasil upload (opsional)
  bool isUploadingPhoto = false;
  bool isFinishingWork = false;

  @override
  void initState() {
    super.initState();
    fetchHomeServices();
  }

  // ===========================================================
  // FETCH DATA
  // ===========================================================
  Future<void> fetchHomeServices({int page = 1, bool refresh = false}) async {
    if (refresh && mounted) {
      setState(() => isLoading = true);
    }

    try {
      final res = await ApiService.get(
        "admin/home-services?page=$page&search=$search",
      );

      if (!mounted) return;

      if (res.statusCode != 200) {
        debugPrint("Status Code: ${res.statusCode}");
        setState(() => isLoading = false);
        return;
      }

      final body = jsonDecode(res.body);
      final pagination = body["home_service"] ?? {};
      final List items = pagination["data"] ?? [];
      // 🔍 DEBUG STATUS DARI API
      for (var item in items) {
        debugPrint("STATUS DARI API: ${item['status']}");
      }

      setState(() {
        homeServices = items;
        currentPage = pagination["current_page"] ?? 1;
        lastPage = pagination["last_page"] ?? 1;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("ERROR FETCH: $e");

      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  // ===========================================================
  // UPDATE STATUS
  // ===========================================================
  Future<void> updateStatus(int id, String newStatus) async {
    final index = homeServices.indexWhere((e) => e['id'] == id);
    if (index == -1) return;

    final currentStatus = homeServices[index]['status'];

    // 🔒 STATUS DONE TIDAK BOLEH DIUBAH
    if (currentStatus == 'done') {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ShowSnackBar.show(
        context,
        "Status sudah selesai dan tidak dapat diubah",
        "warning",
      );

      return;
    }

    // ⛔ STATUS SAMA → TIDAK PERLU API CALL
    if (currentStatus == newStatus) return;

    try {
      final res = await ApiService.patch("admin/home-services/$id/status", {
        "status": newStatus,
      });

      if (res.statusCode == 200) {
        setState(() {
          homeServices[index]['status'] = newStatus;
        });

        ShowSnackBar.show(context, "Status berhasil diperbarui", "success");
      }
    } catch (e) {
      debugPrint("ERROR UPDATE STATUS: $e");
    }
  }

  Future<void> finishWork(
    int id,
    String notes, {
    Uint8List? photoBytes,
    String? filename,
    File? photoFile,
  }) async {
    if (isFinishingWork) return; // 🔒 cegah double submit

    setState(() => isFinishingWork = true);

    try {
      final result = await ApiService.finishWork(
        id: id,
        workNotes: notes,
        photoBytes: photoBytes,
        filename: filename,
        photoFile: photoFile,
      );

      if (!mounted) return;

      if (result["success"] == true) {
        await fetchHomeServices(refresh: true); // ⏳ tunggu refresh selesai

        if (!mounted) return;

        if (result['success'] == true) {
          ShowSnackBar.show(
            context,
            "Pekerjaan berhasil diselesaikan",
            "success",
          );
        } else {
          ShowSnackBar.show(
            context,
            result["message"] ?? "Gagal menyelesaikan pekerjaan",
            "error",
          );
        }
      }
    } catch (e) {
      debugPrint("ERROR FINISH WORK: $e");
    } finally {
      if (mounted) {
        setState(() => isFinishingWork = false);
      }
    }
  }

  Future<void> pickCompletionPhoto(StateSetter modalSetState) async {
    final picker = ImagePicker();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Ambil dari Kamera"),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Pilih dari Galeri"),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final picked = await picker.pickImage(source: source, imageQuality: 75);

    if (picked == null) return;

    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      modalSetState(() {
        completionPhotoBytes = bytes;
        completionPhoto = null;
        uploadedCompletionPhotoUrl = null;
      });
    } else {
      modalSetState(() {
        completionPhoto = File(picked.path);
        completionPhotoBytes = null;
        uploadedCompletionPhotoUrl = null;
      });
    }
  }

  Future<void> confirmUpdateStatus(int id, String status) async {
    final color = statusDialogColor(status);
    final icon = statusDialogIcon(status);

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ICON
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),

              const SizedBox(height: 14),

              // TITLE
              const Text(
                "Konfirmasi Perubahan Status",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              // CONTENT
              Text(
                "Apakah Anda yakin ingin mengubah status menjadi\n\n"
                "${status.replaceAll('_', ' ').toUpperCase()}?",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 22),

              // ACTION BUTTONS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text("Batal"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        "Ya, Ubah",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // ✅ teks putih
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
    );

    if (ok == true) {
      updateStatus(id, status);
    }
  }

  Color statusDialogColor(String status) {
    switch (status) {
      case "approved":
        return Colors.blue;
      case "on_process":
        return Colors.deepPurple;
      case "done":
        return Colors.green;
      case "canceled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData statusDialogIcon(String status) {
    switch (status) {
      case "approved":
        return Icons.check_circle_outline;
      case "on_process":
        return Icons.autorenew;
      case "done":
        return Icons.task_alt;
      case "canceled":
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  // ===========================================================
  // STATUS BADGE
  // ===========================================================
  Color statusColor(String s) {
    switch (s) {
      case "pending":
        return Colors.orange;
      case "approved":
        return Colors.blue;
      case "on_process":
        return Colors.deepPurple;
      case "done":
        return Colors.green;
      case "canceled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData statusIcon(String s) {
    switch (s) {
      case "pending":
        return Icons.schedule;
      case "approved":
        return Icons.check_circle;
      case "on_process":
        return Icons.autorenew;
      case "done":
        return Icons.task_alt;
      case "canceled":
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  Widget statusBadge(String s) {
    final color = statusColor(s);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon(s), size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            s.replaceAll("_", " ").toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: primaryColor),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // DETAIL MODAL
  // ===========================================================
  void showDetailModal(dynamic item) {
    // ================= RESET STATE =================
    workNotesC.clear();
    completionPhoto = null;
    completionPhotoBytes = null;
    uploadedCompletionPhotoUrl = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.85,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  padding: EdgeInsets.only(
                    left: 22,
                    right: 22,
                    top: 14,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 22,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.04),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ================= HEADER =================
                        _detailHeader(),
                        const SizedBox(height: 18),

                        // ================= DATA =================
                        sectionTitle("Data Pelanggan", Icons.person_outline),
                        _infoCard([
                          detailItem("Nama", item['user']?['name'] ?? "-"),
                          detailItem("No HP", item['user']?['phone'] ?? "-"),
                          detailItem("Email", item['user']?['email'] ?? "-"),
                          detailItem("Alamat Lengkap", item['address'] ?? "-"),
                        ]),

                        sectionTitle("Detail Layanan", Icons.build_outlined),
                        _infoCard([
                          detailItem(
                            "Jenis Layanan",
                            item['service_type'] ?? "-",
                          ),
                          detailItem(
                            "Tanggal",
                            formatDate(item['schedule_date']),
                          ),
                          detailItem(
                            "Waktu",
                            formatTime(item['schedule_time']),
                          ),
                          detailItem("Status", item['status'] ?? "-"),
                        ]),

                        sectionTitle("Kendaraan", Icons.electric_bike_outlined),
                        _infoCard([
                          detailItem(
                            "Jenis Kendaraan",
                            item['member']?['vehicle_type'] ?? "-",
                          ),
                          detailItem(
                            "Merk",
                            item['member']?['vehicle_brand'] ?? "-",
                          ),
                          detailItem(
                            "Model",
                            item['member']?['vehicle_model'] ?? "-",
                          ),
                          detailItem(
                            "No Rangka",
                            item['member']?['vehicle_serial_number'] ?? "-",
                          ),
                        ]),

                        sectionTitle("Foto Masalah", Icons.image_outlined),
                        _infoCard([
                          problemPhoto(
                            context: context,
                            photoPath: item['problem_photo'],
                          ),
                          const SizedBox(height: 12),
                          detailItem(
                            "Deskripsi Masalah",
                            item['problem_description'] ?? "-",
                          ),
                        ]),

                        // ================= HASIL PEKERJAAN =================
                        if (item['status'] == 'done') ...[
                          sectionTitle(
                            "Hasil Pengerjaan",
                            Icons.assignment_turned_in,
                          ),

                          _infoCard([
                            // 📝 CATATAN PEKERJAAN
                            detailItem(
                              "Catatan Pengerjaan",
                              item['work_notes']?.toString().isNotEmpty == true
                                  ? item['work_notes']
                                  : "-",
                            ),

                            const SizedBox(height: 14),

                            // 📸 FOTO PENYELESAIAN
                            completionResultPhoto(
                              context: context,
                              photoPath: item['completion_photo'],
                            ),
                          ]),
                        ],

                        const SizedBox(height: 26),

                        // ================= FORM PENYELESAIAN =================
                        if (item['status'] == 'on_process') ...[
                          sectionTitle(
                            "Penyelesaian Pekerjaan",
                            Icons.task_alt,
                          ),

                          _infoCard([
                            // 📝 CATATAN
                            TextField(
                              controller: workNotesC,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: "Catatan pengerjaan...",
                                prefixIcon: const Icon(
                                  Icons.edit_note_outlined,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // 📸 PICK FOTO
                            completionPhotoPicker(() {
                              pickCompletionPhoto(modalSetState);
                            }),
                          ]),

                          const SizedBox(height: 20),

                          // ✅ SUBMIT
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                              label: isFinishingWork
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      "Selesaikan Pekerjaan",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: isFinishingWork
                                  ? null
                                  : () {
                                      if (workNotesC.text.trim().isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).hideCurrentSnackBar();

                                        ShowSnackBar.show(
                                          context,
                                          "Catatan pekerjaan wajib diisi",
                                          "error",
                                        );
                                        return;
                                      }

                                      Navigator.pop(context);

                                      finishWork(
                                        item['id'],
                                        workNotesC.text,
                                        photoFile: completionPhoto,
                                        photoBytes: completionPhotoBytes,
                                      );
                                    },
                            ),
                          ),

                          const SizedBox(height: 14),
                        ],

                        // ================= TUTUP =================
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Tutup"),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void showFinishWorkModal(dynamic item) {
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Selesaikan Pekerjaan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Catatan pekerjaan...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Simpan & Tandai Selesai",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    finishWork(item['id'], notesController.text);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget completionResultPhoto({
    required BuildContext context,
    String? photoPath,
  }) {
    if (photoPath == null || photoPath.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Text(
          "Tidak ada foto penyelesaian",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final imageUrl = ApiService.imageUrl(photoPath);

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            insetPadding: const EdgeInsets.all(16),
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: Image.network(
                imageUrl,
                headers: ApiService.imageHeaders(),
              ),
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.network(
              imageUrl,
              headers: ApiService.imageHeaders(),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  height: 200,
                  alignment: Alignment.center,
                  color: Colors.grey.shade200,
                  child: const Text(
                    "Gagal memuat foto",
                    style: TextStyle(color: Colors.red),
                  ),
                );
              },
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.zoom_in, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget completionPhotoPicker(VoidCallback onPick) {
    final hasImage = completionPhoto != null || completionPhotoBytes != null;

    return GestureDetector(
      onTap: onPick,
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: !hasImage
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.camera_alt_outlined, size: 36),
                  SizedBox(height: 6),
                  Text("Upload Foto (Opsional)"),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: kIsWeb
                    ? Image.memory(
                        completionPhotoBytes!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : Image.file(
                        completionPhoto!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
              ),
      ),
    );
  }

  Widget problemPhoto({required BuildContext context, String? photoPath}) {
    if (photoPath == null || photoPath.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Text(
          "Tidak ada foto masalah",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final imageUrl = ApiService.imageUrl(photoPath);

    return GestureDetector(
      onTap: () {
        // 🔍 Preview zoom
        showDialog(
          context: context,
          builder: (_) => Dialog(
            insetPadding: const EdgeInsets.all(16),
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: Image.network(
                imageUrl,
                headers: ApiService.imageHeaders(),
              ),
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.network(
              imageUrl,
              headers: ApiService.imageHeaders(),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.grey.shade200),
                  child: const Text(
                    "Gagal memuat foto",
                    style: TextStyle(color: Colors.red),
                  ),
                );
              },
            ),

            // 🔍 Overlay icon
            Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.zoom_in, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget completionPhotoPreview() {
    if (completionPhoto == null &&
        completionPhotoBytes == null &&
        uploadedCompletionPhotoUrl == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Preview Foto Penyelesaian",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: kIsWeb && completionPhotoBytes != null
                ? Image.memory(
                    completionPhotoBytes!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : completionPhoto != null
                ? Image.file(
                    completionPhoto!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    uploadedCompletionPhotoUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _detailHeader() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF111827), Color(0xFF374151)],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.build_circle, color: Colors.white),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            "Detail Home Service",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(Icons.close, size: 22),
          ),
        ),
      ],
    );
  }

  Widget detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 6, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                children: [
                  TextSpan(
                    text: "$label\n",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  TextSpan(text: value, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // STATUS SELECTOR
  // ===========================================================
  void showStatusSelector(dynamic item) {
    if (item['status'] == 'done') return; // 🔒 DOUBLE LOCK

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Ubah Status",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              statusButton(item['id'], "approved", "Disetujui", Colors.blue),
              statusButton(
                item['id'],
                "on_process",
                "Sedang Diproses",
                Colors.purple,
              ),
              statusButton(item['id'], "canceled", "Dibatalkan", Colors.red),
            ],
          ),
        );
      },
    );
  }

  Widget statusButton(int id, String key, String label, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          confirmUpdateStatus(id, key);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white, // 🔥 penting
          elevation: 2,
          shadowColor: color.withOpacity(0.35),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              statusIcon(key), // pakai icon status
              size: 18,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================
  // SEARCH DEBOUNCE
  // ===========================================================
  void onSearchChanged(String v) {
    search = v;
    if (lastSearch != null &&
        DateTime.now().difference(lastSearch!) <
            const Duration(milliseconds: 500))
      return;

    lastSearch = DateTime.now();
    fetchHomeServices(page: 1, refresh: true);
  }

  // ===========================================================
  // UI
  // ===========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F9),
      body: Column(
        children: [
          _header(),

          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _searchBox(),
          ),

          // LIST
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: homeServices.length,
                    itemBuilder: (context, index) {
                      return _serviceCard(homeServices[index]);
                    },
                  ),
          ),

          if (!isLoading) _pagination(),
        ],
      ),
    );
  }

  Widget _header() {
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
          // TITLE
          const Padding(
            padding: EdgeInsets.only(left: 44),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(
                  "Kelola Home Service",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Pantau & kelola permintaan layanan",
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ],
            ),
          ),

          // BACK
          Positioned(
            left: 0,
            top: 0,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: "Cari nama, layanan, kendaraan...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _serviceCard(Map item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1F2937), Color(0xFF374151)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['user']?['name'] ?? "-", style: titleStyle),
                    const SizedBox(height: 2),
                    Text(item['user']?['phone'] ?? "-", style: subtitleStyle),
                  ],
                ),
              ),

              statusBadge(item['status']),
            ],
          ),

          const SizedBox(height: 14),

          _infoRow(Icons.build_outlined, "Layanan", item['service_type']),
          _infoRow(Icons.event_outlined, "Jadwal", item['schedule_date']),
          _infoRow(
            Icons.electric_bike_outlined,
            "Kendaraan",
            "${item['member']?['vehicle_brand']} ${item['member']?['vehicle_model']}",
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => showDetailModal(item),
                  icon: const Icon(Icons.info_outline),
                  label: const Text("Detail"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: accentColor,
                    side: BorderSide(color: accentColor.withOpacity(0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: item['status'] == 'done'
                      ? null // 🔒 LOCK
                      : () => showStatusSelector(item),
                  icon: const Icon(Icons.sync),
                  label: const Text("Status"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pagination() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: currentPage > 1
                ? () => fetchHomeServices(page: currentPage - 1, refresh: true)
                : null,
            icon: const Icon(Icons.arrow_back_ios),
          ),
          Text(
            "Page $currentPage / $lastPage",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          IconButton(
            onPressed: currentPage < lastPage
                ? () => fetchHomeServices(page: currentPage + 1, refresh: true)
                : null,
            icon: const Icon(Icons.arrow_forward_ios),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: secondaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: secondaryColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                children: [
                  TextSpan(
                    text: "$label\n",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  TextSpan(text: value, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ADMIN THEME COLORS
const primaryColor = Color(0xFF111827); // Dark Slate (Header)
const secondaryColor = Color(0xFF374151); // Slate
const accentColor = Color(0xFF2563EB); // Blue action (admin standard)

const bgColor = Color(0xFFF3F4F6); // light gray background

TextStyle titleStyle = const TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
);

TextStyle subtitleStyle = TextStyle(fontSize: 13, color: Colors.grey[600]);

TextStyle labelStyle = const TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w600,
);

String formatDate(String? date) {
  if (date == null || date.isEmpty) return "-";
  try {
    final dt = DateTime.parse(date);
    return DateFormat('dd-MM-yy').format(dt);
  } catch (_) {
    return date;
  }
}

String formatTime(String? time) {
  if (time == null || time.isEmpty) return "-";
  try {
    // jika format HH:mm:ss
    final parts = time.split(':');
    if (parts.length >= 2) {
      return "${parts[0]}:${parts[1]} WIB";
    }
    return time;
  } catch (_) {
    return time;
  }
}
