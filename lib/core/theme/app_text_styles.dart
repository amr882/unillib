import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ── Display ───────────────────────────────────────────────
  static const TextStyle heading = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    letterSpacing: 0.3,
    height: 1.25,
  );

  static const TextStyle subheading = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSub,
    height: 1.55,
  );

  // ── Logo ──────────────────────────────────────────────────
  static const TextStyle logoName = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.blue,
    letterSpacing: 1.8,
  );

  static const TextStyle logoSub = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    letterSpacing: 2.2,
  );

  // ── Form ──────────────────────────────────────────────────
  static const TextStyle fieldLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textSub,
    letterSpacing: 1.5,
  );

  static const TextStyle inputText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.white,
  );

  static const TextStyle hintText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  // ── Button ────────────────────────────────────────────────
  static const TextStyle buttonLabel = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    letterSpacing: 0.4,
  );

  // ── Links & small ─────────────────────────────────────────
  static const TextStyle link = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static const TextStyle dividerLabel = TextStyle(
    fontSize: 12,
    color: AppColors.textMuted,
  );

  static const TextStyle socialLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSub,
  );
}
