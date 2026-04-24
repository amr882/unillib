import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unilib/core/model/borrow_model.dart';
import 'package:unilib/core/model/user_model.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/admin/logic/admin_provider.dart';
import 'package:unilib/feature/admin/ui/widgets/borrow_detail_card.dart';
import 'package:unilib/feature/admin/ui/tabs/scanner_tab.dart';
import 'widgets/borrows_search_bar.dart';
import 'widgets/borrows_filter_chips.dart';

class BorrowsTab extends StatefulWidget {
  const BorrowsTab({super.key});

  @override
  State<BorrowsTab> createState() => _BorrowsTabState();
}

class _BorrowsTabState extends State<BorrowsTab> {
  String _searchQuery = '';
  BorrowFilterType _filter = BorrowFilterType.all;

  // Cache user details to avoid repeated fetches
  final Map<String, UserModel?> _userCache = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final admin = context.read<AdminProvider>();
      if (admin.allBorrows.isEmpty) {
        admin.fetchAllBorrows();
      }
    });
  }

  List<BorrowRecord> _getFilteredBorrows(AdminProvider admin) {
    List<BorrowRecord> borrows;

    switch (_filter) {
      case BorrowFilterType.pending:
        borrows = admin.pendingBorrows;
        break;
      case BorrowFilterType.active:
        borrows = admin.activeBorrows;
        break;
      case BorrowFilterType.overdue:
        borrows = admin.overdueBorrows;
        break;
      case BorrowFilterType.returned:
        borrows = admin.returnedBorrows;
        break;
      case BorrowFilterType.all:
        borrows = admin.allBorrows;
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      borrows = borrows.where((b) {
        // Search in book / borrow info
        if (b.bookTitle.toLowerCase().contains(q)) return true;
        if (b.borrowId.toLowerCase().contains(q)) return true;

        // Search in cached user details
        final user = _userCache[b.userId];
        if (user != null) {
          if (user.fullName.toLowerCase().contains(q)) return true;
          if (user.email.toLowerCase().contains(q)) return true;
          if (user.studentId.toLowerCase().contains(q)) return true;
        }
        return false;
      }).toList();
    }

    return borrows;
  }

  Future<UserModel?> _getUserCached(String userId) async {
    if (_userCache.containsKey(userId)) return _userCache[userId];
    final user = await context.read<AdminProvider>().fetchUserDetails(userId);
    _userCache[userId] = user;
    return user;
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final borrows = _getFilteredBorrows(admin);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ─────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Text(
            'All Borrows',
            style: GoogleFonts.playfairDisplay(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Search bar ─────────────────────────────────────
        BorrowsSearchBar(onChanged: (v) => setState(() => _searchQuery = v)),
        const SizedBox(height: 14),

        // ── Filter chips ───────────────────────────────────
        BorrowsFilterChips(
          selected: _filter,
          onChanged: (type) => setState(() => _filter = type),
        ),
        const SizedBox(height: 14),

        // ── Count ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '${borrows.length} record${borrows.length != 1 ? 's' : ''}',
            style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white30),
          ),
        ),
        const SizedBox(height: 10),

        // ── List ───────────────────────────────────────────
        Expanded(
          child: admin.isLoading && admin.allBorrows.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                )
              : borrows.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.inbox_rounded,
                        size: 48,
                        color: Colors.white.withOpacity(0.15),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No records found',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Colors.white30,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.gold,
                  backgroundColor: const Color(0xFF0F1E30),
                  onRefresh: () => admin.fetchAllBorrows(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: borrows.length,
                    itemBuilder: (context, index) {
                      final borrow = borrows[index];
                      return FutureBuilder<UserModel?>(
                        future: _getUserCached(borrow.userId),
                        builder: (context, snap) {
                          return BorrowDetailCard(
                            borrow: borrow,
                            user: snap.data,
                            onScanQR:
                                (borrow.status == BorrowStatus.pendingPickup ||
                                    borrow.status == BorrowStatus.activeBorrow)
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const Scaffold(
                                          backgroundColor: Color(0xFF070E18),
                                          body: SafeArea(child: ScannerTab()),
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                            onReject:
                                borrow.status == BorrowStatus.pendingPickup
                                ? () async {
                                    await admin.rejectRequest(borrow.borrowId);
                                  }
                                : null,
                          );
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
