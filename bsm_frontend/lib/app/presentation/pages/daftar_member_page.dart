import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import 'dart:convert';

class DaftarMemberPage extends StatefulWidget {
  const DaftarMemberPage({super.key});

  @override
  State<DaftarMemberPage> createState() => _DaftarMemberPageState();
}

class _DaftarMemberPageState extends State<DaftarMemberPage> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  bool loading = false;

  Future daftar() async {
    if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty || emailCtrl.text.isEmpty) {
      _showMsg("Nama, Email & No HP wajib diisi", isError: true);
      return;
    }

    // Validasi email
    if (!emailCtrl.text.contains("@") || !emailCtrl.text.contains(".")) {
      _showMsg("Format email tidak valid", isError: true);
      return;
    }

    setState(() => loading = true);

    final res = await ApiService.post("member/register", {
      "name": nameCtrl.text,
      "phone": phoneCtrl.text,
      "email": emailCtrl.text,
    });

    setState(() => loading = false);

    final data = jsonDecode(res.body);

    if (data['success']) {
      _showMsg("Pendaftaran berhasil!");
      nameCtrl.clear();
      phoneCtrl.clear();
      emailCtrl.clear();
    } else {
      _showMsg(data['message'] ?? "Gagal mendaftar", isError: true);
    }
  }

  void _showMsg(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),

      body: Column(
        children: [
          // =======================================
          // 🔵 HEADER GRADIENT
          // =======================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 40, bottom: 26, left: 20, right: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1F3C88), Color(0xFF3A6EA5)],
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
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(CupertinoIcons.arrow_left,
                        color: Colors.white, size: 22),
                  ),
                ),
                const SizedBox(width: 14),
                const Text(
                  "Daftar Member Baru",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // =============================
                  // 📝 Form Card
                  // =============================
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Isi Form Pendaftaran",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // NAMA
                        _inputField(
                          controller: nameCtrl,
                          label: "Nama Lengkap",
                          icon: CupertinoIcons.person_fill,
                        ),

                        const SizedBox(height: 16),

                        // EMAIL (baru)
                        _inputField(
                          controller: emailCtrl,
                          label: "Email",
                          icon: CupertinoIcons.mail_solid,
                          keyboard: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 16),

                        // NOMOR HP
                        _inputField(
                          controller: phoneCtrl,
                          label: "Nomor HP",
                          icon: CupertinoIcons.phone_fill,
                          keyboard: TextInputType.phone,
                        ),

                        const SizedBox(height: 30),

                        // SUBMIT BUTTON
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: const Color(0xFF1F3C88),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: loading ? null : daftar,
                            child: loading
                                ? const CupertinoActivityIndicator(color: Colors.white)
                                : const Text(
                                    "Daftarkan Member",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================
  // 🧩 Custom Input Field
  // ===========================
  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF1F3C88)),
        filled: true,
        fillColor: const Color(0xFFF4F6FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
