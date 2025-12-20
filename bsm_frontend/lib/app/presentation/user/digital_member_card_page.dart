import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DigitalMemberCard extends StatelessWidget {
  final String name;
  final String memberCode;
  final String membershipType;
  final String expiredAt;

  const DigitalMemberCard({
    super.key,
    required this.name,
    required this.memberCode,
    required this.membershipType,
    required this.expiredAt,
  });

  Map<String, dynamic> membershipTheme(String type) {
    switch (type.toLowerCase()) {
      case "platinum":
  return {
    "gradient": const LinearGradient(
      colors: [
        Color(0xFF9E9E9E), // abu metal gelap
        Color(0xFF424242), // charcoal
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    "badge": const Color(0xFF2E2E2E),
  };
      case "gold":
        return {
          "gradient": const LinearGradient(
            colors: [
              Color(0xFFFFE082),
              Color(0xFFB8860B),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          "badge": const Color(0xFF8B6508),
        };
      default: // BLUE
        return {
          "gradient": const LinearGradient(
            colors: [
              Color(0xFF1E88E5),
              Color(0xFF0D47A1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          "badge": const Color(0xFF0A3D91),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = membershipTheme(membershipType);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: theme['gradient'],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          /// Decorative background icon
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              LucideIcons.creditCard,
              size: 120,
              color: Colors.white.withOpacity(0.08),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "BSM MEMBERSHIP",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.85),
                      letterSpacing: 1.4,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme['badge'],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      membershipType.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              // ================= NAME =================
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.4,
                ),
              ),

              const SizedBox(height: 14),

              // ================= MEMBER CODE =================
              Row(
                children: [
                  const Icon(
                    LucideIcons.badgeCheck,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    memberCode,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ================= EXPIRED =================
              Row(
                children: [
                  const Icon(
                    LucideIcons.calendarClock,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Expired $expiredAt",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ================= FOOTER =================
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "DIGITAL CARD",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.6),
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
