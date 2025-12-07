import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DashboardCardIOS extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const DashboardCardIOS({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ICON CIRCLE
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 34),
            ),

            const SizedBox(height: 16),

            // TITLE
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                letterSpacing: 0.2,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
