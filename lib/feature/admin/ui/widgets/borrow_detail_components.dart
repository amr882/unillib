import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BorrowDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const BorrowDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white30),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white38),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class OverdueBanner extends StatelessWidget {
  final DateTime deadline;
  const OverdueBanner({super.key, required this.deadline});

  @override
  Widget build(BuildContext context) {
    final overdueDays = DateTime.now().difference(deadline).inDays;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 14,
            color: Color(0xFFEF4444),
          ),
          const SizedBox(width: 4),
          Text(
            'Overdue by $overdueDays day${overdueDays != 1 ? 's' : ''}',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }
}

class BorrowActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback? onTap;

  const BorrowActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.filled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: filled ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(onTap != null ? 0.5 : 0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: onTap != null ? color : color.withOpacity(0.4),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: onTap != null ? color : color.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
