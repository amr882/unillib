import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/theme/app_colors.dart';

class SlideToAct extends StatefulWidget {
  final String text;
  final VoidCallback onConfirm;
  final bool isLoading;

  const SlideToAct({
    super.key,
    required this.text,
    required this.onConfirm,
    this.isLoading = false,
  });

  @override
  State<SlideToAct> createState() => _SlideToActState();
}

class _SlideToActState extends State<SlideToAct> {
  double _sliderPos = 0.0;
  bool _confirmed = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        final double thumbSize = 56.0;
        final double usableWidth = maxWidth - thumbSize - 8;

        return Container(
          width: double.infinity,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.navy.withOpacity(0.08),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.navy.withOpacity(0.1)),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Text indicator
              Center(
                child: Opacity(
                  opacity: (1 - (_sliderPos / usableWidth)).clamp(0.2, 1.0),
                  child: Text(
                    widget.text.toUpperCase(),
                    style: TextStyle(
                      color: AppColors.navy.withOpacity(0.6),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
              ),

              // Animated Thumb
              Positioned(
                left: _sliderPos + 4,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_confirmed || widget.isLoading) return;
                    setState(() {
                      _sliderPos += details.delta.dx;
                      _sliderPos = _sliderPos.clamp(0, usableWidth);
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_confirmed || widget.isLoading) return;
                    if (_sliderPos >= usableWidth * 0.9) {
                      setState(() {
                        _sliderPos = usableWidth;
                        _confirmed = true;
                      });
                      widget.onConfirm();
                    } else {
                      setState(() {
                        _sliderPos = 0;
                      });
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      color: _confirmed ? AppColors.gold : AppColors.navy,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_confirmed ? AppColors.gold : AppColors.navy)
                              .withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: widget.isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            _confirmed ? Icons.check : Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                ),
              ),

              // Track Fill
              if (_sliderPos > 0)
                Positioned(
                  left: 4,
                  child: IgnorePointer(
                    child: Container(
                      width: _sliderPos + thumbSize / 2,
                      height: thumbSize,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
