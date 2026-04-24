import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:unilib/core/theme/app_colors.dart';

/// The live camera view with scanning overlay and corner accents.
class ScannerCameraView extends StatelessWidget {
  final MobileScannerController controller;
  final void Function(BarcodeCapture) onDetect;

  const ScannerCameraView({
    super.key,
    required this.controller,
    required this.onDetect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  MobileScanner(controller: controller, onDetect: onDetect),
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
                      left: left
                          ? MediaQuery.of(context).size.width * 0.12
                          : null,
                      right: !left
                          ? MediaQuery.of(context).size.width * 0.12
                          : null,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          border: Border(
                            top: top
                                ? const BorderSide(
                                    color: AppColors.gold,
                                    width: 3,
                                  )
                                : BorderSide.none,
                            bottom: !top
                                ? const BorderSide(
                                    color: AppColors.gold,
                                    width: 3,
                                  )
                                : BorderSide.none,
                            left: left
                                ? const BorderSide(
                                    color: AppColors.gold,
                                    width: 3,
                                  )
                                : BorderSide.none,
                            right: !left
                                ? const BorderSide(
                                    color: AppColors.gold,
                                    width: 3,
                                  )
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
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Point camera at student\'s QR code',
                          style: TextStyle(fontSize: 13, color: Colors.white70),
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
}
