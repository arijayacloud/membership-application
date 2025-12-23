import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/api_service.dart';
import '../../../utils/constants.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';

import '../widgets/show_snackbar.dart';

class PromoAdminPage extends StatefulWidget {
  const PromoAdminPage({super.key});

  @override
  State<PromoAdminPage> createState() => _PromoAdminPageState();
}

class _PromoAdminPageState extends State<PromoAdminPage> {
  List promos = [];
  bool isLoading = true;

  File? selectedImageFile; // Untuk Mobile
  Uint8List? selectedImageBytes; // Untuk Web
  String? selectedImageName; // Nama file (Wajib Web)
  String? uploadedPhoto; // Setelah berhasil upload, isi nama file dari server

  final TextEditingController titleC = TextEditingController();
  final TextEditingController descC = TextEditingController();
  final TextEditingController searchC = TextEditingController();
  final TextEditingController startDateC = TextEditingController();
  final TextEditingController endDateC = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPromos();
  }

  // ====================================================
  // 🔵 GET PROMO DATA
  // ====================================================
  Future<void> fetchPromos({String? status}) async {
    setState(() => isLoading = true);

    final endpoint = status == null
        ? "admin/promo"
        : "admin/promo?status=$status";

    final res = await ApiService.get(endpoint);

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      setState(() {
        promos = body['data']['data'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  // ====================================================
  // 🔵 PICK IMAGE
  // ====================================================
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

  Future<void> pickDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.text = picked.toIso8601String().split("T").first;
    }
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "-";
    final dt = DateTime.parse(date);
    return DateFormat('dd-MM-yyyy').format(dt);
  }

  // ====================================================
  // 🔵 SHOW FORM (ADD)
  // ====================================================
  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  void showPromoForm({Map? promo}) {
    Uint8List? imageBytes;
    String? imageName;
    File? imageFile;
    String? existingImage = promo?['banner'];

    bool isSubmitting = false;

    titleC.text = promo?['title'] ?? '';
    descC.text = promo?['description'] ?? '';
    startDateC.text = promo?['start_date'] != null
        ? formatDate(promo!['start_date'])
        : '';
    endDateC.text = promo?['end_date'] != null
        ? formatDate(promo!['end_date'])
        : '';

    showDialog(
      context: context,
      barrierDismissible: !isSubmitting,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickImage() async {
              final img = await ImagePicker().pickImage(
                source: ImageSource.gallery,
              );
              if (img == null) return;

              if (kIsWeb) {
                imageBytes = await img.readAsBytes();
                imageName = img.name;
                imageFile = null;
              } else {
                imageFile = File(img.path);
                imageBytes = null;
                imageName = null;
              }

              setDialogState(() {});
            }

            Widget imagePreview() {
              Widget image;

              if (kIsWeb && imageBytes != null) {
                image = Image.memory(imageBytes!, fit: BoxFit.cover);
              } else if (!kIsWeb && imageFile != null) {
                image = Image.file(imageFile!, fit: BoxFit.cover);
              } else if (existingImage != null) {
                image = Image.network(
                  "${AppConfig.baseUrl}/media/$existingImage",
                  fit: BoxFit.cover,
                );
              } else {
                return Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.image, size: 48, color: Colors.grey),
                  ),
                );
              }

              return GestureDetector(
                onTap: () {
                  showFullscreenImage(
                    context,
                    bytes: imageBytes,
                    file: imageFile,
                    networkUrl: existingImage != null
                        ? "${AppConfig.baseUrl}/media/$existingImage"
                        : null,
                  );
                },
                child: Stack(
                  children: [
                    Positioned.fill(child: image),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.zoom_out_map,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== TITLE =====
                    Text(
                      promo == null ? "Tambah Promo" : "Edit Promo",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ===== FORM =====
                    TextField(
                      controller: titleC,
                      decoration: _inputDecoration(
                        "Judul Promo",
                        icon: Icons.title,
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: descC,
                      maxLines: 3,
                      decoration: _inputDecoration(
                        "Deskripsi",
                        icon: Icons.description,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: startDateC,
                            readOnly: true,
                            decoration: _inputDecoration(
                              "Mulai",
                              icon: Icons.date_range,
                            ),
                            onTap: () => pickDate(context, startDateC),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: endDateC,
                            readOnly: true,
                            decoration: _inputDecoration(
                              "Berakhir",
                              icon: Icons.event,
                            ),
                            onTap: () => pickDate(context, endDateC),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ===== IMAGE PREVIEW =====
                    SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: imagePreview(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text("Pilih Gambar"),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ===== ACTIONS =====
                    // ===== ACTION BUTTONS =====
                    Row(
                      children: [
                        // ❌ BATAL
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isSubmitting
                                ? null
                                : () => Navigator.pop(dialogContext),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey.shade700,
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              "Batal",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // ✅ SIMPAN / UPDATE
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    setDialogState(() => isSubmitting = true);

                                    try {
                                      if (promo == null) {
                                        await createPromo(
                                          title: titleC.text,
                                          description: descC.text,
                                          imageBytes: imageBytes,
                                          imageName: imageName,
                                          imageFile: imageFile,
                                        );
                                      } else {
                                        await updatePromo(
                                          id: promo['id'],
                                          title: titleC.text,
                                          description: descC.text,
                                          imageBytes: imageBytes,
                                          imageName: imageName,
                                          imageFile: imageFile,
                                        );
                                      }

                                      Navigator.pop(dialogContext);
                                    } catch (e) {
                                      setDialogState(
                                        () => isSubmitting = false,
                                      );

                                      ShowSnackBar.show(
                                        context,
                                        "Gagal menyimpan data",
                                        "error",
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    promo == null ? "Simpan" : "Update",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
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
            );
          },
        );
      },
    );
  }

  void showFullscreenImage(
    BuildContext context, {
    Uint8List? bytes,
    File? file,
    String? networkUrl,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (_) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4,
                    child: Builder(
                      builder: (_) {
                        if (bytes != null) {
                          return Image.memory(bytes);
                        }
                        if (file != null) {
                          return Image.file(file);
                        }
                        if (networkUrl != null) {
                          return Image.network(networkUrl);
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),

                // CLOSE BUTTON
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
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

  Future<void> createPromo({
    required String title,
    required String description,
    Uint8List? imageBytes,
    String? imageName,
    File? imageFile,
  }) async {
    if (!mounted) return;

    final res = await ApiService.createPromo(
      title: title,
      description: description,
      startDate: startDateC.text,
      endDate: endDateC.text,
      bannerBytes: imageBytes,
      filename: imageName,
      bannerFile: imageFile,
    );

    debugPrint("CREATE PROMO RESPONSE: $res");

    if (!mounted) return;

    if (res['success'] == true) {
      ShowSnackBar.show(context, "Promo berhasil ditambahkan", "success");
    } else {
      final message =
          res['message'] ??
          res['errors']?.toString() ??
          "Gagal menambahkan promo";

      ShowSnackBar.show(context, message, "error");
    }
  }

  Future<void> updatePromo({
    required int id,
    required String title,
    required String description,
    Uint8List? imageBytes,
    String? imageName,
    File? imageFile,
  }) async {
    if (!mounted) return;

    final res = await ApiService.updatePromo(
      id: id,
      title: title,
      description: description,
      startDate: startDateC.text,
      endDate: endDateC.text,
      bannerBytes: imageBytes,
      filename: imageName,
      bannerFile: imageFile,
    );

    if (!mounted) return;

    if (res['success'] == true) {
      await fetchPromos();

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ShowSnackBar.show(context, "Promo berhasil diperbarui", "success");
    } else {
      final message = res['message'] ?? "Gagal memperbarui promo";

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ShowSnackBar.show(context, message, "error");
    }
  }

  // ====================================================
  // 🔵 DELETE CONFIRMATION
  // ====================================================
  void confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Hapus Promo"),
          content: const Text("Yakin ingin menghapus promo ini?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                deletePromo(id);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Hapus"),
            ),
          ],
        );
      },
    );
  }

  // ====================================================
  // 🔵 DELETE PROMO
  // ====================================================
  Future<void> deletePromo(int id) async {
    final res = await ApiService.delete("admin/promo/$id");

    if (res.statusCode == 200) {
      fetchPromos();
      ShowSnackBar.show(context, "Promo berhasil dihapus", "success");
    }
  }

  // ====================================================
  // 🔵 UPDATE STATUS PROMO (aktif / nonaktif)
  // ====================================================
  Future<void> toggleStatus(int id, bool newValue) async {
    final res = await ApiService.put("admin/promo/status/$id", {
      "is_active": newValue ? "1" : "0",
    });

    if (res.statusCode == 200) {
      fetchPromos();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ShowSnackBar.show(
        context,
        newValue ? "Promo diaktifkan" : "Promo dinonaktifkan",
        newValue ? "success" : "warning",
      );
    }
  }

  // ====================================================
  // 🔵 MAIN UI
  // ====================================================
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
          // ⬇️ GESER TEKS KE KANAN
          const Padding(
            padding: EdgeInsets.only(left: 44),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(
                  "Kelola Promo",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Atur promo aktif dan nonaktif",
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ],
            ),
          ),

          // 🔙 BUTTON BACK
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

          // ➕ BUTTON TAMBAH
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: showPromoForm,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Container(
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
          controller: searchC,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: "Cari promo...",
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _promoCard(Map promo) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== IMAGE =====
          if (promo['banner'] != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
              child: GestureDetector(
                onTap: () {
                  showFullscreenImage(
                    context,
                    networkUrl: "${AppConfig.baseUrl}/media/${promo['banner']}",
                  );
                },
                child: Stack(
                  children: [
                    Image.network(
                      "${AppConfig.baseUrl}/media/${promo['banner']}",
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),

                    // STATUS BADGE
                    Positioned(
                      top: 12,
                      left: 12,
                      child: _statusBadge(promo['is_active']),
                    ),
                  ],
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promo['title'] ?? "-",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  promo['description'] ?? "-",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 8),
                Text(
                  "Periode: ${formatDate(promo['start_date'])} - ${formatDate(promo['end_date'])}",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Switch.adaptive(
                      value: promo['is_active'] == 1,
                      onChanged: (val) => toggleStatus(promo['id'], val),
                    ),

                    Row(
                      children: [
                        _iconAction(
                          Icons.edit,
                          Colors.blue,
                          () => showPromoForm(promo: promo),
                        ),
                        _iconAction(
                          Icons.delete,
                          Colors.red,
                          () => confirmDelete(promo['id']),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(int status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: status == 1 ? Colors.green : Colors.grey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status == 1 ? "AKTIF" : "NONAKTIF",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _iconAction(IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = promos.where((p) {
      final search = searchC.text.toLowerCase();
      return p['title'].toString().toLowerCase().contains(search);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          _header(),
          _searchBar(),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final promo = filtered[i];
                      return _promoCard(promo);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
