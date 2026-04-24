import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/admin/ui/tabs/overview_tab.dart';
import 'package:unilib/feature/admin/ui/tabs/scanner_tab.dart';
import 'package:unilib/feature/admin/ui/tabs/borrows_tab.dart';
import 'package:unilib/feature/admin/ui/tabs/admin_profile_tab.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Overview'),
    _NavItem(icon: Icons.qr_code_scanner_rounded, label: 'Scanner'),
    _NavItem(icon: Icons.library_books_rounded, label: 'Borrows'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const OverviewTab();
      case 1:
        return const ScannerTab();
      case 2:
        return const BorrowsTab();
      case 3:
        return const AdminProfileTab();
      default:
        return const OverviewTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070E18),
      body: SafeArea(child: _buildScreen(_currentIndex)),
      bottomNavigationBar: _AdminBottomNavBar(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _AdminBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _AdminBottomNavBar({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 15, bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1628),
        border: Border(
          top: BorderSide(color: AppColors.gold.withOpacity(0.12), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 7.h,
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isSelected = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 0.5.h,
                          ),
                          decoration: isSelected
                              ? BoxDecoration(
                                  color: AppColors.gold.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                )
                              : null,
                          child: Icon(
                            item.icon,
                            size: 3.5.h,
                            color: isSelected
                                ? AppColors.gold
                                : AppColors.textMuted,
                          ),
                        ),
                        SizedBox(height: 0.4.h),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: isSelected
                                ? AppColors.gold
                                : AppColors.textMuted,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
