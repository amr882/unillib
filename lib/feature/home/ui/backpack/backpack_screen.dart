import 'package:flutter/material.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/feature/home/ui/backpack/widgets/active_borrows_view.dart';
import 'package:unilib/feature/home/ui/backpack/widgets/borrow_history_view.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BackpackScreen extends StatefulWidget {
  final String userId;
  const BackpackScreen({super.key, required this.userId});

  @override
  State<BackpackScreen> createState() => _BackpackScreenState();
}

class _BackpackScreenState extends State<BackpackScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGround,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Backpack',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.white,
            letterSpacing: -0.5,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.gold,
          unselectedLabelColor: AppColors.textSub,
          indicatorColor: AppColors.gold,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ActiveBorrowsView(userId: widget.userId),
          BorrowHistoryView(userId: widget.userId),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}
