import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ── Display ───────────────────────────────────────────────
  static final TextStyle heading = GoogleFonts.playfairDisplay(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    letterSpacing: 0.3,
    height: 1.25,
  );

  static final TextStyle subheading = GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSub,
    height: 1.55,
  );

  // ── Logo ──────────────────────────────────────────────────
  static final TextStyle logoName = GoogleFonts.playfairDisplay(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.blue,
    letterSpacing: 1.8,
  );

  static final TextStyle logoSub = GoogleFonts.dmSans(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    letterSpacing: 2.2,
  );

  // ── Form ──────────────────────────────────────────────────
  static final TextStyle fieldLabel = GoogleFonts.dmSans(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textSub,
    letterSpacing: 1.5,
  );

  static final TextStyle inputText = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.white,
  );

  static final TextStyle hintText = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  // ── Button ────────────────────────────────────────────────
  static final TextStyle buttonLabel = GoogleFonts.dmSans(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    letterSpacing: 0.4,
  );

  // ── Links & small ─────────────────────────────────────────
  static final TextStyle link = GoogleFonts.dmSans(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  static final TextStyle bodySmall = GoogleFonts.dmSans(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static final TextStyle dividerLabel = GoogleFonts.dmSans(
    fontSize: 12,
    color: AppColors.textMuted,
  );

  static final TextStyle socialLabel = GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSub,
  );
}
