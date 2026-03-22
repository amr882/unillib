import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/logic/user_provider.dart';
import 'package:unilib/core/model/book_model.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/core/theme/app_text_styles.dart';
import 'package:unilib/feature/home/logic/book_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Book> trendings = [];
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchData());
  }

  Future<void> _fetchData() async {
    await context.read<BooksProvider>().fetchTrending();
    final trending = context.read<BooksProvider>().trending;
    debugPrint('Trending count: ${trending.length}');
    for (final book in trending) {
      debugPrint('📚 ${book.title} — borrows: ${book.borrowCount}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.backGround,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.backgroundGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 3.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WelcomeHeader(
                      userName: "${user?.firstName} ${user?.lastName}"
                          .toUpperCase(),
                    ),
                    SizedBox(height: 2.h),
                    const _SearchBar(),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: 3.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: Text(
                      textAlign: TextAlign.center,
                      'There is no content for now, but stay tuned for updates!',
                      style: TextStyle(
                        fontSize: 18.sp,

                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  final String userName;

  const _WelcomeHeader({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: AppTextStyles.heading.copyWith(
                color: AppColors.textSub,
                fontSize: 20.sp,
              ),
            ),
            SizedBox(height: 0.3.h),
            Text(
              userName,
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 18.sp,
                color: AppColors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.gold,
          child: Text(
            userName.isNotEmpty ? userName[0] : 'U',
            style: AppTextStyles.heading.copyWith(
              color: AppColors.white,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: 6.h,
        decoration: BoxDecoration(
          color: AppColors.navyInput,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.navyBorder, width: 1),
        ),
        child: Row(
          children: [
            SizedBox(width: 4.w),
            Icon(Icons.search_rounded, color: AppColors.white, size: 2.5.h),
            SizedBox(width: 3.w),
            Expanded(
              child: TextField(
                style: AppTextStyles.inputText,
                decoration: InputDecoration(
                  hintText: 'Search books, journals, articles...',
                  hintStyle: AppTextStyles.hintText,
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
