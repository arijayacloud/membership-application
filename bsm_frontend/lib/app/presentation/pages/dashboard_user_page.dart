import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/dashboard_card.dart';
import 'cek_member_page.dart';
import 'daftar_member_page.dart';
import 'home_service_page.dart';
import 'promo_page.dart';
import 'info_page.dart';
import 'package:bsm_frontend/services/whatsapp_service.dart';

class DashboardUserPage extends StatelessWidget {
  const DashboardUserPage({super.key});

  void logout(BuildContext context) {
    // TODO: Tambahkan proses logout token lokal
    // LocalStorage.clearToken();
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
      body: SafeArea(
        child: Column(
          children: [
            // ==========================
            // 🌟 HEADER (WITH PROFILE + LOGOUT)
            // ==========================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
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
                        "BSM Clinic Center",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Selamat datang, silakan pilih layanan",
                        style: TextStyle(color: Colors.white70, fontSize: 15),
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
                            Navigator.pushNamed(context, "/profile");
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
                        MaterialPageRoute(builder: (_) => const CekMemberPage()),
                      ),
                    ),
                    DashboardCard(
                      title: "Daftar Member",
                      icon: LucideIcons.userPlus,
                      color: const Color(0xFF3A6EA5),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DaftarMemberPage()),
                      ),
                    ),
                    DashboardCard(
                      title: "Home Service",
                      icon: LucideIcons.home,
                      color: const Color(0xFF60A5FA),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeServicePage()),
                      ),
                    ),
                    DashboardCard(
                      title: "Promo Clinic",
                      icon: LucideIcons.sparkle,
                      color: const Color(0xFFFF9F43),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PromoPage()),
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
                      onTap: () => WhatsAppService.openChat("6281234567890"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
