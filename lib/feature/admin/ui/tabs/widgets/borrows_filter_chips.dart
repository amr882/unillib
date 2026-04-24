import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unilib/core/theme/app_colors.dart';

/// The filter categories for borrows tab.
enum BorrowFilterType { all, pending, active, overdue, returned }

/// Horizontal scrollable filter chips for borrow status filtering.
class BorrowsFilterChips extends StatelessWidget {
  final BorrowFilterType selected;
  final ValueChanged<BorrowFilterType> onChanged;

  const BorrowsFilterChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  String _label(BorrowFilterType type) {
    switch (type) {
      case BorrowFilterType.all:
        return 'All';
      case BorrowFilterType.pending:
        return 'Pending';
      case BorrowFilterType.active:
        return 'Active';
      case BorrowFilterType.overdue:
        return 'Overdue';
      case BorrowFilterType.returned:
        return 'Returned';
    }
  }

  Color _color(BorrowFilterType type) {
    switch (type) {
      case BorrowFilterType.all:
        return AppColors.gold;
      case BorrowFilterType.pending:
        return const Color(0xFFF59E0B);
      case BorrowFilterType.active:
        return const Color(0xFF3B82F6);
      case BorrowFilterType.overdue:
        return const Color(0xFFEF4444);
      case BorrowFilterType.returned:
        return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: BorrowFilterType.values.map((type) {
          final isSelected = selected == type;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _color(type).withOpacity(0.15)
                      : const Color(0xFF0F1E30),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? _color(type).withOpacity(0.4)
                        : Colors.white.withOpacity(0.08),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (type == BorrowFilterType.overdue && isSelected)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.warning_rounded,
                          size: 14,
                          color: _color(type),
                        ),
                      ),
                    Text(
                      _label(type),
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected ? _color(type) : Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
