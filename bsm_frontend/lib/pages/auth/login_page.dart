import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_routes.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
          child: Column(
            children: [
              // ===========================
              //          LOGO
              // ===========================
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.local_hospital_rounded,
                  color: Colors.blue[700],
                  size: 70,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "BSM Klinik Center",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.blue[900],
                  letterSpacing: 0.3,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Sistem Layanan Medis Terpadu",
                style: TextStyle(fontSize: 15, color: Colors.blueGrey[600]),
              ),

              const SizedBox(height: 35),

              // ===========================
              //           CARD LOGIN
              // ===========================
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Login Akun",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),

                      const SizedBox(height: 22),

                      // ===========================
                      //          EMAIL
                      // ===========================
                      Text(
                        "Email",
                        style: TextStyle(
                          color: Colors.blueGrey[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),

                      _inputField(
                        controller: emailCtrl,
                        icon: Icons.email_outlined,
                        hint: "Masukkan email",
                      ),

                      const SizedBox(height: 22),

                      // ===========================
                      //        PASSWORD
                      // ===========================
                      Text(
                        "Password",
                        style: TextStyle(
                          color: Colors.blueGrey[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),

                      _inputField(
                        controller: passCtrl,
                        icon: Icons.lock_outline,
                        hint: "Masukkan password",
                        obscure: true,
                      ),

                      const SizedBox(height: 28),

                      // ===========================
                      //       TOMBOL LOGIN
                      // ===========================
                      auth.isLoading
                          ? Center(child: CircularProgressIndicator())
                          : SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                style:
                                    ElevatedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ).copyWith(
                                      backgroundColor: WidgetStateProperty.all(
                                        Colors.transparent,
                                      ),
                                      shadowColor: WidgetStateProperty.all(
                                        Colors.transparent,
                                      ),
                                    ),
                                onPressed: () async {
                                  final ok = await auth.login(
                                    emailCtrl.text,
                                    passCtrl.text,
                                  );

                                  if (ok) {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      auth.role == "admin"
                                          ? AppRoutes.adminDashboard
                                          : AppRoutes.dashboard,
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Login gagal, periksa email & password!",
                                          style: TextStyle(color: Colors.white),
                                        ),
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
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Masuk",
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

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Belum punya akun?",
                    style: TextStyle(color: Colors.blueGrey[700]),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.register);
                    },
                    child: Text(
                      "Daftar Sekarang",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text(
                "Aplikasi Resmi Layanan Klinik BSM",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ====================================================
  //          FUNGSI WIDGET INPUT FIELD
  // ====================================================
  Widget _inputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blue[600]),
        hintText: hint,
        filled: true,
        fillColor: Colors.blueGrey[50],
        contentPadding: EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
