import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unilib/core/model/user_model.dart';
import 'package:unilib/core/theme/app_colors.dart';

/// Displays the admin's profile card with avatar, name, role badge, and email.
class AdminProfileCard extends StatelessWidget {
  final UserModel? user;

  const AdminProfileCard({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.navyBorder),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.gold.withOpacity(0.3),
                  AppColors.gold.withOpacity(0.1),
                ],
              ),
              border: Border.all(
                color: AppColors.gold.withOpacity(0.4),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: AppColors.gold,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            user?.fullName ?? 'Admin',
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'ADMINISTRATOR',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.gold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (user != null) ...[
            _InfoTile(
              icon: Icons.email_outlined,
              label: 'Email',
              value: user!.email,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white30),
          const SizedBox(width: 10),
          Text(
            '$label:',
            style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white38),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
