import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/core/helper/extention.dart';
import 'package:unilib/core/routes/routes.dart';
import 'package:unilib/feature/admin/logic/admin_provider.dart';
import 'package:unilib/feature/admin/ui/widgets/stat_card.dart';
import 'package:unilib/feature/admin/ui/widgets/borrow_detail_card.dart';
import 'package:unilib/core/model/user_model.dart';
import 'package:unilib/feature/admin/ui/screens/stat_details_screen.dart';
import 'package:unilib/feature/admin/ui/tabs/scanner_tab.dart';

class OverviewTab extends StatefulWidget {
  const OverviewTab({super.key});

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchAllBorrows();
    });
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return RefreshIndicator(
      color: AppColors.gold,
      backgroundColor: const Color(0xFF0F1E30),
      onRefresh: () => admin.fetchAllBorrows(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Greeting ─────────────────────────────────────
            Text(
              'Dashboard',
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Library management overview',
              style: GoogleFonts.dmSans(fontSize: 14, color: Colors.white54),
            ),
            const SizedBox(height: 24),

            // ── Stats grid ───────────────────────────────────
            if (admin.isLoading && admin.allBorrows.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
              )
            else ...[
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.2,
                children: [
                  StatCard(
                    label: 'Pending Pickup',
                    value: '${admin.pendingBorrows.length}',
                    icon: Icons.hourglass_bottom_rounded,
                    color: const Color(0xFFF59E0B),
                    onTap: () => context.pushNamed(
                      Routes.statDetailsScreen,
                      arguments: {
                        'type': StatType.pendingPickup,
                        'title': 'Pending Pickup',
                      },
                    ),
                  ),
                  StatCard(
                    label: 'Active Borrows',
                    value: '${admin.activeBorrows.length}',
                    icon: Icons.menu_book_rounded,
                    color: const Color(0xFF3B82F6),
                    onTap: () => context.pushNamed(
                      Routes.statDetailsScreen,
                      arguments: {
                        'type': StatType.activeBorrows,
                        'title': 'Active Borrows',
                      },
                    ),
                  ),
                  StatCard(
                    label: 'Overdue',
                    value: '${admin.overdueBorrows.length}',
                    icon: Icons.warning_rounded,
                    color: const Color(0xFFEF4444),
                    bgColor: admin.overdueBorrows.isNotEmpty
                        ? const Color(0xFF1A0F0F)
                        : null,
                    onTap: () => context.pushNamed(
                      Routes.statDetailsScreen,
                      arguments: {
                        'type': StatType.overdue,
                        'title': 'Overdue Books',
                      },
                    ),
                  ),
                  StatCard(
                    label: 'Returned',
                    value: '${admin.returnedBorrows.length}',
                    icon: Icons.check_circle_rounded,
                    color: const Color(0xFF10B981),
                    onTap: () => context.pushNamed(
                      Routes.statDetailsScreen,
                      arguments: {
                        'type': StatType.returned,
                        'title': 'Returned Books',
                      },
                    ),
                  ),
                ],
              ),

              // ── Overdue section ─────────────────────────────
              if (admin.overdueBorrows.isNotEmpty) ...[
                const SizedBox(height: 30),
                Row(
                  children: [
                    const Icon(
                      Icons.warning_rounded,
                      color: Color(0xFFEF4444),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Overdue Books',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${admin.overdueBorrows.length}',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...admin.overdueBorrows.map((borrow) {
                  return FutureBuilder<UserModel?>(
                    future: context.read<AdminProvider>().fetchUserDetails(
                      borrow.userId,
                    ),
                    builder: (context, snap) {
                      return BorrowDetailCard(
                        borrow: borrow,
                        user: snap.data,
                        onScanQR: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const Scaffold(
                                backgroundColor: Color(0xFF070E18),
                                body: SafeArea(child: ScannerTab()),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }),
              ],

              // ── Recent pending ──────────────────────────────
              if (admin.pendingBorrows.isNotEmpty) ...[
                const SizedBox(height: 30),
                Text(
                  'Recent Pending Requests',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                ...admin.pendingBorrows.take(3).map((borrow) {
                  return FutureBuilder<UserModel?>(
                    future: context.read<AdminProvider>().fetchUserDetails(
                      borrow.userId,
                    ),
                    builder: (context, snap) {
                      return BorrowDetailCard(
                        borrow: borrow,
                        user: snap.data,
                        onScanQR: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const Scaffold(
                                backgroundColor: Color(0xFF070E18),
                                body: SafeArea(child: ScannerTab()),
                              ),
                            ),
                          );
                        },
                        onReject: () async {
                          await context.read<AdminProvider>().rejectRequest(
                            borrow.borrowId,
                          );
                        },
                      );
                    },
                  );
                }),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
