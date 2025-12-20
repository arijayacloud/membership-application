import 'package:bsm_frontend/app/presentation/widgets/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_routes.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final adminKeyCtrl = TextEditingController();

  String role = "user";
  bool hidePass = true;
  bool hideAdminKey = true;

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    adminKeyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // ================= LOGO =================
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1F3C88), Color(0xFF3A6EA5)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.electric_moped_rounded,
                    size: 72,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  "BSM Service Center",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F3C88),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Pendaftaran Akun Layanan Resmi Motor & Sepeda Listrik",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.blueGrey.shade600,
                  ),
                ),

                const SizedBox(height: 36),

                // ================= CARD FORM =================
                Card(
                  elevation: 8,
                  shadowColor: Colors.blue.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Daftar Akun",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F3C88),
                            ),
                          ),
                          const SizedBox(height: 24),

                          _label("Nama Lengkap"),
                          _field(
                            controller: nameCtrl,
                            hint: "Masukkan nama lengkap",
                            icon: Icons.person_outline,
                            validator: (v) =>
                                v == null || v.isEmpty ? "Nama wajib diisi" : null,
                          ),
                          const SizedBox(height: 18),

                          _label("No HP"),
                          _field(
                            controller: phoneCtrl,
                            hint: "08xxxxxxxxxx",
                            icon: Icons.phone_android,
                            type: TextInputType.phone,
                            validator: (v) =>
                                v == null || v.isEmpty ? "No HP wajib diisi" : null,
                          ),
                          const SizedBox(height: 18),

                          _label("Email"),
                          _field(
                            controller: emailCtrl,
                            hint: "email@example.com",
                            icon: Icons.email_outlined,
                            type: TextInputType.emailAddress,
                            validator: (v) =>
                                v == null || v.isEmpty ? "Email wajib diisi" : null,
                          ),
                          const SizedBox(height: 18),

                          _label("Password"),
                          _field(
                            controller: passCtrl,
                            hint: "Minimal 6 karakter",
                            icon: Icons.lock_outline,
                            obscure: hidePass,
                            suffix: IconButton(
                              icon: Icon(
                                hidePass
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () =>
                                  setState(() => hidePass = !hidePass),
                            ),
                            validator: (v) => v == null || v.length < 6
                                ? "Minimal 6 karakter"
                                : null,
                          ),

                          const SizedBox(height: 22),

                          _label("Daftar sebagai"),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F6FA),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: role,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: "user",
                                  child: Text("User"),
                                ),
                                DropdownMenuItem(
                                  value: "admin",
                                  child: Text("Admin"),
                                ),
                              ],
                              onChanged: (v) => setState(() => role = v!),
                            ),
                          ),

                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: role == "admin"
                                ? Column(
                                    key: const ValueKey("admin"),
                                    children: [
                                      const SizedBox(height: 18),
                                      _label("Kode Rahasia Admin"),
                                      _field(
                                        controller: adminKeyCtrl,
                                        hint: "Masukkan kode admin",
                                        icon: Icons.key,
                                        obscure: hideAdminKey,
                                        suffix: IconButton(
                                          icon: Icon(
                                            hideAdminKey
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                          ),
                                          onPressed: () => setState(
                                            () => hideAdminKey = !hideAdminKey,
                                          ),
                                        ),
                                        validator: (v) {
  if (role == "admin" && (v == null || v.isEmpty)) {
    return "Kode admin wajib";
  }
  return null;
},
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                          ),

                          const SizedBox(height: 30),

                          auth.isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                    ),
                                    onPressed: () async {
                                      if (!formKey.currentState!.validate()) {
                                        return;
                                      }

                                      final ok = await auth.register(
                                        name: nameCtrl.text.trim(),
                                        phone: phoneCtrl.text.trim(),
                                        email: emailCtrl.text.trim(),
                                        password: passCtrl.text,
                                        role: role,
                                        adminKey: adminKeyCtrl.text,
                                      );

                                      ShowSnackBar.show(
                                        context,
                                        ok
                                            ? "Registrasi berhasil! Silakan login 😊"
                                            : "Registrasi gagal, periksa kembali!",
                                        ok ? "success" : "error",
                                      );

                                      if (ok) {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          AppRoutes.login,
                                        );
                                      }
                                    },
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF1F3C88),
                                            Color(0xFF3A6EA5),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "DAFTAR SEKARANG",
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Sudah punya akun?",
                      style: TextStyle(color: Colors.blueGrey[700]),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.login,
                      ),
                      child: const Text(
                        "Masuk",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F3C88),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Text(
                  "Aplikasi Resmi BSM Service Center",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===================== FIELD =====================
  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.blueGrey.shade700,
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscure = false,
    TextInputType type = TextInputType.text,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      keyboardType: type,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF1F3C88)),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF4F6FA),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
