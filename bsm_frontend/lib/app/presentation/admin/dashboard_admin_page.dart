import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../services/api_service.dart';
import '../../../storage/local_storage.dart';
import '../widgets/dashboard_card.dart';
import '../admin/member_admin_page.dart';
import '../admin/home_service_admin_page.dart';
import '../admin/promo_admin_page.dart';
import '../admin/info_admin_page.dart';
import '../widgets/profile_admin_modal.dart';

class DashboardAdminPage extends StatelessWidget {
  const DashboardAdminPage({super.key});

  Future<void> logout(BuildContext context) async {
    try {
      // 🔐 hit API logout (optional tapi best practice)
      await ApiService.post("logout", {});
    } catch (e) {
      debugPrint("LOGOUT API ERROR: $e");
    }

    // 🧹 hapus token & data lokal
    await LocalStorage.clear();

    if (!context.mounted) return;

    // 🚀 reset navigation ke login
    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
  }

  void _showProfileModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProfileAdminModal(),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text("Konfirmasi Logout"),
          ],
        ),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              logout(context);
            },
            child: const Text("Keluar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
      body: SafeArea(
        child: Column(
          children: [
            // ================================
            // 🌟 HEADER ADMIN
            // ================================
            Container(
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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Admin Dashboard",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Kelola semua data bengkel di sini",
                        style: TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                    ],
                  ),

                  Positioned(
                    right: 0,
                    top: 0,
                    child: Row(
                      children: [
                        _headerIcon(
                          icon: LucideIcons.user,
                          onTap: () => _showProfileModal(context),
                        ),
                        const SizedBox(width: 10),
                        _headerIcon(
                          icon: LucideIcons.logOut,
                          onTap: () => _confirmLogout(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================================
            // 🌟 MENU GRID
            // ================================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.92,
                  children: [
                    DashboardCard(
                      title: "Kelola Member",
                      icon: LucideIcons.userCog,
                      color: const Color(0xFF0061A8),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MemberAdminPage(),
                        ),
                      ),
                    ),
                    DashboardCard(
                      title: "Kelola Home Service",
                      icon: LucideIcons.wrench,
                      color: const Color(0xFF00ADB5),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomeServiceAdminPage(),
                        ),
                      ),
                    ),
                    DashboardCard(
                      title: "Kelola Promo",
                      icon: LucideIcons.sparkles,
                      color: const Color(0xFFFF7F50),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PromoAdminPage(),
                        ),
                      ),
                    ),
                    DashboardCard(
                      title: "Kelola Info Bengkel",
                      icon: LucideIcons.info,
                      color: const Color(0xFF8E44AD),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const InfoAdminPage(),
                        ),
                      ),
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

  Widget _headerIcon({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
