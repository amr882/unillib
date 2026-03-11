import 'package:flutter/material.dart';

class AppDimens {
  AppDimens._();

  // ── Border radii ──────────────────────────────────────────
  static const double radiusXS   = 8.0;
  static const double radiusSM   = 12.0;
  static const double radiusMD   = 14.0;
  static const double radiusLG   = 18.0;
  static const double radiusXL   = 24.0;
  static const double radiusLogo = 18.0;

  static const BorderRadius cardRadius  = BorderRadius.all(Radius.circular(radiusLG));
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(radiusMD));
  static const BorderRadius btnRadius   = BorderRadius.all(Radius.circular(radiusMD));
  static const BorderRadius logoRadius  = BorderRadius.all(Radius.circular(radiusLogo));

  // ── Spacing ───────────────────────────────────────────────
  static const double spXXS  = 4.0;
  static const double spXS   = 8.0;
  static const double spSM   = 12.0;
  static const double spMD   = 16.0;
  static const double spLG   = 24.0;
  static const double spXL   = 32.0;
  static const double spXXL  = 48.0;

  // ── Icon / Logo sizes ─────────────────────────────────────
  static const double logoIconSize  = 64.0;
  static const double logoInnerIcon = 30.0;

  // ── Input ─────────────────────────────────────────────────
  static const double inputHeight      = 52.0;
  static const double inputIconSize    = 18.0;
  static const double inputPaddingLeft = 48.0;

  // ── Button ────────────────────────────────────────────────
  static const double btnHeight = 52.0;

  // ── Social button ─────────────────────────────────────────
  static const double socialBtnHeight = 48.0;

  // ── Screen padding ────────────────────────────────────────
  static const EdgeInsets screenPadding =
      EdgeInsets.symmetric(horizontal: 28.0);
}
