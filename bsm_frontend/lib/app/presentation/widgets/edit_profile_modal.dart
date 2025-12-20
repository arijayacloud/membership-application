import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../widgets/show_snackbar.dart';
import '../user/daftar_member_page.dart';

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

  final vehicleBrandCtrl = TextEditingController();
  final vehicleModelCtrl = TextEditingController();
  final vehicleSerialNumberCtrl = TextEditingController();

  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  bool showPassword = false;
  bool showConfirmPassword = false;

  String? selectedVehicleType;

  bool loading = false;
  bool isMember = false; // state

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    addressCtrl.dispose();
    vehicleBrandCtrl.dispose();
    vehicleModelCtrl.dispose();
    vehicleSerialNumberCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    try {
      setState(() => loading = true);

      final res = await ApiService.get("member/profile");

      if (res.statusCode != 200) {
        ShowSnackBar.show(context, "Gagal memuat data profil", "error");
        return;
      }

      final json = jsonDecode(res.body);

      final user = json["user"];
      final member = json["member"];
      isMember = json["is_member"] == true;

      // ======================
      // USER (SELALU ADA)
      // ======================
      nameCtrl.text = user?["name"] ?? "";
      phoneCtrl.text = user?["phone"] ?? "";
      emailCtrl.text = user?["email"] ?? "";

      // ======================
      // JIKA BELUM MEMBER
      // ======================
      if (!isMember || member == null) {
        // Tampilkan snackbar dulu
        ShowSnackBar.show(
          context,
          "Anda belum terdaftar sebagai member. Silakan daftar terlebih dahulu.",
          "warning",
        );

        // Delay sebentar agar snackbar terlihat
        Future.delayed(const Duration(milliseconds: 800), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DaftarMemberPage()),
          );
        });

        selectedVehicleType = null;
        addressCtrl.clear();
        vehicleBrandCtrl.clear();
        vehicleModelCtrl.clear();
        vehicleSerialNumberCtrl.clear();

        setState(() => loading = false);
        return;
      }

      // ======================
      // JIKA SUDAH MEMBER
      // ======================
      addressCtrl.text = member["address"] ?? "";
      selectedVehicleType = member["vehicle_type"];
      vehicleBrandCtrl.text = member["vehicle_brand"] ?? "";
      vehicleModelCtrl.text = member["vehicle_model"] ?? "";
      vehicleSerialNumberCtrl.text = member["vehicle_serial_number"] ?? "";

      setState(() => loading = false);
    } catch (e) {
      setState(() => loading = false);

      ShowSnackBar.show(context, "Terjadi kesalahan: $e", "error");
    }
  }

  Future save() async {
    if (selectedVehicleType == null) {
      ShowSnackBar.show(
        context,
        "Silakan daftar sebagai member terlebih dahulu",
        "warning",
      );
      return;
    }

    setState(() => loading = true);

    final payload = {
      "name": nameCtrl.text,
      "phone": phoneCtrl.text,
      "email": emailCtrl.text,
      "address": addressCtrl.text,
      "vehicle_type": selectedVehicleType,
      "vehicle_brand": vehicleBrandCtrl.text,
      "vehicle_model": vehicleModelCtrl.text,
      "vehicle_serial_number": vehicleSerialNumberCtrl.text,
    };

    if (passwordCtrl.text.isNotEmpty &&
        passwordCtrl.text != confirmPasswordCtrl.text) {
      setState(() => loading = false);
      ShowSnackBar.show(context, "Konfirmasi password tidak cocok", "error");
      return;
    }

    final res = await ApiService.put("member/update-profile", payload);

    setState(() => loading = false);

    if (res.statusCode == 200) {
      Navigator.pop(context);
      ShowSnackBar.show(context, "Profil berhasil diperbarui", "success");
    } else {
      ShowSnackBar.show(context, "Gagal memperbarui profil", "error");
    }
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
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 26),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1F3C88), Color(0xFF3A6EA5)],
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
                    icon: Icons.person,
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
                    ],
                  ),

                  _card(
                    title: "Data Kendaraan",
                    icon: Icons.motorcycle,
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
                    icon: Icons.safety_check,
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
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
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
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD0D7E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD0D7E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
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

  Widget _card({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          Row(
            children: [
              Icon(icon, color: const Color(0xFF1F3C88)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F3C88),
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

  Widget _vehicleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tipe Kendaraan",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F3C88),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFD0D7E1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedVehicleType,
              hint: const Text("Pilih Tipe Kendaraan"),
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
              onChanged: isMember
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
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1F3C88),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
        ),
        onPressed: loading ? null : save,
        child: loading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Simpan Perubahan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
