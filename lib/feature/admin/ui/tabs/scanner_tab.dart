import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:unilib/core/model/borrow_model.dart';
import 'package:unilib/core/model/user_model.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/admin/logic/admin_provider.dart';
import 'widgets/scanner_camera_view.dart';
import 'widgets/scanner_status_views.dart';
import 'widgets/scanner_result_view.dart';

class ScannerTab extends StatefulWidget {
  const ScannerTab({super.key});

  @override
  State<ScannerTab> createState() => _ScannerTabState();
}

class _ScannerTabState extends State<ScannerTab> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _isScanning = true;
  bool _isLoading = false;
  bool _isProcessing = false;
  BorrowRecord? _scannedBorrow;
  UserModel? _scannedUser;
  String? _errorMessage;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _onQRDetected(BarcodeCapture capture) async {
    if (!_isScanning || _isLoading) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final rawValue = barcode.rawValue!.trim();
    if (rawValue.isEmpty) return;

    final borrowId = rawValue.startsWith('UNILIB-BORROW:')
        ? rawValue.substring('UNILIB-BORROW:'.length)
        : rawValue;

    setState(() {
      _isScanning = false;
      _isLoading = true;
      _errorMessage = null;
      _scannedBorrow = null;
      _scannedUser = null;
    });

    try {
      final admin = context.read<AdminProvider>();
      final borrow = await admin.fetchBorrowById(borrowId);

      if (borrow == null) {
        setState(() {
          _errorMessage = 'No borrow record found for this QR code.';
          _isLoading = false;
        });
        return;
      }

      final user = await admin.fetchUserDetails(borrow.userId);

      if (!mounted) return;
      setState(() {
        _scannedBorrow = borrow;
        _scannedUser = user;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error scanning: $e';
        _isLoading = false;
      });
    }
  }

  void _resetScanner() {
    setState(() {
      _isScanning = true;
      _scannedBorrow = null;
      _scannedUser = null;
      _errorMessage = null;
      _isProcessing = false;
    });
  }

  Future<void> _handleConfirmPickup() async {
    if (_scannedBorrow == null || _isProcessing) return;
    setState(() => _isProcessing = true);

    final admin = context.read<AdminProvider>();
    final success = await admin.confirmPickup(_scannedBorrow!.borrowId);

    if (!mounted) return;

    if (success) {
      _showSuccessSnackbar('Pickup confirmed successfully! ✅');
      _resetScanner();
    } else {
      setState(() => _isProcessing = false);
      _showErrorSnackbar(admin.error ?? 'Failed to confirm pickup');
    }
  }

  Future<void> _handleConfirmReturn() async {
    if (_scannedBorrow == null || _isProcessing) return;
    setState(() => _isProcessing = true);

    final admin = context.read<AdminProvider>();
    final success = await admin.confirmReturn(_scannedBorrow!.borrowId);

    if (!mounted) return;

    if (success) {
      _showSuccessSnackbar('Return confirmed successfully! 📚');
      _resetScanner();
    } else {
      setState(() => _isProcessing = false);
      _showErrorSnackbar(admin.error ?? 'Failed to confirm return');
    }
  }

  Future<void> _handleReject() async {
    if (_scannedBorrow == null || _isProcessing) return;
    setState(() => _isProcessing = true);

    final admin = context.read<AdminProvider>();
    final success = await admin.rejectRequest(_scannedBorrow!.borrowId);

    if (!mounted) return;

    if (success) {
      _showSuccessSnackbar('Request rejected.');
      _resetScanner();
    } else {
      setState(() => _isProcessing = false);
      _showErrorSnackbar(admin.error ?? 'Failed to reject');
    }
  }

  void _showSuccessSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Header ─────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            children: [
              if (Navigator.canPop(context))
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              Text(
                'QR Scanner',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              if (!_isScanning)
                GestureDetector(
                  onTap: _resetScanner,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.gold.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: AppColors.gold,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Scan Again',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Scan student\'s QR code to process pickup or return',
            style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white38),
          ),
        ),
        const SizedBox(height: 20),

        // ── Content ────────────────────────────────────────
        Expanded(
          child: _isScanning
              ? ScannerCameraView(
                  controller: _scannerController,
                  onDetect: _onQRDetected,
                )
              : _isLoading
              ? const ScannerLoadingView()
              : _errorMessage != null
              ? ScannerErrorView(
                  errorMessage: _errorMessage!,
                  onRetry: _resetScanner,
                )
              : _scannedBorrow != null
              ? ScannerResultView(
                  borrow: _scannedBorrow!,
                  user: _scannedUser,
                  isProcessing: _isProcessing,
                  onConfirmPickup: _handleConfirmPickup,
                  onConfirmReturn: _handleConfirmReturn,
                  onReject: _handleReject,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
