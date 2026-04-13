import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/logic/user_provider.dart';
import 'package:unilib/feature/home/logic/user_books_provider.dart';
import 'package:unilib/feature/home/ui/nav_pages/profile_page/widgets/borrowed_books_sheet.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BackpackFab extends StatefulWidget {
  const BackpackFab({super.key});

  @override
  State<BackpackFab> createState() => _BackpackFabState();
}

class _BackpackFabState extends State<BackpackFab> {
  @override
  void initState() {
    super.initState();
    // Sync borrow count when the FAB is first initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncCount();
    });
  }

  void _syncCount() {
    final user = context.read<UserProvider>().user;
    if (user != null) {
      context.read<UserBooksProvider>().syncBorrowCount(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserBooksProvider>(
      builder: (context, provider, child) {
        final count = provider.activeBorrowCount;

        return GestureDetector(
          onTap: () {
            final user = context.read<UserProvider>().user;
            if (user == null) return;

            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => DraggableScrollableSheet(
                initialChildSize: 0.7,
                minChildSize: 0.5,
                maxChildSize: 0.95,
                builder: (_, controller) => BorrowedBooksSheet(
                  userId: user.id,
                  scrollController: controller,
                ),
              ),
            );
          },
          child: SizedBox(
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                SvgPicture.asset(
                  'assets/svgs/backpack-svgrepo-com.svg',
                  width: 30.sp,
                  height: 30.sp,
                ),

                if (count > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child:
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ).animate().scale(
                          duration: 300.ms,
                          curve: Curves.elasticOut,
                        ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
