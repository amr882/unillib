import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unilib/core/model/borrow_model.dart';
import 'package:unilib/core/model/user_model.dart';
import 'package:unilib/feature/admin/logic/admin_provider.dart';
import 'package:unilib/feature/admin/ui/widgets/borrow_detail_card.dart';
import 'package:unilib/feature/admin/ui/tabs/scanner_tab.dart';

enum StatType { pendingPickup, activeBorrows, overdue, returned }

class StatDetailsScreen extends StatelessWidget {
  final StatType type;
  final String title;

  const StatDetailsScreen({super.key, required this.type, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A121C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, admin, child) {
          List<BorrowRecord> borrows = [];

          switch (type) {
            case StatType.pendingPickup:
              borrows = admin.pendingBorrows;
              break;
            case StatType.activeBorrows:
              borrows = admin.activeBorrows;
              break;
            case StatType.overdue:
              borrows = admin.overdueBorrows;
              break;
            case StatType.returned:
              borrows = admin.returnedBorrows;
              break;
          }

          if (admin.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFEAB308),
              ), // Gold color
            );
          }

          if (borrows.isEmpty) {
            return Center(
              child: Text(
                'No records found.',
                style: GoogleFonts.dmSans(color: Colors.white54, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: borrows.length,
            itemBuilder: (context, index) {
              final borrow = borrows[index];
              return FutureBuilder<UserModel?>(
                future: admin.fetchUserDetails(borrow.userId),
                builder: (context, snap) {
                  return BorrowDetailCard(
                    borrow: borrow,
                    user: snap.data,
                    onReject: type == StatType.pendingPickup
                        ? () async {
                            await admin.rejectRequest(borrow.borrowId);
                          }
                        : null,
                    onScanQR:
                        (type == StatType.pendingPickup ||
                            type == StatType.activeBorrows ||
                            type == StatType.overdue)
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
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
