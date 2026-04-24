import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Search bar widget for filtering borrows by student name, email, ID, or book.
class BorrowsSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const BorrowsSearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F1E30),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: TextField(
          onChanged: onChanged,
          style: GoogleFonts.dmSans(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search by student name, email, ID, or book...',
            hintStyle: GoogleFonts.dmSans(color: Colors.white30, fontSize: 14),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Colors.white30,
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}
