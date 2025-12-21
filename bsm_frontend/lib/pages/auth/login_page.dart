import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/presentation/widgets/show_snackbar.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool showPassword = false;

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

                // =========================
                // LOGO + BRAND
                // =========================
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
                  "Layanan Resmi Motor & Sepeda Listrik",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.blueGrey.shade600,
                  ),
                ),

                const SizedBox(height: 40),

                // =========================
                // CARD LOGIN
                // =========================
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Masuk ke Akun",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F3C88),
                        ),
                      ),

                      const SizedBox(height: 22),

                      _label("Email"),
                      _inputField(
                        controller: emailCtrl,
                        icon: Icons.email_outlined,
                        hint: "email@example.com",
                      ),

                      const SizedBox(height: 18),

                      _label("Password"),
                      _inputField(
                        controller: passCtrl,
                        icon: Icons.lock_outline,
                        hint: "Masukkan password",
                        obscure: !showPassword,
                        suffix: IconButton(
                          icon: Icon(
                            showPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              showPassword = !showPassword;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 28),

                      auth.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (emailCtrl.text.isEmpty ||
                                      passCtrl.text.isEmpty) {
                                    ShowSnackBar.show(
                                      context,
                                      "Email dan password wajib diisi",
                                      "warning",
                                    );
                                    return;
                                  }

                                  final ok = await auth.login(
                                    emailCtrl.text.trim(),
                                    passCtrl.text,
                                  );

                                  if (ok) {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      auth.role == "admin"
                                          ? AppRoutes.dashboardAdmin
                                          : AppRoutes.dashboard,
                                    );

                                    ShowSnackBar.show(
                                      context,
                                      "Login berhasil, selamat datang!",
                                      "success",
                                    );
                                  } else {
                                    ShowSnackBar.show(
                                      context,
                                      auth.errorMessage ?? "Login gagal",
                                      "error",
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
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
                                      "MASUK",
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

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Belum punya akun?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.register);
                      },
                      child: const Text(
                        "Daftar Sekarang",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F3C88),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Text(
                  "© BSM Service Center",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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

  Widget _inputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
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
