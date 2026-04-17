import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:unilib/core/model/borrow_model.dart';
import 'package:unilib/core/model/user_model.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/admin/logic/admin_provider.dart';
import 'package:unilib/feature/admin/ui/widgets/borrow_detail_card.dart';

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
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 24),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: AppColors.gold.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.qr_code_scanner_rounded,
                            color: AppColors.gold, size: 16),
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
              ? _buildScannerView()
              : _isLoading
                  ? _buildLoadingView()
                  : _errorMessage != null
                      ? _buildErrorView()
                      : _buildResultView(),
        ),
      ],
    );
  }

  Widget _buildScannerView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  MobileScanner(
                    controller: _scannerController,
                    onDetect: _onQRDetected,
                  ),
                  // Scanning overlay
                  Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.gold.withOpacity(0.6),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  // Corner accents
                  ...List.generate(4, (i) {
                    final top = i < 2;
                    final left = i % 2 == 0;
                    return Positioned(
                      top: top
                          ? MediaQuery.of(context).size.height * 0.12
                          : null,
                      bottom: !top
                          ? MediaQuery.of(context).size.height * 0.12
                          : null,
                      left: left ? MediaQuery.of(context).size.width * 0.12 : null,
                      right:
                          !left ? MediaQuery.of(context).size.width * 0.12 : null,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          border: Border(
                            top: top
                                ? const BorderSide(
                                    color: AppColors.gold, width: 3)
                                : BorderSide.none,
                            bottom: !top
                                ? const BorderSide(
                                    color: AppColors.gold, width: 3)
                                : BorderSide.none,
                            left: left
                                ? const BorderSide(
                                    color: AppColors.gold, width: 3)
                                : BorderSide.none,
                            right: !left
                                ? const BorderSide(
                                    color: AppColors.gold, width: 3)
                                : BorderSide.none,
                          ),
                        ),
                      ),
                    );
                  }),
                  // Bottom hint
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Point camera at student\'s QR code',
                          style: GoogleFonts.dmSans(
                              fontSize: 13, color: Colors.white70),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.gold),
          SizedBox(height: 16),
          Text(
            'Looking up borrow record...',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  color: Color(0xFFEF4444), size: 48),
            ),
            const SizedBox(height: 20),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _resetScanner,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                ),
                child: Text(
                  'Try Again',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView() {
    if (_scannedBorrow == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Success scan indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.qr_code_2_rounded,
                    color: Color(0xFF10B981), size: 20),
                const SizedBox(width: 10),
                Text(
                  'QR Code scanned successfully',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Borrow detail card with actions
          BorrowDetailCard(
            borrow: _scannedBorrow!,
            user: _scannedUser,
            isProcessing: _isProcessing,
            onConfirmPickup:
                _scannedBorrow!.status == BorrowStatus.pendingPickup
                    ? _handleConfirmPickup
                    : null,
            onConfirmReturn:
                _scannedBorrow!.status == BorrowStatus.activeBorrow
                    ? _handleConfirmReturn
                    : null,
            onReject: _scannedBorrow!.status == BorrowStatus.pendingPickup
                ? _handleReject
                : null,
          ),
        ],
      ),
    );
  }
}
