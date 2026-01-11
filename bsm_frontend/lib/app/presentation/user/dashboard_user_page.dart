import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../services/api_service.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/show_snackbar.dart';
import 'cek_member_page.dart';
import 'daftar_member_page.dart';
import 'home_service_page.dart';
import 'promo_page.dart';
import 'info_page.dart';
import 'package:bsm_frontend/services/whatsapp_service.dart';
import '../widgets/edit_profile_modal.dart';
import '../../../storage/local_storage.dart';
import '../../../utils/session_manager.dart';

class DashboardUserPage extends StatefulWidget {
  const DashboardUserPage({super.key});

  @override
  State<DashboardUserPage> createState() => _DashboardUserPageState();
}

class _DashboardUserPageState extends State<DashboardUserPage>
    with WidgetsBindingObserver {
  String? whatsappNumber;
  bool loadingWhatsapp = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SessionManager.updateLastActive();
    fetchWhatsapp();
  }

  Future<void> fetchWhatsapp() async {
    final phone = await ApiService.getWhatsappNumber();
    setState(() {
      whatsappNumber = phone;
      loadingWhatsapp = false;
    });
  }

  String normalizeWhatsapp(String phone) {
    // Hapus spasi, tanda +, strip, dll
    String clean = phone.replaceAll(RegExp(r'[^0-9]'), '');

    // Jika mulai 0 → ganti 62
    if (clean.startsWith('0')) {
      clean = '62${clean.substring(1)}';
    }

    // Jika sudah 62 → biarkan
    if (clean.startsWith('62')) {
      return clean;
    }

    // Fallback (kalau format aneh)
    return clean;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // 📴 App ke background
      await SessionManager.updateLastActive();
    }

    if (state == AppLifecycleState.resumed) {
      // 🔁 App dibuka lagi
      final lastActive = await SessionManager.getLastActive();

      if (lastActive != null) {
        final diff = DateTime.now().difference(lastActive);

        if (diff.inHours >= 1) {
          // ⛔ Timeout 1 jam → logout
          await LocalStorage.clear();

          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(context, "/login", (_) => false);
          }
        }
      }
    }
  }

  void logout(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Konfirmasi Logout",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("Apakah Anda yakin ingin keluar?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
              },
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                Navigator.pop(context);

                await SessionManager.clear();
                await LocalStorage.clear();

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/login",
                  (route) => false,
                );
              },
              child: const Text("Ya, Keluar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => SessionManager.updateLastActive(),
      onPanDown: (_) => SessionManager.updateLastActive(),

      child: PopScope(
        canPop: false, // ⛔ cegah keluar otomatis
        onPopInvoked: (didPop) {
          if (didPop) return;
          logout(context);
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF6F9FC),
          body: SafeArea(
            child: Column(
              children: [
                // ==========================
                // 🌟 HEADER (WITH PROFILE + LOGOUT)
                // ==========================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 26,
                    horizontal: 20,
                  ),
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

                  child: Stack(
                    children: [
                      // Text title
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "BSM Service Center",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Selamat datang, silakan pilih layanan",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),

                      // =====================
                      // PROFILE + LOGOUT BUTTONS
                      // =====================
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Row(
                          children: [
                            // PROFILE BUTTON
                            GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) =>
                                      const EditProfileModal(),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  LucideIcons.user,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // LOGOUT BUTTON
                            GestureDetector(
                              onTap: () => logout(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  LucideIcons.logOut,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ====================================
                // 🌟 GRID MENU
                // ====================================
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.92,
                      children: [
                        DashboardCard(
                          title: "Cek Member",
                          icon: LucideIcons.badgeCheck,
                          color: const Color(0xFF1F8A70),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CekMemberPage(),
                            ),
                          ),
                        ),
                        DashboardCard(
                          title: "Daftar Member",
                          icon: LucideIcons.userPlus,
                          color: const Color(0xFF3A6EA5),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DaftarMemberPage(),
                            ),
                          ),
                        ),
                        DashboardCard(
                          title: "Home Service",
                          icon: LucideIcons.home,
                          color: const Color(0xFF60A5FA),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomeServicePage(),
                            ),
                          ),
                        ),
                        DashboardCard(
                          title: "Promo Bengkel",
                          icon: LucideIcons.sparkle,
                          color: const Color(0xFFFF9F43),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PromoPage(),
                            ),
                          ),
                        ),
                        DashboardCard(
                          title: "Info",
                          icon: LucideIcons.info,
                          color: const Color(0xFF7A7ADB),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const InfoPage()),
                          ),
                        ),
                        DashboardCard(
                          title: "WhatsApp",
                          icon: LucideIcons.messageCircle,
                          color: const Color(0xFF25D366),
                          onTap: () {
                            if (loadingWhatsapp) return;

                            if (whatsappNumber == null ||
                                whatsappNumber!.isEmpty) {
                              ShowSnackBar.show(
                                context,
                                "Nomor WhatsApp belum tersedia",
                                "error",
                              );
                              return;
                            }

                            final waNumber = normalizeWhatsapp(whatsappNumber!);

                            WhatsAppService.openChat(
                              waNumber,
                              message:
                                  'Halo, saya tertarik dengan layanan Anda',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
