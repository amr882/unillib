import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/model/borrow_model.dart';
import 'package:unilib/core/service/borrow_service.dart';
import 'package:unilib/core/theme/app_colors.dart';

class AdminQrScannerScreen extends StatefulWidget {
  const AdminQrScannerScreen({super.key});

  @override
  State<AdminQrScannerScreen> createState() => _AdminQrScannerScreenState();
}

class _AdminQrScannerScreenState extends State<AdminQrScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  final BorrowService _borrowService = BorrowService();

  bool _isProcessing = false;
  BorrowRecord? _scannedRecord;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing || _scannedRecord != null) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null &&
          barcode.rawValue!.startsWith('UNILIB-BORROW:')) {
        final borrowId = barcode.rawValue!.replaceFirst('UNILIB-BORROW:', '');

        setState(() => _isProcessing = true);

        // Pause scanner while we fetch and show data
        _scannerController.stop();

        final record = await _borrowService.fetchRecord(borrowId);

        if (mounted) {
          setState(() {
            _isProcessing = false;
            _scannedRecord = record;
          });

          if (record == null) {
            _showError('Invalid or expired QR code.');
            _resetScanner();
          }
        }
        break; // Only process the first valid one
      }
    }
  }

  void _resetScanner() {
    setState(() {
      _scannedRecord = null;
      _isProcessing = false;
    });
    _scannerController.start();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> _handleConfirmAction() async {
    if (_scannedRecord == null) return;

    setState(() => _isProcessing = true);

    BorrowScanResult result;
    if (_scannedRecord!.status == BorrowStatus.pendingPickup) {
      result = await _borrowService.confirmPickup(_scannedRecord!.borrowId);
    } else if (_scannedRecord!.status == BorrowStatus.activeBorrow) {
      result = await _borrowService.confirmReturn(_scannedRecord!.borrowId);
    } else {
      _showError('No action available for this status.');
      _resetScanner();
      return;
    }

    if (mounted) {
      if (result.success) {
        _showSuccess(
          _scannedRecord!.status == BorrowStatus.pendingPickup
              ? 'Pickup Confirmed! 14-day loan started.'
              : 'Return Confirmed! Book available again.',
        );
        Navigator.pop(context); // Go back after success
      } else {
        _showError(result.error ?? 'Action failed.');
        _resetScanner();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Admin Scanner'),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flip_camera_ios_rounded),
            onPressed: () => _scannerController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Scanner View
          MobileScanner(controller: _scannerController, onDetect: _onDetect),

          // Overlay UI
          if (_scannedRecord == null && !_isProcessing)
            Center(
              child: Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gold, width: 3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'Align QR Code here',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                ),
              ),
            ),

          // Processing Indicator
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              ),
            ),

          // Result Card
          if (_scannedRecord != null && !_isProcessing)
            Align(alignment: Alignment.bottomCenter, child: _buildActionCard()),
        ],
      ),
    );
  }

  Widget _buildActionCard() {
    final record = _scannedRecord!;
    final isPickup = record.status == BorrowStatus.pendingPickup;

    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  record.bookCoverUrl,
                  height: 10.h,
                  width: 15.w,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 10.h,
                    width: 15.w,
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.bookTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Student: ${record.userId.substring(0, 6)}...', // would use relations for name
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isPickup
                            ? Colors.orange.withOpacity(0.2)
                            : Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isPickup ? 'AWAITING PICKUP' : 'AWAITING RETURN',
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: isPickup
                              ? Colors.orange.shade800
                              : Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetScanner,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Cancel Scan'),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _handleConfirmAction,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: isPickup
                        ? AppColors.gold
                        : Colors.blueAccent,
                  ),
                  child: Text(
                    isPickup ? 'Confirm Pickup' : 'Confirm Return',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
