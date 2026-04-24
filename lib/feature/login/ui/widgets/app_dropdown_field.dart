import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/core/theme/app_text_styles.dart';

class AppDropdownField<T> extends StatefulWidget {
  final String label;
  final String hint;
  final IconData prefixIcon;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;

  const AppDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
  });

  @override
  State<AppDropdownField<T>> createState() => _AppDropdownFieldState<T>();
}

class _AppDropdownFieldState<T> extends State<AppDropdownField<T>> {
  bool _focused = false;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode()
      ..addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label.toUpperCase(), style: AppTextStyles.fieldLabel),

        SizedBox(height: 2.h),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.navyInput,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _focused ? AppColors.blue : AppColors.navyBorder,
              width: _focused ? 1.5 : 1.0,
            ),
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: AppColors.blue.withOpacity(0.10),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: DropdownButtonFormField<T>(
            value: widget.value,
            focusNode: _focus,
            items: widget.items,
            onChanged: widget.onChanged,
            validator: widget.validator,
            style: AppTextStyles.inputText,
            dropdownColor: AppColors.navyCard,
            icon: const Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
            isExpanded: true,
            hint: Text(
              widget.hint,
              style: AppTextStyles.hintText,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 2.w,
                vertical: 2.h,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 14, right: 10),
                child: Icon(
                  widget.prefixIcon,
                  color: _focused ? AppColors.blue : AppColors.textMuted,
                  size: 2.h,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 48),
            ),
          ),
        ),
      ],
    );
  }
}
