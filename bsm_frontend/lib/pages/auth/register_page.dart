import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_routes.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
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
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFE9F0FF),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                // ===================== LOGO =====================
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person_add_alt_rounded,
                    color: Colors.blue[700],
                    size: 70,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  "BSM Klinik Center",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.blue[900],
                    letterSpacing: 0.3,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Pendaftaran Akun Pengguna Klinik",
                  style: TextStyle(fontSize: 15, color: Colors.blueGrey[600]),
                ),

                const SizedBox(height: 32),

                // ===================== CARD REGISTER =====================
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: Colors.white.withOpacity(0.92),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 15,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Daftar Akun",
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        const SizedBox(height: 22),

                        buildField(
                          controller: nameCtrl,
                          label: "Nama Lengkap",
                          icon: Icons.person,
                          validator: (v) =>
                              v!.isEmpty ? "Nama wajib diisi" : null,
                        ),
                        const SizedBox(height: 18),

                        buildField(
                          controller: phoneCtrl,
                          label: "No HP",
                          icon: Icons.phone_android,
                          type: TextInputType.phone,
                          validator: (v) =>
                              v!.isEmpty ? "No HP wajib diisi" : null,
                        ),
                        const SizedBox(height: 18),

                        buildField(
                          controller: emailCtrl,
                          label: "Email *",
                          icon: Icons.email,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Email wajib diisi";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        buildField(
                          controller: passCtrl,
                          label: "Password",
                          icon: Icons.lock_outline,
                          obscure: hidePass,
                          toggle: () => setState(() => hidePass = !hidePass),
                          validator: (v) =>
                              v!.length < 6 ? "Minimal 6 karakter" : null,
                        ),

                        const SizedBox(height: 22),

                        Text(
                          "Daftar sebagai",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.blueGrey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey[50],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: DropdownButtonFormField(
                            isExpanded:
                                true, // ← WAJIB untuk menghindari overflow
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            value: role,
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
                            onChanged: (val) => setState(() => role = val!),
                          ),
                        ),

                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: role == "admin"
                              ? Column(
                                  children: [
                                    const SizedBox(height: 18),
                                    buildField(
                                      controller: adminKeyCtrl,
                                      label: "Kode Rahasia Admin",
                                      icon: Icons.key,
                                      obscure: hideAdminKey,
                                      toggle: () => setState(
                                        () => hideAdminKey = !hideAdminKey,
                                      ),
                                      validator: (v) =>
                                          role == "admin" && v!.isEmpty
                                          ? "Kode admin wajib"
                                          : null,
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),

                        const SizedBox(height: 30),

                        auth.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (!formKey.currentState!.validate())
                                      return;

                                    final ok = await auth.register(
                                      name: nameCtrl.text,
                                      phone: phoneCtrl.text,
                                      email: emailCtrl.text,
                                      password: passCtrl.text,
                                      role: role,
                                      adminKey: adminKeyCtrl.text,
                                    );

                                    if (ok) {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        AppRoutes.login,
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text("Pendaftaran gagal!"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue.shade700,
                                          Colors.blue.shade500,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Daftar Sekarang",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
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
                      child: Text(
                        "Masuk",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  "Aplikasi Resmi Layanan Klinik BSM",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================== Custom Field ===========================
  Widget buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscure = false,
    VoidCallback? toggle,
    TextInputType type = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      keyboardType: type,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blue[600]),
        suffixIcon: toggle != null
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[600],
                ),
                onPressed: toggle,
              )
            : null,
        hintText: label,
        filled: true,
        fillColor: Colors.blueGrey[50],
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
