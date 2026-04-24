import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/home/ui/nav_pages/ai_page/ai_assistant.dart';
import 'package:unilib/feature/home/ui/nav_pages/browse_page/browse_screen.dart';
import 'package:unilib/feature/home/ui/nav_pages/home_page/home_screen.dart';
import 'package:unilib/feature/home/ui/nav_pages/profile_page/profile_screen.dart';
import 'package:unilib/feature/home/ui/widgets/backpack_fab.dart';
import 'package:provider/provider.dart';
import 'package:unilib/core/logic/user_provider.dart';
import 'package:unilib/feature/home/logic/user_books_provider.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  UserProvider? _userProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  void _initData() {
    _userProvider = context.read<UserProvider>();
    final booksProvider = context.read<UserBooksProvider>();

    if (_userProvider!.user != null) {
      booksProvider.syncBorrowCount(_userProvider!.user!.id);
    } else {
      // If user isn't loaded yet, we can listen for one update
      _userProvider!.addListener(_onUserLoaded);
    }
  }

  void _onUserLoaded() {
    if (_userProvider?.user != null) {
      context.read<UserBooksProvider>().syncBorrowCount(
        _userProvider!.user!.id,
      );
      _userProvider!.removeListener(_onUserLoaded);
    }
  }

  @override
  void dispose() {
    // Use cached reference — safe even after widget deactivation
    _userProvider?.removeListener(_onUserLoaded);
    super.dispose();
  }

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.menu_book_rounded, label: 'Browse'),
    _NavItem(icon: Icons.auto_awesome_rounded, label: 'UniLib AI'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const BrowseScreen();
      case 2:
        return const AiAssistant();
      case 3:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _buildScreen(_currentIndex),
      ),
      floatingActionButton: const BackpackFab(),
      bottomNavigationBar: _AppBottomNavBar(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: (i) {
          setState(() => _currentIndex = i);
        },
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _AppBottomNavBar({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 15, bottom: 15),
      decoration: BoxDecoration(
        color: AppColors.navyMid,
        border: Border(top: BorderSide(color: AppColors.navyBorder, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
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
