import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/api_service.dart';
import '../widgets/show_snackbar.dart';

class InfoAdminPage extends StatefulWidget {
  const InfoAdminPage({super.key});

  @override
  State<InfoAdminPage> createState() => _InfoAdminPageState();
}

class _InfoAdminPageState extends State<InfoAdminPage> {
  bool isLoading = false;
  int? infoId;

  final clinicNameC = TextEditingController();
  final addressC = TextEditingController();
  final phoneC = TextEditingController();
  final emailC = TextEditingController();
  final operationalC = TextEditingController();
  final aboutC = TextEditingController();
  final descC = TextEditingController();
  final mapsUrlC = TextEditingController();
  final instagramC = TextEditingController();
  final websiteC = TextEditingController();

  List<String> facilities = [];
  List<String> services = [];

  @override
  void initState() {
    super.initState();
    fetchInfo();
  }

  // ===========================================================
  // FETCH INFO
  // ===========================================================
  Future<void> fetchInfo() async {
    setState(() => isLoading = true);

    try {
      final res = await ApiService.get("admin/info");
      final body = json.decode(res.body);

      if (res.statusCode == 200 && body['data'] != null) {
        final d = body['data'];

        setState(() {
          infoId = d['id'];
          clinicNameC.text = d['clinic_name'] ?? "";
          addressC.text = d['address'] ?? "";
          phoneC.text = d['phone'] ?? "";
          emailC.text = d['email'] ?? "";
          operationalC.text = d['operational_hours'] ?? "";
          aboutC.text = d['about'] ?? "";
          descC.text = d['description'] ?? "";
          mapsUrlC.text = d['maps_url'] ?? "";
          instagramC.text = d['instagram'] ?? "";
          websiteC.text = d['website'] ?? "";

          facilities = List<String>.from(d['facilities'] ?? []);
          services = List<String>.from(d['services'] ?? []);
        });
      }
    } catch (e) {
      debugPrint("FETCH INFO ERROR: $e");
    }

    setState(() => isLoading = false);
  }

  // ===========================================================
  // SAVE INFO
  // ===========================================================
  Future<void> saveInfo() async {
    final body = {
      "clinic_name": clinicNameC.text.trim(),
      "address": addressC.text.trim(),
      "phone": phoneC.text.trim(),
      "email": emailC.text.trim(),
      "operational_hours": operationalC.text.trim(),
      "about": aboutC.text.trim(),
      "description": descC.text.trim(),
      "facilities": facilities,
      "services": services,
      "maps_url": mapsUrlC.text.trim(),
      "instagram": instagramC.text.trim(),
      "website": websiteC.text.trim(),
    };

    try {
      final res = infoId == null
          ? await ApiService.postJson("admin/info", body)
          : await ApiService.putJson("admin/info/$infoId", body);

      if (!mounted) return;

      // ================= SUCCESS =================
      if (res.statusCode == 200 || res.statusCode == 201) {
        await fetchInfo();

        ShowSnackBar.show(context, "Info Bengkel berhasil disimpan", "success");
        return;
      }

      // ================= WARNING (VALIDATION) =================
      if (res.statusCode == 422) {
        final data = jsonDecode(res.body);

        String message = "Data tidak valid";
        if (data is Map && data['message'] != null) {
          message = data['message'];
        }

        ShowSnackBar.show(context, message, "warning");
        return;
      }

      // ================= OTHER ERROR =================
      ShowSnackBar.show(
        context,
        "Terjadi kesalahan (${res.statusCode})",
        "error",
      );
    } catch (e) {
      debugPrint("SAVE INFO ERROR: $e");

      if (!mounted) return;
      ShowSnackBar.show(
        context,
        "Gagal menyimpan data. Periksa koneksi atau server.",
        "error",
      );
    }
  }

  // ===========================================================
  // UI
  // ===========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          _header(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    child: Column(
                      children: [
                        _cardSection(
                          icon: Icons.local_hospital,
                          title: "Informasi Umum",
                          children: [
                            _field("Nama Bengkel", clinicNameC),
                            _field("Alamat", addressC, maxLines: 2),
                            _field("No Telepon", phoneC),
                            _field("Email", emailC),
                            _field("Jam Operasional", operationalC),
                          ],
                        ),
                        _cardSection(
                          icon: Icons.info_outline,
                          title: "Tentang Bengkel",
                          children: [
                            _field("Tentang", aboutC, maxLines: 3),
                            _field("Deskripsi", descC, maxLines: 3),
                          ],
                        ),
                        _cardSection(
                          icon: Icons.apartment,
                          title: "Fasilitas",
                          children: [
                            _chipInput(
                              items: facilities,
                              hint: "Tambah fasilitas",
                              onChanged: (v) => setState(() => facilities = v),
                            ),
                          ],
                        ),
                        _cardSection(
                          icon: Icons.medical_services,
                          title: "Layanan",
                          children: [
                            _chipInput(
                              items: services,
                              hint: "Tambah layanan",
                              onChanged: (v) => setState(() => services = v),
                            ),
                          ],
                        ),
                        _cardSection(
                          icon: Icons.map,
                          title: "Lokasi & Media",
                          children: [
                            _field("Google Maps URL", mapsUrlC),
                            _mapPreview(mapsUrlC.text),
                            _field("Instagram", instagramC),
                            _field("Website", websiteC),
                          ],
                        ),

                        const SizedBox(height: 8),
                        _saveButton(), // ⬅️ DI SINI
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // COMPONENTS
  // ===========================================================
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
          const Padding(
            padding: EdgeInsets.only(left: 44),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(
                  "Info Bengkel",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Kelola informasi & profil Bengkel",
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ],
            ),
          ),

          // 🔙 BACK
          Positioned(
            left: 0,
            top: 0,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: _headerButton(Icons.arrow_back_ios_new),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _cardSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blueGrey),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : saveInfo,
        icon: const Icon(Icons.save),
        label: const Text(
          "Simpan Perubahan",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blueGrey.shade900,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // CHIP INPUT
  // ===========================================================
  Widget _chipInput({
    required List<String> items,
    required String hint,
    required Function(List<String>) onChanged,
  }) {
    final controller = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((e) {
            return Chip(
              label: Text(e),
              backgroundColor: Colors.blueGrey.shade50,
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () {
                final updated = [...items]..remove(e);
                onChanged(updated);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                final value = controller.text.trim();
                if (value.isEmpty) return;
                onChanged([...items, value]);
                controller.clear();
              },
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================
  // MAP PREVIEW
  // ===========================================================
  Widget _mapPreview(String url) {
    if (url.isEmpty) return const SizedBox();

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [Colors.red.shade400, Colors.red.shade700],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, color: Colors.white, size: 34),
              SizedBox(height: 8),
              Text(
                "Buka di Google Maps",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
