import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unilib/core/model/user_model.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar with Blur Border Thing
          Stack(
            alignment: Alignment.center,
            children: [
              // Admin Glow layer
              Container(
                    width: 85,
                    height: 85,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withOpacity(0.4),
                          blurRadius: 25,
                          spreadRadius: 3,
                        ),
                        BoxShadow(
                          color: AppColors.gold.withOpacity(0.2),
                          blurRadius: 45,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  )
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .scale(
                    duration: 2.seconds,
                    begin: const Offset(1, 1),
                    end: const Offset(1.15, 1.15),
                    curve: Curves.easeInOut,
                  )
                  .fadeIn(duration: 1.seconds),

              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.gold.withOpacity(0.6),
                      AppColors.gold.withOpacity(0.1),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                  border: Border.all(
                    color: AppColors.gold.withOpacity(0.8),
                    width: 3,
                  ),
                ),
                child:
                    Icon(
                          Icons.admin_panel_settings_rounded,
                          color: AppColors.gold,
                          size: 36,
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .shimmer(
                          duration: 2000.ms,
                          color: Colors.white.withOpacity(0.4),
                        )
                        .scale(
                          duration: 1500.ms,
                          begin: const Offset(1, 1),
                          end: const Offset(1.1, 1.1),
                          curve: Curves.easeInOut,
                        )
                        .then()
                        .scale(
                          duration: 1500.ms,
                          begin: const Offset(1.1, 1.1),
                          end: const Offset(1, 1),
                          curve: Curves.easeInOut,
                        ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified_rounded,
                color: AppColors.gold,
                size: 20,
              ).animate().fadeIn(duration: 500.ms).scale(),
              const SizedBox(width: 8),
              Text(
                user?.fullName ?? 'Admin',
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withOpacity(0.4)),
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
            const _SectionHeader(title: 'Staff Information'),
            _InfoTile(
              icon: Icons.badge_outlined,
              label: 'Employee ID',
              value: user!.employeeId ?? 'STAFF-00${user!.id.substring(0, 3).toUpperCase()}',
            ),
            _InfoTile(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: user!.phoneNumber ?? '+1 (555) 123-4567',
            ),
            _InfoTile(
              icon: Icons.location_on_outlined,
              label: 'Branch',
              value: user!.branch ?? 'Main Campus Library',
            ),
            
            const SizedBox(height: 20),
            const _SectionHeader(title: 'Permissions'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (user!.permissions ?? ['User MGMT', 'Support'])
                  .map((p) => _PermissionChip(label: p))
                  .toList(),
            ),

            const SizedBox(height: 24),
            const _SectionHeader(title: 'Activity Summary'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Books Added',
                    value: '${user!.activityStats?['books_added'] ?? 12}',
                    icon: Icons.add_box_rounded,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Users Verified',
                    value: '${user!.activityStats?['approvals'] ?? 5}',
                    icon: Icons.how_to_reg_rounded,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.white54,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionChip extends StatelessWidget {
  final String label;
  const _PermissionChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_rounded, size: 12, color: AppColors.gold.withOpacity(0.7)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color.withOpacity(0.8)),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              color: Colors.white38,
              fontWeight: FontWeight.w500,
            ),
          ),
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
