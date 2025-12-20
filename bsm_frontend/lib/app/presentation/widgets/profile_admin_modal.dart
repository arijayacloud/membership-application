import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../widgets/show_snackbar.dart';

class ProfileAdminModal extends StatefulWidget {
  const ProfileAdminModal({super.key});

  @override
  State<ProfileAdminModal> createState() => _ProfileAdminModalState();
}

class _ProfileAdminModalState extends State<ProfileAdminModal> {
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final phoneC = TextEditingController();
  final passwordC = TextEditingController();
  final passwordConfirmC = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;
  bool hidePassword = true;
  bool hideConfirm = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  @override
  void dispose() {
    nameC.dispose();
    emailC.dispose();
    phoneC.dispose();
    passwordC.dispose();
    passwordConfirmC.dispose();
    super.dispose();
  }

  Future<void> fetchProfile() async {
    try {
      final res = await ApiService.get("admin/profile");
      final body = jsonDecode(res.body);

      if (res.statusCode == 200 && body['user'] != null) {
        final user = body['user'];
        nameC.text = user['name'] ?? "";
        emailC.text = user['email'] ?? "";
        phoneC.text = user['phone'] ?? "";
      } else {
        ShowSnackBar.show(context, "Gagal memuat profil", "error");
      }
    } catch (_) {
      ShowSnackBar.show(context, "Terjadi kesalahan server", "error");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> saveProfile() async {
    if (nameC.text.trim().isEmpty || emailC.text.trim().isEmpty) {
      ShowSnackBar.show(context, "Nama dan Email wajib diisi", "warning");
      return;
    }

    if (passwordC.text.isNotEmpty &&
        passwordC.text != passwordConfirmC.text) {
      ShowSnackBar.show(context, "Konfirmasi password tidak cocok", "warning");
      return;
    }

    setState(() => isSaving = true);

    try {
      final body = {
        "name": nameC.text.trim(),
        "email": emailC.text.trim(),
        "phone": phoneC.text.trim(),
      };

      if (passwordC.text.isNotEmpty) {
        body["password"] = passwordC.text;
        body["password_confirmation"] = passwordConfirmC.text;
      }

      final res = await ApiService.putJson("admin/profile", body);

      if (!mounted) return;

      if (res.statusCode == 200) {
        ShowSnackBar.show(context, "Profil berhasil diperbarui", "success");
        Navigator.pop(context);
      } else {
        ShowSnackBar.show(context, "Gagal menyimpan perubahan", "error");
      }
    } catch (_) {
      ShowSnackBar.show(context, "Koneksi bermasalah", "error");
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        22,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: isLoading
          ? const SizedBox(
              height: 180,
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== HEADER =====
                Row(
                  children: const [
                    CircleAvatar(
                      backgroundColor: Color(0xFF1F3C88),
                      child: Icon(Icons.admin_panel_settings,
                          color: Colors.white),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Profil Admin",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                _field("Nama Lengkap", nameC),
                _field("Email", emailC,
                    keyboard: TextInputType.emailAddress),
                _field("No. HP", phoneC,
                    keyboard: TextInputType.phone),

                _passwordField(
                  label: "Password Baru (opsional)",
                  controller: passwordC,
                  hide: hidePassword,
                  toggle: () =>
                      setState(() => hidePassword = !hidePassword),
                  helper: "Kosongkan jika tidak ingin mengubah",
                ),

                _passwordField(
                  label: "Konfirmasi Password",
                  controller: passwordConfirmC,
                  hide: hideConfirm,
                  toggle: () =>
                      setState(() => hideConfirm = !hideConfirm),
                ),

                const SizedBox(height: 24),

                // ===== BUTTON =====
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : saveProfile,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF1F3C88),
                            Color(0xFF3A6EA5),
                          ],
                        ),
                      ),
                      child: Center(
                        child: isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Simpan Perubahan",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF6F9FC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _passwordField({
    required String label,
    required TextEditingController controller,
    required bool hide,
    required VoidCallback toggle,
    String? helper,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        obscureText: hide,
        decoration: InputDecoration(
          labelText: label,
          helperText: helper,
          filled: true,
          fillColor: const Color(0xFFF6F9FC),
          suffixIcon: IconButton(
            icon: Icon(
              hide ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: toggle,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
